from pathlib import Path
from typing import List, Set
from schema_model import BASIC_TYPES, COMPOSITE_TYPES, Schema, SchemaType, TYPE_NULLABLE
import os


def get_python_type(schema_type: SchemaType) -> str:
    if schema_type.name == "Map" and len(schema_type.children) == 2:
        key_type = get_python_type(schema_type.children[0])
        value_type = get_python_type(schema_type.children[1])
        return f"Dict[{key_type}, {value_type}]"
    elif schema_type.name == "List" and schema_type.children:
        item_type = get_python_type(schema_type.children[0])
        return f"List[{item_type}]"
    elif schema_type.name == "ByteArray":
        return "bytes"
    elif schema_type.name in BASIC_TYPES:
        mapping = {
            'String': 'str',
            'Int': 'int',
            'UInt': 'int',
            'Double': 'float',
            'Float': 'float',
            'Boolean': 'bool',
            'Long': 'int',
            'Short': 'int',
            'Byte': 'int',
            'Char': 'str',
            'Any': 'Any',
        }
        return mapping[schema_type.name]
    else:
        return schema_type.name


def collect_used_types(schema: Schema) -> Set[str]:
    used_types = set()

    def collect_types(schema_type: SchemaType):
        types = []
        if (
            schema_type.name not in BASIC_TYPES
            and schema_type.name not in COMPOSITE_TYPES
            and schema_type.name != schema.name
        ):
            types.append(schema_type.name)
        for child in schema_type.children:
            types.extend(collect_types(child))
        return types

    for field in schema.fields:
        used_types.update(collect_types(field.type))

    return used_types


def find_schema_file(type_name: str, input_dir: str) -> Path | None:
    for root, _, files in os.walk(input_dir):
        for file in files:
            if file == f"{type_name}.txt":
                return Path(root) / file
    return None


def find_imports(schema: Schema, input_dir: str, out_dir: str) -> List[str]:
    used_types = collect_used_types(schema)
    import_lines = []

    for type_name in sorted(used_types):
        type_file = find_schema_file(type_name, input_dir)
        if type_file:
            import_rel_path = type_file.parent.relative_to(input_dir)
            import_parts = [p for p in import_rel_path.parts] + [type_name]
            import_line = f"from {out_dir}.{'.'.join(import_parts)} import {type_name}"
            import_lines.append(import_line)

    return import_lines


def generate_python(schema: Schema, file_path: Path, input_dir: str, out_dir: str = "") -> str:
    rel_path = file_path.parent.relative_to(input_dir)
    typing_imports = set()
    lines: List[str] = []

    # Imports
    used_types = collect_used_types(schema)
    import_lines = find_imports(schema, input_dir, out_dir)

    for field in schema.fields:
        py_type = get_python_type(field.type)
        if "List[" in py_type:
            typing_imports.add("List")
        if "Dict[" in py_type:
            typing_imports.add("Dict")
        if "Any" in py_type:
            typing_imports.add("Any")
        if field.type.enforcement == TYPE_NULLABLE:
            typing_imports.add("Optional")

    # Header
    lines.append("from dataclasses import dataclass, field")
    if typing_imports:
        lines.append(f"from typing import {', '.join(sorted(typing_imports))}")
    lines.extend(import_lines)
    lines.append("")
    lines.append(f"# Module: {rel_path.as_posix() if rel_path.parts else 'root'}")
    lines.append("@dataclass")
    lines.append(f"class {schema.name}:")

    # Separate fields
    required_fields = []
    default_fields = []

    for field in schema.fields:
        py_type = get_python_type(field.type)
        is_nullable = field.type.enforcement == TYPE_NULLABLE

        if is_nullable:
            py_type = f"Optional[{py_type}]"

        default = None
        if field.default is not None:
            stripped = field.default.strip()
            if stripped == "{}":
                default = "field(default_factory=dict)"
            elif stripped == "[]":
                default = "field(default_factory=list)"
            elif stripped.lower() in {"true", "false"} and field.type.name == "Boolean":
                default = stripped.capitalize()
            elif field.type.name == "String":
                default = f'{stripped}'
            elif stripped.lower() == "null":
                default = "None"
            else:
                default = stripped
        elif field.type.name == "Map":
            default = "field(default_factory=dict)"
        elif field.type.name in {"List", "ByteArray"}:
            default = "field(default_factory=list)"
        elif is_nullable:
            default = "None"

        line = f"    {field.name}: {py_type}"
        if default is not None:
            if default.startswith("field("):
                line += f" = {default}"
            else:
                line += f" = {default}"
            default_fields.append(line)
        else:
            required_fields.append(line)


    if not required_fields and not default_fields:
        lines.append("    pass")
    else:
        lines.extend(required_fields + default_fields)

    return "\n".join(lines) + "\n"
