from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import TypeVar

A = TypeVar("A", covariant=True)


class Result[A]: ...


@dataclass(frozen=True)
class Success(Result[A]):
    value: A


class ConfigError(Exception, Result[A]):
    def __str__(self) -> str:
        return self.__class__.__name__


@dataclass(frozen=True)
class ConfigPathError(ConfigError):
    errors: dict[Path, ConfigError]

    def __str__(self) -> str:
        return "\n".join(
            [f"- {file_path}: {error}" for file_path, error in self.errors.items()]
        )


@dataclass(frozen=True)
class InvalidJsonFileError(ConfigError):
    message: str
    file_path: Path
    cause: Exception | None = None

    def __str__(self) -> str:
        lines = [f"{self.message}:", f"    - path: {self.file_path}"]
        if self.cause:
            lines.append(f"    - cause: {self.cause}")

        return "\n".join(lines)


@dataclass(frozen=True)
class InvalidConfigError(ConfigError):
    config_errors: list[ConfigErr] = field(default_factory=list)

    def __str__(self) -> str:
        return "\n- ".join([f"{error}" for error in self.config_errors])


@dataclass(frozen=True)
class ConfigErr:
    json_path: str
    message: str

    def __str__(self) -> str:
        return f"{self.json_path}: {self.message}"
