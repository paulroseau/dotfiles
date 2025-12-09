from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .config import DEFAULT_CONFIG_PATH, Config
from .core import sync_section
from .result import ConfigError, Success


def log_multiline_error(error: ConfigError) -> None:
    lines = f"{error}".split("\n")
    sys.stderr.write("\n".join([f"[error] {line}" for line in lines]) + "\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Clone or update repositories defined in JSON files."
    )
    parser.add_argument(
        "-p",
        "--path",
        default=str(DEFAULT_CONFIG_PATH),
        help="Path to a configuration JSON file or a directory containing several configuration JSON files (default: $XDG_CONFIG_HOME/my-repos/). Precedence goes to files which come first in alphabetical order",
    )
    parser.add_argument(
        "-t",
        "--target",
        default=str(Path()),
        help="Target path where relative path will be moved under",
    )
    args = parser.parse_args(argv)

    json_path = Path(args.path).expanduser().resolve()
    if not json_path.exists():
        sys.stderr.write(f"[error] JSON file not found: {json_path}\n")
        return 2

    match Config.from_path(json_path):
        case ConfigError() as error:
            sys.stderr.write("[error] Invalid config files:\n")
            log_multiline_error(error)
            return 2
        case Success(config):
            base_dir = Path(args.target).expanduser().resolve()
            all_succeeded = all(
                sync_section(section, base_dir) for section in config.sections.values()
            )
            if all_succeeded:
                return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
