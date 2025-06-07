from flask import Flask, request, Response, send_file, send_from_directory
import logging
from flask_cors import CORS

logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__, static_folder="static", static_url_path="/")
cors_app = CORS(app)

@app.route("/r/<path:filename>")
def serve_files(filename=""):
    return send_from_directory("r", filename)


if __name__ == "__main__":
    app.run("127.0.0.1", 80, True)
