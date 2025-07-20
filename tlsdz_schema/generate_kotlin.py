import os
from pathlib import Path
from schema_model import BASIC_TYPES, COMPOSITE_TYPES, TYPE_NULLABLE, Schema, SchemaType

BASE_PACKAGE = "dev.deadzone.core.model"


def kotlin_type(schema_type: SchemaType) -> str:
    if schema_type.is_composite:
        if schema_type.name == "Map":
            k_type = kotlin_type(schema_type.children[0])
            v_type = kotlin_type(schema_type.children[1])
            return f"Map<{k_type}, {v_type}>"
        elif schema_type.name == "List":
            inner_type = kotlin_type(schema_type.children[0])
            return f"List<{inner_type}>"
    return schema_type.name


def find_imports(schema: Schema, input_dir: str):
    used_types = set()

    for field in schema.fields:
        def collect_types(schema_type):
            types = []
            if schema_type.name not in BASIC_TYPES and schema_type.name not in COMPOSITE_TYPES and schema_type.name != schema.name:
                types.append(schema_type.name)
            for child in schema_type.children:
                types.extend(collect_types(child))
            return types

        used_types.update(collect_types(field.type))

    import_lines = []
    for type_name in sorted(used_types):
        type_file = find_schema_file(type_name, input_dir)
        if type_file:
            import_rel_path = type_file.parent.relative_to(input_dir)
            import_parts = [BASE_PACKAGE] + [p.lower() for p in import_rel_path.parts] + [type_name]
            import_lines.append(f"import {'.'.join(import_parts)}")

    return import_lines


def find_schema_file(type_name: str, input_dir: str) -> Path | None:
    for root, _, files in os.walk(input_dir):
        for file in files:
            if file == f"{type_name}.txt":
                return Path(root) / file
    return None


def generate_kotlin(schema: Schema, file_path: Path, input_dir: str) -> str:
    rel_path = file_path.parent.relative_to(input_dir)
    package_parts = [BASE_PACKAGE] + [part.lower() for part in rel_path.parts]
    package_line = f"package {'.'.join(package_parts)}\n"

    lines = []
    lines.append(package_line)

    if schema.type == "data":
        lines.append("import kotlinx.serialization.Serializable")
        lines.extend(find_imports(schema, input_dir))
        lines.append("")
        lines.append("@Serializable")
        lines.append(f"data class {schema.name}(")

        field_lines = []
        for i, field in enumerate(schema.fields):
            type_str = kotlin_type(field.type)
            if field.type.enforcement == TYPE_NULLABLE:
                type_str += "?"

            default = ""
            stripped = field.default.strip() if field.default else None

            if stripped is not None:
                is_map = type_str.startswith("Map")
                is_list = type_str.startswith("List")
                is_byte_array = type_str == "ByteArray"
                is_uint = type_str == "UInt"

                if stripped == "{}":
                    default = " = mapOf()"
                elif stripped == "[]":
                    default = " = byteArrayOf()" if is_byte_array else " = listOf()"
                elif is_map and stripped.startswith("{") and stripped.endswith("}"):
                    entries = stripped[1:-1].strip()
                    if entries:
                        mapped = [
                            f"{k.strip()} to {v.strip()}"
                            for pair in entries.split(",") if ":" in pair
                            for k, v in [pair.split(":", 1)]
                        ]
                        default = f" = mapOf({', '.join(mapped)})"
                    else:
                        default = " = mapOf()"
                elif is_list and stripped.startswith("[") and stripped.endswith("]"):
                    items = stripped[1:-1].strip()
                    ctor = "byteArrayOf" if is_byte_array else "listOf"
                    default = f" = {ctor}({items})" if items else f" = {ctor}()"
                else:
                    if is_uint:
                        default = f" = {field.default}u"
                    else:
                        default = f" = {field.default}"

            field_line = f"    val {field.name}: {type_str}{default}"
            is_last = i == len(schema.fields) - 1

            if field.comment:
                comment = field.comment.strip().rstrip(',')
                field_lines.append(f"    {comment}")

            field_line = f"    val {field.name}: {type_str}{default}"
            if not is_last:
                field_line += ","
            field_lines.append(field_line)

        lines.append("\n".join(field_lines))
        lines.append(")\n")

    elif schema.type == "enum":
        field_type = kotlin_type(schema.fields[0].type)

        lines.append("import kotlinx.serialization.Serializable")
        lines.extend(find_imports(schema, input_dir))
        lines.append("")
        lines.append("@Serializable")
        lines.append("@JvmInline")
        lines.append(f"value class {schema.name}(val value: {field_type})\n")
        
        lines.append(f"object {schema.name}_Constants {{")
        for field in schema.fields:
            value = field.default or f'"{field.name}"'
            type_str = kotlin_type(field.type)

            if type_str == "UInt" and not value.endswith("u"):
                value += "u"

            lines.append(f"    val {field.name} = {schema.name}({value})")
        lines.append("}\n")

    return "\n".join(lines)
