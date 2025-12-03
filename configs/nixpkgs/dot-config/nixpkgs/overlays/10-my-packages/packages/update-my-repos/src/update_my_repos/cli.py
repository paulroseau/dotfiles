from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .config import DEFAULT_CONFIG_PATH, Config
from .core import sync_section


def main(argv: list[str] | None = None) -> int:
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
        sync_section(section, base_dir) for section in config.sections.values()
    )
    return 0 if all_succeeded else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
