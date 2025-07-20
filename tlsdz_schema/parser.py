import re
from schema_model import TYPE_NONE_DEFAULT, TYPE_NULLABLE, TYPE_REQUIRED, Schema, SchemaField, SchemaType


def parse_schema(txt: str) -> Schema:
    lines = txt.split("\n")

    schema = Schema()
    schema_title = lines[0].strip()
    schema.type = schema_title.split(" ", 1)[0].strip()
    schema.name = schema_title.split(" ", 1)[1].strip()

    pending_comment = None

    for i, line in enumerate(lines[1:], start=2):
        line = line.strip()

        # empty line
        if not line:
            pending_comment = None
            continue

        # comment line
        if line.startswith("//"):
            pending_comment = line
            continue

        # extract comment part, preserving even the spaces
        if '//' in line:
            line_content, comment = line.split('//', 1)
            line = line_content.strip()
            pending_comment = f"// {comment.strip()}"
        else:
            pending_comment = None

        valid_definition = r'^(\w+):\s*([\w<>, ?!]+)(?:\s*=\s*(.+))?$'
        match = re.match(valid_definition, line)

        if not match:
            print(f"[WARN] Invalid field definition at line {i} in schema '{schema.name}': {line}")
            pending_comment = None
            continue

        field_name, type_name, default_value = match.groups()
        schema_type = parse_type(type_name.strip())
        default_value = default_value.strip() if default_value else None

        field = SchemaField(field_name, schema_type, type_name.strip(), default_value, pending_comment)
        schema.fields.append(field)

        pending_comment = None

    return schema


def parse_type(type_name: str) -> SchemaType:
    """
    Parses a schema type like `Type!`, `Type?`, `List<Type>?`, `Map<K, V>!`
    and returns a structured `[SchemaType]` with child types if applicable.
    """
    enforcement = TYPE_NONE_DEFAULT
    if type_name.endswith("?"):
        enforcement = TYPE_NULLABLE
        type_name = type_name[:-1].strip()
    elif type_name.endswith("!"):
        enforcement = TYPE_REQUIRED
        type_name = type_name[:-1].strip()

    list_match = re.match(r'^List<(.+)>$', type_name)
    map_match = re.match(r'^Map<([^,]+),\s*(.+)>$', type_name)

    if list_match:
        child_type_str = list_match.group(1).strip()
        child_type = parse_type(child_type_str)
        return SchemaType(name="List", enforcement=enforcement, is_composite=True, children=[child_type])

    elif map_match:
        key_type_str = map_match.group(1).strip()
        val_type_str = map_match.group(2).strip()
        key_type = parse_type(key_type_str)
        val_type = parse_type(val_type_str)
        return SchemaType(name="Map", enforcement=enforcement, is_composite=True, children=[key_type, val_type])

    return SchemaType(name=type_name, enforcement=enforcement, is_composite=False)
