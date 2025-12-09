from __future__ import annotations

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .result import (
    ConfigErr,
    ConfigError,
    ConfigPathError,
    InvalidConfigError,
    InvalidJsonFileError,
    Result,
    Success,
)

DEFAULT_CONFIG_PATH = (
    Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "my-repos"
)


@dataclass(frozen=True)
class RepoSpec:
    clone_url: str
    name: str | None = None
    recurse_submodules: bool | None = None


@dataclass(frozen=True)
class SectionSpec:
    repositories: list[RepoSpec]
    local_path: Path | None = None


@dataclass(frozen=True)
class Config:
    sections: dict[str, SectionSpec]

    @classmethod
    def from_path(cls, path: Path) -> Result[Config]:
        if path.is_file():
            return cls.from_file(path)
        elif path.is_dir():
            sections: dict[str, SectionSpec] = {}
            errors: dict[Path, ConfigError] = {}

            for file_path in sorted(
                (p for p in path.iterdir() if p.is_file()), key=lambda p: p.name
            ):
                match cls.from_file(file_path):
                    case Success(value=config):
                        for name, section in config.sections.items():
                            if name not in sections:
                                sections[name] = section
                    case ConfigError() as error:
                        errors[file_path] = error

            if errors:
                return ConfigPathError(errors=errors)

            return Success(cls(sections=sections))
        else:
            return InvalidJsonFileError(
                message="config path is neither a directory nor a file",
                file_path=path,
            )

    @classmethod
    def from_file(cls, file_path: Path) -> Result[Config]:
        try:
            with file_path.open("r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as exception:
            return InvalidJsonFileError(
                message="failed to load JSON",
                file_path=file_path,
                cause=exception,
            )
        return cls.from_dict(data)

    @classmethod
    def from_dict(cls, data: Any) -> Result[Config]:
        if not isinstance(data, dict):
            return InvalidConfigError(
                config_errors=[
                    ConfigErr(
                        json_path="$.",
                        message="top-level JSON must be an object mapping: section name -> section config",
                    )
                ]
            )

        errors: list[ConfigErr] = []
        sections: dict[str, SectionSpec] = {}

        for section_name, section in data.items():
            json_path = f"$.{section_name}"
            if not isinstance(section, dict):
                errors.append(
                    ConfigErr(
                        json_path=json_path,
                        message="must be an object",
                    )
                )
                continue

            local_path = section.get("local_path")
            if local_path is not None and not isinstance(local_path, str):
                errors.append(
                    ConfigErr(
                        json_path=f"{json_path}.local_path",
                        message="must be a string when present",
                    )
                )
                continue

            repositories = section.get("repositories")
            if not isinstance(repositories, list):
                errors.append(
                    ConfigErr(
                        json_path=f"{json_path}.repositories",
                        message="must be an array",
                    )
                )
                continue

            repository_specs: list[RepoSpec] = []
            for index, repository in enumerate(repositories):
                json_repository_path = f"{json_path}.repositories[{index}]"
                if not isinstance(repository, dict):
                    errors.append(
                        ConfigErr(
                            json_path=json_repository_path,
                            message="must be an object",
                        )
                    )
                    continue

                url = repository.get("clone_url")
                if not isinstance(url, str) or not url.strip():
                    errors.append(
                        ConfigErr(
                            json_path=f"{json_repository_path}.clone_url",
                            message="`clone_url` is missing or an empty string",
                        )
                    )
                    continue

                name = repository.get("name")
                if name is not None and not isinstance(name, str):
                    errors.append(
                        ConfigErr(
                            json_path=f"{json_repository_path}.name",
                            message="`name` must be a string when present",
                        )
                    )
                    name = None

                recurse_submodules = repository.get("recurse_submodules")
                if recurse_submodules is not None and not isinstance(
                    recurse_submodules, bool
                ):
                    errors.append(
                        ConfigErr(
                            json_path=f"{json_repository_path}.recurse_submodules",
                            message="`recurse_submodules` must be a bool when present",
                        )
                    )
                    recurse_submodules = None

                repository_specs.append(
                    RepoSpec(
                        clone_url=url, name=name, recurse_submodules=recurse_submodules
                    )
                )

            sections[section_name] = SectionSpec(
                local_path=Path(os.path.expandvars(local_path)) if local_path else None,
                repositories=repository_specs,
            )

        if errors:
            return InvalidConfigError(config_errors=errors)

        return Success(cls(sections=sections))
