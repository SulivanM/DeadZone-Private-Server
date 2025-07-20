from typing import List


BASIC_TYPES = {'String', 'Int', "UInt", 'Double', 'Float', 'Boolean', 'Long', 'Short', 'Byte', 'Char', 'Any', 'ByteArray'}
COMPOSITE_TYPES = {'List', 'Map'}
TYPE_NULLABLE = "?"
TYPE_REQUIRED = "!"
TYPE_NONE_DEFAULT = ""


class Schema():
    def __init__(self):
        self.type = ""
        self.name = ""
        self.fields = []

    def __repr__(self):
        fields_str = ",\n".join(field.__repr__(6) for field in self.fields)
        return f"Schema(type={self.type}, name={self.name},\n  fields=[\n{fields_str}\n  ])"


class SchemaType:
    def __init__(self, name: str = "", enforcement: str = TYPE_NONE_DEFAULT, is_composite: bool = False, children: List['SchemaType'] = None):
        self.name = name
        self.enforcement = enforcement
        self.is_composite = is_composite
        self.children = children or []

    def __repr__(self, indent=0):
        ind = ' ' * indent
        next_ind = ' ' * (indent + 2)
        repr_str = f"{ind}SchemaType(name={self.name}, enforcement={self.enforcement}, is_composite={self.is_composite}"
        if self.children:
            child_reprs = ",\n".join(child.__repr__(indent + 4) for child in self.children)
            repr_str += f",\n{next_ind}children=[\n{child_reprs}\n{next_ind}]"
        else:
            repr_str += f", children=[]"
        return repr_str + ")"


class SchemaField():
    def __init__(self, name: str, schema_type: SchemaType, raw_type: str, default: any = None, pending_comment: str = None):
        self.name = name
        self.type = schema_type
        self.raw_type = raw_type
        self.default = default
        self.comment = pending_comment

    def __repr__(self, indent=4):
        ind = ' ' * indent
        type_repr = self.type.__repr__(indent + 2)
        return (
            f"{ind}SchemaField(name={self.name},\n"
            f"{type_repr},\n"
            f"{ind}  raw_type={self.raw_type}, default={self.default}, comment={self.comment})"
        )
