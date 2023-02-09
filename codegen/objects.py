import yaml
from config import *
from dataclasses import dataclass

@dataclass
class BeansObjectDef:
    serializableInfo: dict[str, str]
    methods: dict[str, dict[str, str]]

def codegen() -> str:
    with open(get_config(ConfigField.objects_def_path), 'rt') as fh:
        contents = yaml.safe_load(fh)
    imports: list[str] = []
    objects: dict[str, BeansObjectDef] = {}

    print(contents)

    for objectName, object in contents.items():
        serializableInfo: dict[str, str] = object['serializableInfo']
        for memberName, type in serializableInfo.items():
            if '@' in type:
                serializableInfo[memberName] = type.split('@')[0]
                imports.append(type.split('@')[1])

        objects[objectName] = BeansObjectDef(serializableInfo, object['methods'])


    out = ''
    for import_ in imports:
        out += f"import '{import_}';\n"
    
    if imports != []: out += '\n'

    for objectName, object in objects.items():
        out += f'class {objectName}Info {{\n'
        for memberName, type in object.serializableInfo.items():
            out += f'    final {type} {memberName};\n'
        out += '\n'
        out += f'    {objectName}Info('
        for memberName in object.serializableInfo.keys():
            out += f'this.{memberName}'
            if memberName != list(object.serializableInfo.keys())[-1]:
                out += ', '
        out += ');\n\n'

        out += f'    static {objectName}Info fromJson(Map<String, dynamic> json) => {objectName}Info(\n'
        for memberName, type in object.serializableInfo.items():
            out += f"        json['{memberName}'] as {type}"
            if memberName != list(object.serializableInfo.keys())[-1]:
                out += ','
            out += '\n'
        out += '    );\n\n'

        out += '    Map<String, dynamic> toJson() => {\n'
        for memberName, type in object.serializableInfo.items():
            out += f"        '{memberName}': {memberName}"
            if memberName != list(object.serializableInfo.keys())[-1]:
                out += ','
            out += '\n'
        out += '    };\n}\n\n'

        out += f'abstract class {objectName}Base {{\n'
        for methodName, params in object.methods.items():
            out += f'    void {methodName}('
            for paramName, type in params.items():
                out += f'{type} {paramName}'
                if paramName != list(params.keys())[-1]:
                    out += ', '
            out += ');\n'
        out += '}\n\n'

    return out
