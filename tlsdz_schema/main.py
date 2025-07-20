import os
from pathlib import Path

from parser import parse_schema
from generate_kotlin import generate_kotlin
from generate_python import generate_python

INPUT_DIR = "schema"
OUTPUT_DIR_PY = "outpy"
OUTPUT_DIR_KT = "outkt"


def main(lang: str):
    for root, _, files in os.walk(INPUT_DIR):
        for file in files:
            if not file.endswith(".txt"):
                continue

            input_path = Path(root) / file

            with open(input_path, "r", encoding="utf-8") as f:
                raw_schema_text = f.read()

            schema = parse_schema(raw_schema_text)

            if lang == "py":
                generated_code = generate_python(schema, input_path, INPUT_DIR, "model")
            else:
                generated_code = generate_kotlin(schema, input_path, INPUT_DIR)

            ext = ".py" if lang == "py" else ".kt"
            output = OUTPUT_DIR_PY if lang == "py" else OUTPUT_DIR_KT

            output_path = Path(output) / input_path.relative_to(INPUT_DIR).with_suffix(ext)
            output_path.parent.mkdir(parents=True, exist_ok=True)

            with open(output_path, "w", encoding="utf-8") as f:
                f.write(generated_code)

    print(f"Code generation done")


if __name__ == "__main__":
    main("py")
