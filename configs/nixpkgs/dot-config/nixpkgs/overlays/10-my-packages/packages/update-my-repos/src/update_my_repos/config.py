from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from enum import Enum
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


class RepoKey(str, Enum):
    LOCAL_PATH = "local_path"
    REPOSITORIES = "repositories"
    CLONE_URL = "clone_url"
    NAME = "name"
    RECURSE_SUBMODULES = "recurse_submodules"


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
    overridden_sections: dict[Path, list[str]] = field(default_factory=dict)

    @classmethod
    def from_path(cls, path: Path, excluded_section: set[str]) -> Result[Config]:
        if path.is_file():
            return cls.from_file(path)
        elif path.is_dir():
            sections: dict[str, SectionSpec] = {}
            overridden_sections: dict[Path, list[str]] = {}
            errors: dict[Path, ConfigError] = {}

            for file_path in sorted(
                (p for p in path.iterdir() if p.is_file()), key=lambda p: p.name
            ):
                match cls.from_file(file_path):
                    case Success(value=config):
                        for name, section in config.sections.items():
                            if name not in excluded_section:
                                if name not in sections:
                                    sections[name] = section
                                else:
                                    overridden_sections.setdefault(
                                        file_path, []
                                    ).append(name)
                    case ConfigError() as error:
                        errors[file_path] = error

            if errors:
                return ConfigPathError(errors=errors)

            return Success(
                cls(sections=sections, overridden_sections=overridden_sections)
            )
        else:
            return InvalidJsonFileError(
                path=path,
                reason="config path is neither a directory nor a file",
            )

    @classmethod
    def from_file(cls, file_path: Path) -> Result[Config]:
        try:
            with file_path.open("r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as exception:
            return InvalidJsonFileError(
                path=file_path,
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

            if invalid_keys := section.keys() - {
                RepoKey.LOCAL_PATH,
                RepoKey.REPOSITORIES,
            }:
                errors.append(
                    ConfigErr(
                        json_path=json_path,
                        message=f"invalid key(s) ({', '.join([f'{key}' for key in invalid_keys])})",
                    )
                )
                continue

            local_path = section.get(RepoKey.LOCAL_PATH)
            if local_path is not None and not isinstance(local_path, str):
                errors.append(
                    ConfigErr(
                        json_path=f"{json_path}.{RepoKey.LOCAL_PATH}",
                        message="must be a string when present",
                    )
                )
                continue

            repositories = section.get(RepoKey.REPOSITORIES)
            if not isinstance(repositories, list):
                errors.append(
                    ConfigErr(
                        json_path=f"{json_path}.{RepoKey.REPOSITORIES}",
                        message="must be an array",
                    )
                )
                continue

            repository_specs: list[RepoSpec] = []
            for index, repository in enumerate(repositories):
                json_repository_path = f"{json_path}.{RepoKey.REPOSITORIES}[{index}]"
                if not isinstance(repository, dict):
                    errors.append(
                        ConfigErr(
                            json_path=json_repository_path,
                            message="must be an object",
                        )
                    )
                    continue

                if invalid_keys := repository.keys() - {
                    RepoKey.CLONE_URL,
                    RepoKey.NAME,
                    RepoKey.RECURSE_SUBMODULES,
                }:
                    errors.append(
                        ConfigErr(
                            json_path=json_path,
                            message=f"invalid key(s) ({', '.join([f'{key}' for key in invalid_keys])})",
                        )
                    )
                    continue

                url = repository.get(RepoKey.CLONE_URL)
                if not isinstance(url, str) or not url.strip():
                    errors.append(
                        ConfigErr(
                            json_path=f"{json_repository_path}.{RepoKey.CLONE_URL}",
                            message=f"`{RepoKey.CLONE_URL}` is missing or an empty string",
                        )
                    )
                    continue

                name = repository.get(RepoKey.NAME)
                if name is not None and not isinstance(name, str):
                    errors.append(
                        ConfigErr(
                            json_path=f"{json_repository_path}.{RepoKey.NAME}",
                            message=f"`{RepoKey.NAME}` must be a string when present",
                        )
                    )
                    name = None

                recurse_submodules = repository.get(RepoKey.REPOSITORIES)
                if recurse_submodules is not None and not isinstance(
                    recurse_submodules, bool
                ):
                    errors.append(
                        ConfigErr(
                            json_path=f"{json_repository_path}.{RepoKey.REPOSITORIES}",
                            message=f"`{RepoKey.RECURSE_SUBMODULES}` must be a bool when present",
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

    @property
    def pretty_print_overriden_sections(self):
        return "\n".join(
            f"- {file_path}: {', '.join(section_names)}"
            for file_path, section_names in self.overridden_sections.items()
        )
