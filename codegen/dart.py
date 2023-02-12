from codegen_types import *
from typelookup import *
from banner import *
import os.path as path
from shared_library_extension import *
from typing import Callable
from annotations import *
from typemappings import *

# omg globals! what the hell jaddison! you're a terrible programmer and i hope you eat shit!
lookup: TypeLookup

def get_typename(type_: CodegenType, typename_dict: dict[str, str]) -> str:
    assert type_.typename in typename_dict or lookup.exists(type_.typename), f"Cannot find type {type_.typename}"
    if type_.typename in typename_dict:
        codegen_typename = type_.typename
    elif lookup.is_enum(type_.typename):
        codegen_typename = "int"
    elif lookup.is_class(type_.typename):
        if not type_.is_pointer:
            raise ValueError("Cannot pass class by value - please pass a pointer instead.")
        return "Pointer<Void>"
    else:
        raise ValueError(f"Data structures like {type_.typename} aren't currently supported.")
    
    if type_.is_pointer:
        return f"Pointer<{NATIVE[codegen_typename]}>"
    else:
        return typename_dict[codegen_typename]

def func_sig_name(file: ParsedGenFile, func_name: str, native: bool) -> str:
    out = f"_{file.libname()}_func_{func_name}"

    if native: out += "_native"
    out += "_sig"

    return out

def method_sig_name(file: ParsedGenFile, class_: CodegenClass, method: CodegenFunction, native: bool) -> str:
    out = f"_{file.libname()}_class_{class_.name}_method_{method.name}"

    if native: out += "_native"
    out += "_sig"

    return out

def func_typedefs(funcs: list[CodegenFunction], getName: Callable[[CodegenFunction, bool], str]) -> str:
    out: str = ""

    for func in funcs:
        out += f"// {func.signature_string()}\n"
        out += f"typedef {getName(func, True)} = {get_typename(func.return_type, NATIVE)} Function("
        for i, param_type in enumerate(func.params.values()):
            out += get_typename(param_type, NATIVE)
            if i != len(func.params) - 1:
                out += ", "
        out += ");\n"

        out += f"typedef {getName(func, False)} = "

        return_typename = get_typename(func.return_type, DART)
        out += return_typename

        out += " Function("
        for i, param_type in enumerate(func.params.values()):
            out += get_typename(param_type, DART)
            if i!= len(func.params) - 1:
                out += ", "
        out += ");\n\n"

    return out

def func_class_init_ref(file: ParsedGenFile, func: CodegenFunction, getName: Callable[[CodegenFunction, bool], str]) -> str:
    leaf = 'true'
    if has_annotation(func.annotations, 'Leaf'):
        leaf = get_annotation(func.annotations, 'Leaf').args[0]

    return f"_{file.libname()}.lookupFunction<{getName(func, True)}, {getName(func, False)}>('{func.name}', isLeaf: {leaf})"

def func_class_private_refs(file: ParsedGenFile, funcs: list[CodegenFunction], getName: Callable[[CodegenFunction, bool], str]) -> str:
    out = ''

    for func in funcs:
        # motivation behind making it static:
        # static:
        #   - pros:
        #       - only looked up / stored once
        #   - cons:
        #       - Dart lazily initializes - time overhead when first called
        # stored per-instance (probably via constructor):
        #   - pros:
        #       - initialized immediately so always available
        #   - cons:
        #       - storing lots (i know they're just pointers but still. for the many not the few)
        #       - lookup every time we construct is actually kinda expensive
        #       - ESPECIALLY in case of secondary constructors eg fromPointer() - that should be incredibly lightweight, not have time cost!
        out += f"    static final _{func.name} = {func_class_init_ref(file, func, getName)};\n"
    out += "\n"

    return out

def param_list(func: CodegenFunction) -> str:
    out: str = ""

    for i, param_name in enumerate(func.params):
        param_type = func.params[param_name]
        dart_type = get_typename(param_type, DART)


        if dart_type == "Pointer<Utf8>":
            dart_type = "String"
        elif param_type.typename == "bool":
            dart_type = "bool"
        elif lookup.is_enum(param_type.typename):
            dart_type = param_type.typename
        elif lookup.is_class(param_type.typename):
            dart_type = param_type.typename
        
        out += f"{dart_type} {param_name}"
        if i != len(func.params) - 1:
            out += ", "

    out += ") {\n"

    return out


def get_library(file: ParsedGenFile) -> str:
    out = ""

    out += f"DynamicLibrary.open('build{path.sep}"
    # in the Dart string, if we're on Windows, we want to put "build\\whatever", or the slash will get interpreted
    # by Dart as an escape character
    if path.sep == "\\":
        out += "\\"
    out += file.libpath_no_ext().replace("\\", "\\\\")
    
    out += f"{shared_library_extension()}')"

    return out

def func_class_func_return_type(func: CodegenFunction) -> str:
    typename = get_typename(func.return_type, DART)
    if func.return_type.typename == "bool":
        typename = "bool"
    elif lookup.is_enum(func.return_type.typename):
        typename = func.return_type.typename
    elif typename == "Pointer<Utf8>":
        typename = "String"
    elif lookup.is_class(func.return_type.typename):
        typename = func.return_type.typename

    return typename

def func_params(func: CodegenFunction) -> str:
    out = ""

    for i, param_name in enumerate(func.params):
        param_type = func.params[param_name]
        param_typename = get_typename(param_type, DART)
        if param_typename == "Pointer<Utf8>":
            out += f"{param_name}.toNativeUtf8()"
        elif param_type.typename == "bool":
            out += f"{param_name} ? 1 : 0"
        elif lookup.is_enum(param_type.typename):
            out += f"{param_type.typename}ToInt({param_name})"
        elif lookup.is_class(param_type.typename):
            out += f"{param_name}.structPointer"
        else:
            out += param_name
        
        if i != len(func.params) - 1:
            out += ", "

    return out

def func_class_return_string(func: CodegenFunction, get_value: str) -> str:
    out = ""

    if func.return_type.typename == "bool":
        out += f"({get_value}) == 1"
    elif lookup.is_enum(func.return_type.typename):
        out += f"{func.return_type.typename}FromInt({get_value})"
    elif get_typename(func.return_type, DART) == "Pointer<Utf8>":
        out += f"({get_value}).toDartString()"
    elif lookup.is_class(func.return_type.typename):
        # hoohooheehohaaaaaaaaaaaaaaa
        # trusting the C code to produce a valid struct!!!
        # also this kinda fucks the memory management - who is responsible for destroying this?
        out += f"{func.return_type.typename}.fromPointer({get_value})"
    else:
        out += get_value

    out += ";\n"

    return out

def funcs(file: ParsedGenFile) -> str:
    out: str = ""

    if len(file.functions) == 0: return out

    out += banner("function signature typedefs")
    out += func_typedefs(file.functions, lambda func, is_native: func_sig_name(file, func.name, is_native))
    
    out += banner(file.libname())

    out += f"class {file.libname()} {{\n"
    out += func_class_private_refs(file, file.functions, lambda func, is_native: func_sig_name(file, func.name, is_native))
    
    for func in file.functions:
        out += f"    {func_class_func_return_type(func)} {func.display_name()}("

        out += param_list(func)

        out +=  "        return "
        out += func_class_return_string(func,
            f"_{func.name}({func_params(func)})"
        )
        out += "    }\n\n"
    
    out += "}\n\n\n"
    
    return out


def enums(file: ParsedGenFile) -> str:
    out = ""

    if len(file.enums) == 0: return out

    out += banner("enums")
    for enum in file.enums:
        out += f"enum {enum.name} {{\n"
        for value in enum.values:
            out += f"    {value.name},\n"
        out += "}\n\n"
        
        out += f"{enum.name} {enum.name}FromInt(int val) => {enum.name}.values[val];\n"
        out += f"int {enum.name}ToInt({enum.name} val) => {enum.name}.values.indexOf(val);\n\n"
        out += f"String {enum.name}ToString({enum.name} val) {{\n"
        out += "    switch (val) {\n"
        for value in enum.values:
            out += f"        case {enum.name}.{value.name}: {{ return '{value.stringify_as}'; }}\n"
        out += "    }\n"
        out += "}\n\n"

    return out

def classes(file: ParsedGenFile) -> str:
    out: str = ""

    if len(file.classes) == 0: return out

    out += banner("func sig typedefs for classes")
    for class_ in file.classes:
        out += banner(class_.name)
        out += func_typedefs(class_.methods, lambda method, is_native: method_sig_name(file, class_, method, is_native))
    
    out += banner("class implementations")
    for class_ in file.classes:
        out += f"class {class_.name} {{\n"
        out +=  "    Pointer<Void> structPointer = nullptr;\n\n"
        out +=  "    void _validatePointer(String methodName) {\n"
        out +=  "        if (structPointer.address == 0) {\n"
        out += f"            throw Exception('{class_.name}.$methodName was called, but structPointer is a nullptr.');\n"
        out +=  "        }\n"
        out +=  "    }\n\n"

        out += func_class_private_refs(file, class_.methods, lambda method, is_native: method_sig_name(file, class_, method, is_native))

        # out += func_class_initializers(file, class_.methods,  lambda method, is_native: method_sig_name(file, class_, method, is_native))

        initializer = class_.initializer()
        out += f"    {class_.name}("
        out += param_list(initializer)

        out += f"        structPointer = _{initializer.name}("
        out += func_params(initializer)
        out += ");\n"
        out += "    }\n\n"

        out += f"    {class_.name}.fromPointer(Pointer<Void> ptr) {{\n"
        out +=  "        structPointer = ptr;\n"
        out +=  "    }\n\n"

        for method in class_.methods:
            if has_annotation(method.annotations, "Initializer"): continue

            # hopefully it's not mutable !!!!!
            del method.params["struct_ptr"]

            if has_annotation(method.annotations, "Getter"):
                getter = get_annotation(method.annotations, "Getter")
                if has_annotation(method.annotations, "Show"):
                    print(f"Warning: Annotation {get_annotation(method.annotations, 'Show')} on {class_.name}.{method.name} will have no effect, because the method also has the annotation {getter}.")
                out += f"    {func_class_func_return_type(method)} get "
                out += getter.args[0]
                out += " {\n"
            
            elif has_annotation(method.annotations, "SubscriptGet"):
                if has_annotation(method.annotations, "Show"):
                    print(f"Warning: Annotation {get_annotation(method.annotations, 'Show')} on {class_.name}.{method.name} will have no effect, because the method also has the annotation @SubscriptGet().")
                out += f"    {func_class_func_return_type(method)} operator[]("
                out += param_list(method);

            elif has_annotation(method.annotations, "SubscriptSet"):
                if has_annotation(method.annotations, "Show"):
                    print(f"Warning: Annotation {get_annotation(method.annotations, 'Show')} on {class_.name}.{method.name} will have no effect, because the method also has the annotation @SubscriptSet().")
                out += f"    {func_class_func_return_type(method)} operator[]=("
                out += param_list(method);

            else:
                if has_annotation(method.annotations, "Invalidates"):
                    out += "    @mustCallSuper\n"

                display_name = method.display_name()
                if has_annotation(class_.annotations, 'Prefix'):
                    prefix = get_annotation(class_.annotations, 'Prefix')
                    if display_name == method.name and display_name.startswith(prefix.args[0]):
                        display_name = display_name[len(prefix.args[0]):]
                out += f'    {func_class_func_return_type(method)} {display_name}('
                
                out += param_list(method)

            out += f"        _validatePointer('{method.display_name()}');\n"
            get_return_value = f"_{method.name}(structPointer"
            if len(method.params) > 0:
                get_return_value += ", "
            get_return_value += func_params(method)
            get_return_value += ")"
            return_string = func_class_return_string(method, get_return_value)
            if has_annotation(method.annotations, "Invalidates"):
                out += f"        final out = {return_string}"
                out += "\n        // this method invalidates the pointer, probably by freeing memory\n"
                out += "        structPointer = nullptr;\n\n"
                out += "        return out;\n"
            else:
                out += f"        return {return_string}"
            out += "    }\n\n"
        
        out += "}\n\n"


    return out


def codegen(files: list[ParsedGenFile]) -> str:
    out = ""
    out += \
"""// for native types & basic FFI functionality
import 'dart:ffi';
// for string utils
import 'package:ffi/ffi.dart';
// for @mustCallSuper
import 'package:meta/meta.dart';

"""

    global lookup
    lookup = TypeLookup(files)

    for file in files:
        out += banner(f"file: {file.name}")
        out += f'final _{file.libname()} = {get_library(file)};\n\n'
        out += funcs(file)
        out += enums(file)
        out += classes(file)

    return out
