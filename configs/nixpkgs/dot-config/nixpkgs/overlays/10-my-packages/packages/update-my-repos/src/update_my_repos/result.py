from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import TypeVar

from .utils import indent

A = TypeVar("A")


class Result[A]: ...


@dataclass(frozen=True)
class Success(Result[A]):
    value: A


class ConfigError(Exception, Result[A]):
    def __str__(self) -> str:
        return self.description

    @property
    def description(self) -> str:
        return "Configuration Error"

    @property
    def details(self) -> str:
        return ""

    @property
    def detailed_description(self) -> str:
        if self.details:
            return "\n".join([self.description + ":", self.details])

        return self.description + "."


@dataclass(frozen=True)
class ConfigPathError(ConfigError):
    errors: dict[Path, ConfigError]

    @property
    def description(self) -> str:
        return "Configuration errors in some configuration files"

    @property
    def details(self) -> str:
        def message(file_path: Path, error: ConfigError) -> str:
            result = f"- {file_path}: {error}"
            if error.details:
                result = (
                    result + "\n" + indent(prefix="  ", multiline_string=error.details)
                )

            return result

        lines = [message(file_path, error) for file_path, error in self.errors.items()]
        return "\n".join(lines)


@dataclass(frozen=True)
class InvalidJsonFileError(ConfigError):
    path: Path
    reason: str | None = None
    cause: Exception | None = None

    @property
    def description(self) -> str:
        return "Configuration file is not a valid JSON"

    @property
    def details(self) -> str:
        lines = [f"- path: {self.path}"]
        if self.reason:
            lines.append(f"- reason: {self.reason}")
        if self.cause:
            lines.append(f"- cause: {self.cause}")

        return "\n".join(lines)


@dataclass(frozen=True)
class InvalidConfigError(ConfigError):
    config_errors: list[ConfigErr] = field(default_factory=list)

    @property
    def description(self) -> str:
        return "JSON file is not a valid configuration"

    @property
    def details(self) -> str:
        return "\n".join([f"- {error}" for error in self.config_errors])


@dataclass(frozen=True)
class ConfigErr:
    json_path: str
    message: str

    def __str__(self) -> str:
        return f"{self.json_path}: {self.message}"
