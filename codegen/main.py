import os
import os.path as path

from parse import *
from codegen_types import *
from config import *

import dart
import c
import makefile
import cloc_exclude_list

def all_with_extension(directory: str, ext: str) -> list[str]:
    if not ext.startswith('.'): ext = f'.{ext}'

    out: list[str] = []
    for root, _, files in os.walk(directory):
        for file in files:
            if path.splitext(file)[-1] == ext:
                out.append(path.join(root, file))
    
    return out

def main():
    parsed_files: list[ParsedGenFile] = []
    for gen_file in all_with_extension(
        get_config(ConfigField.definition_search_path),
        get_config(ConfigField.definition_ext)
    ):
        parsed_files.append(
            Parser(gen_file).parse()
        )
    
    with open(get_config(ConfigField.dart_output_path), "wt") as fh:
        fh.write(dart    .codegen(parsed_files))
    with open(get_config(ConfigField.c_output_path),    "wt") as fh:
        fh.write(c       .codegen(parsed_files))
    with open("Makefile",                               "wt") as fh:
        fh.write(makefile.codegen(parsed_files))
    
    if (get_config(ConfigField.use_cloc) == "True"):
        with open(get_config(ConfigField.cloc_exclude_list_path), "wt") as fh:
            fh.write(cloc_exclude_list.codegen())

    

if __name__ == '__main__': main()