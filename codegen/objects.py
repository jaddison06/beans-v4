import yaml
from config import *
from dataclasses import dataclass
from banner import *

@dataclass
class BeansObjectDef:
    serializableInfo: dict[str, str]
    methods: dict[str, dict[str, str]]
    key: str
    ctrl: bool
    alt: bool

def codegen() -> str:
    with open(get_config(ConfigField.objects_def_path), 'rt') as fh:
        contents = yaml.safe_load(fh)
    imports: list[str] = ['core/Engine.dart', 'ui/EventPoller.dart', 'dart_codegen.dart', 'core/CommandLine.dart', 'core/BeansObject.dart']
    objects: dict[str, BeansObjectDef] = {}

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

        objects[objectName] = BeansObjectDef(serializableInfo, object['methods'], object['key'], ctrl, alt)


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
    bool isProc(List<CommandLineToken> current) {
        
    }
}
'''

    return out
