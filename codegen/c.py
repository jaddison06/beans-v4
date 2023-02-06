from codegen_types import *
from banner import *

def generate_enum(enum: CodegenEnum) -> str:
    out = f"typedef enum {{\n"

    for i, val in enumerate(enum.values):
        out += f"    {enum.name}_{val.name} = {i},\n"
    
    out += f"}} {enum.name};\n\n"

    return out

def codegen(files: list[ParsedGenFile]) -> str:
    out = \
"""#ifndef C_CODEGEN_H
#define C_CODEGEN_H

// old-style booleans to ensure Dart compatibility
typedef int BOOL;
#define TRUE 1
#define FALSE 0

"""
    for file in files:
        out += banner(file.name)
        for enum in file.enums:
            out += generate_enum(enum)
    
    out += "#endif // C_CODEGEN_H"

    return out