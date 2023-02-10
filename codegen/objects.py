import yaml
from config import *
from dataclasses import dataclass
from enum import Enum, auto
from banner import *

@dataclass
class BeansObjectDef:
    serializableInfo: dict[str, str]
    methods: dict[str, dict[str, str]]
    text: str
    ctrl: bool
    alt: bool


class BCLTokenType(Enum):
    text = auto()
    key = auto()

@dataclass
class BeansProcedure:
    tokenType: BCLTokenType
    token: str

def codegen() -> str:
    with open(get_config(ConfigField.objects_def_path), 'rt') as fh:
        contents = yaml.safe_load(fh)
    imports: list[str] = ['core/Engine.dart', 'ui/EventPoller.dart', 'dart_codegen.dart', 'core/BeansCommandLine.dart', 'core/BeansObject.dart']
    objects: dict[str, BeansObjectDef] = {}
    procedures: dict[str, BeansProcedure] = {}

    for objectName, object in contents['objects'].items():
        serializableInfo: dict[str, str] = object['serializableInfo']
        for memberName, type in serializableInfo.items():
            if '@' in type:
                serializableInfo[memberName] = type.split('@')[0]
                dartFile = type.split('@')[1]
                if dartFile not in imports:
                    imports.append(dartFile)

        if 'modifiers' in object:
            modifiers: dict[str, bool] = object['modifiers']
            ctrl = modifiers.get('ctrl', False)
            alt = modifiers.get('alt', False)
        else:
            ctrl = alt = False

        objects[objectName] = BeansObjectDef(serializableInfo, object['methods'], object['text'], ctrl, alt)

    for procName, proc in contents['procedures'].items():
        if 'key' in proc:
            procedures[procName] = BeansProcedure(BCLTokenType.key, proc['key'])
        elif 'text' in proc:
            procedures[procName] = BeansProcedure(BCLTokenType.text, proc['text'])
        else:
            raise ValueError("Need 'key' or 'text' in procedure!")

    out = banner('generated file - do not edit!')
    for import_ in imports:
        out += f"import '{import_}';\n"
    
    out += '\n'

    for objectName, object in objects.items():
        out += f'class {objectName}Info extends Serializable {{\n'
        for memberName, type in object.serializableInfo.items():
            out += f'    final {type} {memberName};\n'
        out += '\n'
        out += f'    {objectName}Info.fromValues('
        for memberName in object.serializableInfo.keys():
            out += f'this.{memberName}'
            if memberName != list(object.serializableInfo.keys())[-1]:
                out += ', '
        out += ') : super({});\n\n'

        out += f'    {objectName}Info(Map<String, dynamic> json) :\n'
        for memberName, type in object.serializableInfo.items():
            out += f"        {memberName} = json['{memberName}'] as {type},\n"
        out += '        super(json);\n\n'

        out += '    @override\n'
        out += '    Map<String, dynamic> toJson() => {\n'
        for memberName, type in object.serializableInfo.items():
            out += f"        '{memberName}': {memberName}"
            if memberName != list(object.serializableInfo.keys())[-1]:
                out += ','
            out += '\n'
        out += '    };\n}\n\n'

        out += f'abstract class {objectName}Base extends BeansObject<{objectName}Info> {{\n'
        out += f'    {objectName}Base({objectName}Info info) : super(info);\n\n'
        for methodName, params in object.methods.items():
            out += f'    void {methodName}('
            for paramName, type in params.items():
                out += f'{type} {paramName}'
                if paramName != list(params.keys())[-1]:
                    out += ', '
            out += ');\n'
        out += '}\n\n'
    
    out += \
'''mixin CommandLineBase {
    bool isProc(BCLToken current) {
        if (current.type == BCLTokenType.Key && (
'''
    for procName, proc in procedures.items():
        if proc.tokenType == BCLTokenType.key:
            out += f'            current.key == Key.{proc.token} ||\n'
    out = out[:-4]
    out += '\n        )) { return true; }\n\n'

    out += '        else if (current.type == BCLTokenType.Text && (\n'
    for procName, proc in procedures.items():
        if proc.tokenType == BCLTokenType.text:
            out += f"            current.text == '{proc.token}' ||\n"
    out = out[:-4]
    out += '\n        )) { return true; }\n\n'

    out += '        return false;\n'

    out += '    }\n\n'

    out += '    bool isObject(BCLToken current) {\n'
    # currently operating under the assumption that all objects are text (!)
    out += '        if (current.type == BCLTokenType.Text && (\n'
    for objectName, object in objects.items():
        out += f"            (current.text == '{object.text}' && current.modifiers.control == {str(object.ctrl).lower()} && current.modifiers.alt == {str(object.alt).lower()}) ||\n"
    out = out[:-4]
    out += '\n        )) { return true; }\n\n'
    out += '        return false;\n    }\n'


    out += '}'


    return out
