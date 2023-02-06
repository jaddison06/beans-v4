from config import *

def codegen() -> str:
    # Files and directories that we don't want cloc to count.
    out = "\n".join([
        ".dart_tool",
        ".vscode",
        "build",
        "codegen",
        get_config(ConfigField.dart_output_path),
        get_config(ConfigField.c_output_path),
        "Makefile",
        get_config(ConfigField.cloc_exclude_list_path)
    ])

    return out
