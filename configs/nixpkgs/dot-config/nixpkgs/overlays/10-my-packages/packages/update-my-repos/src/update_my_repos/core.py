from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

from .config import RepoSpec, SectionSpec


def run(cmd: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        text=True,
        capture_output=True,
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
    print(f"[info] cloning {repository_path}...", end="", flush=True)
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
        print("❌")
        print(f"[error] failed to clone {repository_path}", file=sys.stderr)
        print(f"[error] {completed_process.stderr}", file=sys.stderr)
        return False

    print("✅")
    return True


def pull_repo(repository_path: Path, recurse_submodules: bool | None) -> bool:
    print(f"[info] pulling {repository_path}...", end="", flush=True)
    completed_process = run(
        ["git", "-C", str(repository_path), "pull", "--ff-only"]
        + (["--recurse-submodules"] if recurse_submodules else [])
    )

    if completed_process.returncode != 0:
        print("❌")
        print(f"[error] failed to pull {repository_path}", file=sys.stderr)
        print(f"[error] {completed_process.stderr}", file=sys.stderr)
        return False

    print("✅")
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
        local_dir = local_dir / section.local_path

    if not local_dir.is_absolute():
        local_dir = local_dir.resolve()

    ensure_dir(local_dir)

    return all(
        sync_repository(local_dir=local_dir, repository=repository)
        for repository in section.repositories
    )
