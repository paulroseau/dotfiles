from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

import argparse
import json
import os
import subprocess
import sys

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
                        f"{json_repository_path}.clone_url: missing or not a non-empty string"
                    )
                    continue

                name = repository.get("name")
                if name is not None and not isinstance(name, str):
                    errors.append(
                        f"{json_repository_path}.name: must be a string when present"
                    )
                    name = None

                recurse_submodules = repository.get("recurse_submodules")
                if recurse_submodules is not None and not isinstance(name, bool):
                    errors.append(
                        f"{json_repository_path}.recurse_submodules: must be a bool when present"
                    )
                    recurse_submodules = None

                repository_specs.append(
                    RepoSpec(
                        clone_url=url, name=name, recurse_submodules=recurse_submodules
                    )
                )

            if isinstance(repositories, list):
                sections[section_name] = SectionSpec(
                    local_path=Path(local_path) if local_path else None,
                    repositories=repository_specs,
                )

        if errors:
            raise ConfigError("Invalid repositories.json:\n- " + "\n- ".join(errors))

        return cls(sections=sections)


def run(cmd: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def repository_name_from_url(url: str) -> str:
    parsed_url = urlparse(url)
    if parsed_url.scheme in ("http", "https", "ssh", "git"):
        name = Path(parsed_url.path).name
    else:
        # Likely scp-like syntax (git@host:org/repo.git) or local path
        name = Path(url.split(":")[-1]).name

    if name.endswith(".git"):
        return name[:-4]

    return name


def clone_repo(
    url: str, repository_path: Path, recurse_submodules: bool | None
) -> bool:
    sys.stdout.write(f"[info] cloning {repository_path}...")
    completed_process = run(
        [
            "git",
            "clone",
        ]
        + (["--recurse-submodules"] if recurse_submodules else [])
        + [
            "--",
            url,
            str(repository_path),
        ]
    )

    if completed_process.returncode != 0:
        sys.stdout.write("❌\n")
        sys.stderr.write(f"[error] failed to clone {repository_path}\n")
        sys.stderr.write(f"[error] {completed_process.stderr}\n")
        return False

    sys.stdout.write("✅\n")
    return True


def pull_repo(repository_path: Path, recurse_submodules: bool | None) -> bool:
    sys.stdout.write(f"[info] pulling {repository_path}...")
    completed_process = run(
        ["git", "-C", str(repository_path), "pull", "--ff-only"]
        + (["--recurse-submodules"] if recurse_submodules else [])
    )

    if completed_process.returncode != 0:
        sys.stdout.write("❌\n")
        sys.stderr.write(f"[error] failed to pull {repository_path}\n")
        sys.stderr.write(f"[error] {completed_process.stderr}\n")
        return False

    sys.stdout.write("✅\n")
    return True


def sync_repository(local_dir: Path, repository: RepoSpec) -> bool:
    repository_name = repository.name or repository_name_from_url(repository.clone_url)

    repository_path = local_dir / repository_name
    if repository_path.exists():
        return pull_repo(
            repository_path=repository_path,
            recurse_submodules=repository.recurse_submodules,
        )

    return clone_repo(
        url=repository.clone_url,
        repository_path=repository_path,
        recurse_submodules=repository.recurse_submodules,
    )


def sync_section(section: SectionSpec, base_dir: Path) -> bool:
    local_dir = base_dir

    if section.local_path:
        local_dir = local_dir / Path(section.local_path)

    if not local_dir.is_absolute():
        local_dir = local_dir.resolve()

    ensure_dir(local_dir)

    return all(
        [
            sync_repository(local_dir=local_dir, repository=repository)
            for repository in section.repositories
        ]
    )


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Clone or update repositories defined in a JSON file."
    )
    parser.add_argument(
        "-f",
        "--file",
        default=str(DEFAULT_CONFIG_PATH),
        help="Path to repositories JSON file (default: $XDG_CONFIG_HOME/my-repos/repositories.json)",
    )
    parser.add_argument(
        "-t",
        "--target",
        default=str(Path()),
        help="Target path where relative path will be moved under",
    )
    args = parser.parse_args(argv)

    json_path = Path(args.file).expanduser().resolve()
    if not json_path.exists():
        sys.stderr.write(f"[error] JSON file not found: {json_path}\n")
        return 2

    try:
        config = Config.from_file(json_path)
    except Exception as e:
        sys.stderr.write(f"[error] Config file is invalid: {e}\n")
        return 2

    base_dir = Path(args.target).expanduser().resolve()

    all_succeeded = all(
        [sync_section(section, base_dir) for section in config.sections.values()]
    )

    return 0 if all_succeeded else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
