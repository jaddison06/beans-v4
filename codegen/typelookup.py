from codegen_types import *

class TypeLookup:
    def __init__(self, files: list[ParsedGenFile]):
        self.enums: list[str] = []
        self.classes: list[str] = []
        
        for file in files:
            for enum in file.enums:
                self.enums.append(enum.name)
            for class_ in file.classes:
                self.classes.append(class_.name)
        
    def is_enum(self, typename: str) -> bool:
        return typename in self.enums
    def is_class(self, typename: str) -> bool:
        return typename in self.classes
    
    def exists(self, typename: str) -> bool:
        return self.is_enum(typename) or self.is_class(typename)
