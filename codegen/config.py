import sys
from termcolor import colored
import yaml
import os.path as path
from enum import Enum, auto

class ConfigField(Enum):
    definition_ext = auto()
    definition_search_path = auto()
    dart_output_path = auto()
    c_output_path = auto()
    use_cloc = auto()
    cloc_exclude_list_path = auto()

DEFAULTS = {
    ConfigField.definition_ext: ".gen",
    ConfigField.definition_search_path: "native",
    ConfigField.dart_output_path: "bin/dart_codegen.dart",
    ConfigField.c_output_path: "native/c_codegen.h",
    ConfigField.use_cloc: True,
    ConfigField.cloc_exclude_list_path: ".cloc_exclude_list.txt",
}

CONFIG_FNAME = 'codegen.yaml'

def panic(msg: str):
    print(colored(f'CONFIG ERROR: {msg}'), 'red')
    sys.exit()

def get_config(key: ConfigField) -> str:
    if path.exists(CONFIG_FNAME):
        with open(CONFIG_FNAME, 'rt') as fh:
            values = yaml.safe_load(fh)
        if key.name in values:
            return values[key.name]
    
    if key in DEFAULTS: return str(DEFAULTS[key])

    panic(f'Key {key} not found in values file or DEFAULTS')