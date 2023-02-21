import sys
from termcolor import colored
import yaml
import os.path as path
from enum import Enum, auto
from platform import system
from typing import Optional

class ConfigField(Enum):
    definition_ext = auto()
    definition_search_path = auto()
    dart_output_path = auto()
    c_output_path = auto()
    use_cloc = auto()
    cloc_exclude_list_path = auto()
    cloc_path = auto()
    objects_def_path = auto()
    objects_output_path = auto()

DEFAULTS = {
    ConfigField.definition_ext: ".gen",
    ConfigField.definition_search_path: "native",
    ConfigField.dart_output_path: "bin/dart_codegen.dart",
    ConfigField.c_output_path: "native/c_codegen.h",
    ConfigField.use_cloc: True,
    ConfigField.cloc_exclude_list_path: ".cloc_exclude_list.txt",
    ConfigField.cloc_path: "cloc",
    ConfigField.objects_def_path: 'objects.yaml',
    ConfigField.objects_output_path: 'bin/objects.dart'
}

def panic(msg: str):
    print(colored(f'CONFIG ERROR: {msg}'), 'red')
    return sys.exit()

def get_config(key: ConfigField) -> str:
    global_fname = 'codegen.yaml'
    system_fname = f'codegen.{system().lower()}.yaml'

    fname = None
    if path.exists(global_fname): fname = global_fname
    elif path.exists(system_fname): fname = system_fname
    if fname is not None:
        with open(fname, 'rt') as fh:
            values = yaml.safe_load(fh)
        if key.name in values:
            return values[key.name]
    
    if key in DEFAULTS: return str(DEFAULTS[key])

    panic(f'Key {key} not found in values file or DEFAULTS')