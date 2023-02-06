from dataclasses import dataclass
from typing import Optional
import os.path as path
from annotations import *

@dataclass
class CodegenType:
    typename: str
    is_pointer: bool

    def c_type(self) -> str:
        out = self.typename

        if self.is_pointer: out += "*"

        return out

@dataclass
class CodegenFunction:
    name: str
    return_type: CodegenType
    params: dict[str, CodegenType]
    annotations: list[CodegenAnnotation]

    def signature_string(self) -> str:
        out = ""

        out += self.return_type.c_type()
        out += " "
        out += self.name
        out += "("
        for i, param_name in enumerate(self.params):
            param_type = self.params[param_name]
            out += param_type.c_type()
            out += " "
            out += param_name
            if i != len(self.params) - 1:
                out += ", "
        
        out += ")"

        return out
    
    def display_name(self) -> str:
        if has_annotation(self.annotations, "Getter"):
            return get_annotation(self.annotations,"Getter").args[0]
        if has_annotation(self.annotations, "Show"):
            return get_annotation(self.annotations, "Show").args[0]
        else:
            return self.name


@dataclass
class CodegenDataStructureField:
    name: str
    type_: CodegenType
    annotations: list[CodegenAnnotation]

@dataclass
class CodegenEnumValue:
    name: str
    stringify_as: str

@dataclass
class CodegenEnum:
    name: str
    values: list[CodegenEnumValue]
    annotations: list[CodegenAnnotation]

@dataclass
class CodegenClass:
    name: str
    fields: list[CodegenDataStructureField]
    methods: list[CodegenFunction]
    annotations: list[CodegenAnnotation]

    def has_initializer_annotation(self, method: CodegenFunction) -> bool:
        for annotation in method.annotations:
            if annotation.name == "Initializer":
                return True
        return False

    def validate(self) -> Optional[str]:
        initializer: Optional[CodegenFunction] = None
        for method in self.methods:
            if self.has_initializer_annotation(method):
                initializer = method
                break
        
        if initializer is None:
            return f"The class {self.name} must have a method annotated as @Initializer."
        
        if not (
            initializer.return_type.typename == "void" and
            initializer.return_type.is_pointer):
            return f"The initializer for the class {self.name} must have a return type of void* ."

    
    def initializer(self) -> CodegenFunction:
        for method in self.methods:
            if self.has_initializer_annotation(method):
                return method
        
        raise ValueError("CodegenClass.initializer() was called but no initializer method was found.")

# each set of annotations is a dict of annotation name to argc
SUPPORTED_ANNOTATIONS: dict[str, dict[str, int]] = {
    "class": {
        "Prefix": 1
    },
    "function": {
        "Show": 1
    },
    "method": {
        "Initializer": 0,
        "Getter": 1,
        "Show": 1,
        "Invalidates": 0
    },
    "enum": {

    },
    "file": {
        "LinkWithLib": 1
    }
}

@dataclass
class ParsedGenFile:
    # eg native/some_subdir/something.gen
    name: str

    functions: list[CodegenFunction]
    enums: list[CodegenEnum]
    classes: list[CodegenClass]

    annotations: list[CodegenAnnotation]

    def has_code(self) -> bool:
        return len(self.functions) > 0 or len(self.classes) > 0

    def validate_annotation(self, annotation: CodegenAnnotation, typename: str) -> Optional[str]:
        if annotation.name not in SUPPORTED_ANNOTATIONS[typename]:
            return f"Annotation '{annotation}' not supported on objects of type '{typename}'."
        
        arg_len = len(annotation.args)
        expected_arg_len = SUPPORTED_ANNOTATIONS[typename][annotation.name]
        if arg_len != expected_arg_len:
            return f"Annotation {annotation} expected {expected_arg_len} arguments, but got {arg_len}."
        

    def validate_annotation_list(self, annotations: list[CodegenAnnotation], typename: str) -> str:
        out = ""

        for annotation in annotations:
            res = self.validate_annotation(annotation, typename)
            if res != None:
                out += res + "\n"
        
        return out

    def validate_all_annotations(self) -> str:
        out = ""

        out += self.validate_annotation_list(self.annotations, "file")
        for function in self.functions:
            out += self.validate_annotation_list(function.annotations, "function")
        for enum in self.enums:
            out += self.validate_annotation_list(enum.annotations, "enum")
        for class_ in self.classes:
            out += self.validate_annotation_list(class_.annotations, "class")
            for method in class_.methods:
                out += self.validate_annotation_list(method.annotations, "method")

        if out.endswith('\n'):
            out = out[:-1]

        return out

    # returns "something"
    def id(self) -> str:
        return path.splitext(path.basename(self.name))[0]
    
    def name_no_ext(self) -> str:
        return path.splitext(self.name)[0]
    
    def libpath_no_ext(self) -> str:
        return path.dirname(self.name) + path.sep + self.libname()
    
    def libname(self) -> str:
        return f"lib{self.id()}"
