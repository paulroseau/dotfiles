from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

# TODO :
# - add target folder parameter (for relative paths)
# - do we need recurse-submodules?
# - add variables for format of the json keys
# - difference between sys.stderr and print
# - return failure types and append outside - no side effects in sync_section, log only in main
# - wrap in nix

def run(cmd: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )

def is_git_repo(path: Path) -> bool:
    if not path.exists() or not path.is_dir():
        return False

    if (path / ".git").exists():
        return True

    return False

def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)

# TODO return Nonn if not ok and handle
def repo_name_from_url(url: str) -> str:
    parsed = urlparse(url)
    if parsed.scheme in ("http", "https", "ssh", "git"):
        name = Path(parsed.path).name
    else:
        # Likely scp-like syntax (git@host:org/repo.git) or local path
        name = Path(url.split(":")[-1]).name
    if name.endswith(".git"):
        name = name[:-4]
    return name or "repo"

def clone_repo(url: str, dest: Path) -> bool:
    print(f"[clone] {url} -> {dest}")
    cp = run(["git", "clone", "--recurse-submodules", url, str(dest)])
    if cp.returncode != 0:
        sys.stderr.write(f"[error] clone failed for {url}: {cp.stderr}\n")
        return False
    return True

def pull_repo(dest: Path) -> bool:
    # Use ff-only to avoid creating merge commits unexpectedly
    cp = run(["git", "-C", str(dest), "pull", "--ff-only", "--recurse-submodules"])
    if cp.returncode != 0:
        sys.stderr.write(f"[warn] pull failed in {dest}: {cp.stderr}\n")
        return False
    print(f"[update] pulled latest in {dest}")
    return True

def sync_section(section_name: str, section: dict, base_dir: Path, failures: list[str]) -> None:
    repos = section.get("repositories", [])
    local_path = section.get("local_path")
    if not isinstance(local_path, str):
        sys.stderr.write(f"[warn] section '{section_name}' missing 'local_path'; skipping\n")
        return

    local_dir = Path(local_path)
    if not local_dir.is_absolute():
        local_dir = (base_dir / local_dir).resolve()

    ensure_dir(local_dir)
    print(f"[path] using local path: {local_dir}")

    for repo in repos:
        if not isinstance(repo, dict):
            sys.stderr.write(f"[warn] invalid repo entry in '{section_name}'; skipping\n")
            continue
        url = repo.get("clone_url") or repo.get("url")
        if not url:
            sys.stderr.write(f"[warn] repo missing 'clone_url'; skipping\n")
            continue

        name = repo.get("name") or repo_name_from_url(url)
        dest = local_dir / name

        if dest.exists():
            if is_git_repo(dest):
                ok = pull_repo(dest)
                if not ok:
                    failures.append(f"pull:{dest}")
            else:
                sys.stderr.write(f"[warn] {dest} exists but is not a git repo; skipping\n")
        else:
            ok = clone_repo(url, dest)
            if not ok:
                failures.append(f"clone:{url}")

def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)

def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Clone or update repositories defined in a JSON file.")
    parser.add_argument("-f", "--file", default="repositories.json", help="Path to repositories JSON file")
    args = parser.parse_args(argv)

    json_path = Path(args.file).expanduser().resolve()
    if not json_path.exists():
        sys.stderr.write(f"[error] JSON file not found: {json_path}\n")
        return 2

    try:
        data = load_json(json_path)
    except Exception as e:
        sys.stderr.write(f"[error] failed to load JSON: {e}\n")
        return 2

    if not isinstance(data, dict):
        sys.stderr.write("[error] JSON top-level must be an object with sections\n")
        return 2

    failures: list[str] = []
    base_dir = json_path.parent

    for section_name, section in data.items():
        if not isinstance(section, dict):
            sys.stderr.write(f"[warn] section '{section_name}' is not an object; skipping\n")
            continue
        print(f"[section] {section_name}")
        sync_section(section_name, section, base_dir, failures)

    if failures:
        sys.stderr.write(f"[warn] operations with issues: {', '.join(failures)}\n")
        return 1

    print("[info] all repositories are up to date")
    return 0

if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

