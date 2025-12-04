from __future__ import annotations

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

DEFAULT_CONFIG_PATH = (
    Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    / "my-repos"
    / "repositories.json"
)


class ConfigError(Exception): ...


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
    def from_file(cls, file_path: Path) -> Config:
        try:
            with file_path.open("r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            raise ConfigError(f"Failed to load JSON from {file_path}: {e}") from e
        return cls.from_dict(data)

    @classmethod
    def from_dict(cls, data: Any) -> Config:
        if not isinstance(data, dict):
            raise ConfigError(
                "Top-level JSON must be an object mapping section name -> section config"
            )

        errors: list[str] = []
        sections: dict[str, SectionSpec] = {}

        for section_name, section in data.items():
            json_path = f"$.{section_name}"
            if not isinstance(section, dict):
                errors.append(f"{json_path}: must be an object")
                continue

            local_path = section.get("local_path")
            if local_path is not None and not isinstance(local_path, str):
                errors.append(f"{json_path}.local_path: must be a string when present")
                continue

            repositories = section.get("repositories")
            if not isinstance(repositories, list):
                errors.append(f"{json_path}.repositories: must be an array")
                continue

            repository_specs: list[RepoSpec] = []
            for index, repository in enumerate(repositories):
                json_repository_path = f"{json_path}.repositories[{index}]"
                if not isinstance(repository, dict):
                    errors.append(f"{json_repository_path}: must be an object")
                    continue

                url = repository.get("clone_url")
                if not isinstance(url, str) or not url.strip():
                    errors.append(
                        f"{json_repository_path}.clone_url: missing or not a non-empty "
                        "string"
                    )
                    continue

                name = repository.get("name")
                if name is not None and not isinstance(name, str):
                    errors.append(
                        f"{json_repository_path}.name: must be a string when present"
                    )
                    name = None

                recurse_submodules = repository.get("recurse_submodules")
                if recurse_submodules is not None and not isinstance(
                    recurse_submodules, bool
                ):
                    errors.append(
                        f"{json_repository_path}.recurse_submodules: must be a bool "
                        "when present"
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
            raise ConfigError("Invalid repositories.json:\n- " + "\n- ".join(errors))

        return cls(sections=sections)
