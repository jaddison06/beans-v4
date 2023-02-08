NATIVE: dict[str, str] = {
    "void": "Void",
    "char": "Utf8",
    "int": "Int32",
    "double": "Double",
    "bool": "Int32",
    'i8': 'Int8',
    'i16': 'Int16',
    'i32': 'Int32',
    'i64': 'Int64',
    'u8': 'Uint8',
    'u16': 'Uint16',
    'u32': 'Uint32',
    'u64': 'Uint64'
}

DART: dict[str, str] = {
    "void": "void",
    "char": "Utf8",
    "int": "int",
    "double": "double",
    "bool": "int",
    'i8': 'int',
    'i16': 'int',
    'i32': 'int',
    'i64': 'int',
    'u8': 'int',
    'u16': 'int',
    'u32': 'int',
    'u64': 'int'
}

def is_int_type(typename: str) -> bool:
    return DART[typename] == 'int'