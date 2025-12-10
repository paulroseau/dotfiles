def indent(prefix: str, multiline_string: str) -> str:
    lines = multiline_string.split("\n")
    return "\n".join([prefix + line for line in lines])
