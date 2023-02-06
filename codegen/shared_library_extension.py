import platform

def shared_library_extension() -> str:
    if platform.system() == 'Linux': return '.so'
    elif platform.system() == 'Darwin': return '.dylib'
    elif platform.system() == 'Windows': return '.dll'
    else: raise ValueError('Couldn\'t get shared library extension - unknown platform')