from __future__ import annotations

import argparse
import sys
from pathlib import Path

from .config import DEFAULT_CONFIG_PATH, Config
from .core import sync_section
from .result import ConfigError, Success
from .utils import indent


def log_multiline(log: str, log_level: str = "info") -> None:
    lines = indent(prefix=f"[{log_level}] ", multiline_string=log)
    match log_level:
        case "error":
            print(lines, file=sys.stderr)
        case _:
            print(lines)


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

    match Config.from_path(json_path):
        case ConfigError() as error:
            log_multiline(log=error.detailed_description, log_level="error")
            return 2
        case Success(config):
            if config.overridden_sections:
                log_multiline(
                    log="The following paths contain overriden sections:",
                    log_level="warn",
                )
                log_multiline(
                    log=config.pretty_print_overriden_sections, log_level="warn"
                )
            base_dir = Path(args.target).expanduser().resolve()
            all_succeeded = all(
                sync_section(section, base_dir) for section in config.sections.values()
            )
            if all_succeeded:
                return 0
    return 1


def cli() -> None:
    try:
        return_code = main(sys.argv[1:])
    except KeyboardInterrupt:
        print("\n\nInterrupted by user (Ctrl-C)", file=sys.stderr)
        return_code = 130
    raise SystemExit(return_code)
