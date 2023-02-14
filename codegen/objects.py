import yaml
from config import *
from dataclasses import dataclass
from enum import Enum, auto
from banner import *
from typing import Any

class BCLTokenType(Enum):
    Text = auto()
    Key = auto()

@dataclass
class BCLToken:
    type: BCLTokenType
    tok: str
    ctrl: bool
    alt: bool

    @classmethod
    def fromJson(cls, json: dict[str, Any]) -> 'BCLToken':
        if 'modifiers' in json:
            ctrl: bool = json['modifiers'].get('ctrl', False)
            alt: bool = json['modifiers'].get('alt', False)
        else:
            ctrl = alt = False
        
        if 'key' in json:
            return BCLToken(BCLTokenType.Key, json['key'], ctrl, alt)
        elif 'text' in json:
            return BCLToken(BCLTokenType.Text, json['text'], ctrl, alt)
        else:
            raise ValueError("Need 'key' or 'text' in procedure!")
    
    def dartInitializer(self) -> str:
        match self.type:
            case BCLTokenType.Key:
                key = f"Key.{self.tok}"
                text = 'null'
            case BCLTokenType.Text:
                key = 'null'
                text = f"'{self.tok}'"
        return f'BCLToken({self.type}, {key}, {text}, Modifiers(shift: false, control: {str(self.ctrl).lower()}, alt: {str(self.alt).lower()}, caps: false))'

@dataclass
class BCLMethodDef:
    token: BCLToken
    params: dict[str, str]

@dataclass
class BCLObjectDef:
    serializableInfo: dict[str, str]
    methods: dict[str, BCLMethodDef]
    token: BCLToken

@dataclass
class BCLProcDef:
    token: BCLToken

def codegen() -> str:
    with open(get_config(ConfigField.objects_def_path), 'rt') as fh:
        contents = yaml.safe_load(fh)
    imports: list[str] = ['core/Engine.dart', 'ui/EventPoller.dart', 'dart_codegen.dart', 'core/BeansCommandLine.dart', 'core/BeansObject.dart']
    objects: dict[str, BCLObjectDef] = {}
    procedures: dict[str, BCLProcDef] = {}

    for objectName, object in contents['objects'].items():
        serializableInfo: dict[str, str] = object['serializableInfo']
        for memberName, type in serializableInfo.items():
            if '@' in type:
                serializableInfo[memberName] = type.split('@')[0]
                dartFile = type.split('@')[1]
                if dartFile not in imports:
                    imports.append(dartFile)

        methods: dict[str, BCLMethodDef] = {}
        for methodName, method in object['methods'].items():
            methods[methodName] = BCLMethodDef(BCLToken.fromJson(method), method['params'])

        objects[objectName] = BCLObjectDef(serializableInfo, methods, BCLToken.fromJson(object))

    for procName, proc in contents['procedures'].items():
        procedures[procName] = BCLProcDef(BCLToken.fromJson(proc))

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
        for methodName, method in object.methods.items():
            out += f'    void {methodName}('
            for paramName, type in method.params.items():
                out += f'{type} {paramName}'
                if paramName != list(method.params.keys())[-1]:
                    out += ', '
            out += ');\n'
        out += '}\n\n'
    
    out += 'mixin CommandLineBase {\n'

    out += '    final Map<BCLToken, BCLProc> procedures = {\n'
    for procName, proc in procedures.items():
        out += f"        {proc.token.dartInitializer()}: BCLProc('{procName}'),\n"
    out = out[:-2]
    out += '\n    };\n\n'

    dart_type_to_param_type = {'int': 'Int'}
    
    out += '    final Map<BCLToken, BCLObj> objects = {\n'
    for objName, obj in objects.items():
        out += f"        {obj.token.dartInitializer()}: BCLObj('{objName}', {{\n"
        for methodName, method in obj.methods.items():
            out += f"            {method.token.dartInitializer()}: BCLMethod('{methodName}', [\n"
            for paramType in method.params.values():
                out += '                BCLMethodParam('
                if paramType in objects:
                    out += f'BCLMethodParamType.Object, {objects[paramType].token.dartInitializer()})'
                else:
                    out += f'BCLMethodParamType.{dart_type_to_param_type[paramType]})'
                out += ',\n'
            out = out[:-2]
            out += '\n            ]),\n'

        out = out[:-2]
        out += '\n        }),\n'
    
    out = out[:-2]
    out += '\n    };\n'

    out += '}'

    return out
