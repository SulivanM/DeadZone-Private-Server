from flask import Flask, request, Response, send_file, send_from_directory
import logging
from flask_cors import CORS

logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__, static_folder="static", static_url_path="/")
cors_app = CORS(app)


@app.route("/")
def index():
    return send_file("index.html")


@app.route("/game/preloader.swf")
def preloader_swf():
    return send_file("static/preloader.swf")


@app.route("/null/game/<path:filename>")
def serve_files(filename=""):
    return send_from_directory("static", filename)


@app.route("/game/<path:filename>")
def serve_files_1(filename=""):
    return send_from_directory("static", filename)


@app.route("/null/game/core.swf")
def preloader_swf_1():
    return send_file("static/core.swf")


if __name__ == "__main__":
    app.run("127.0.0.1", 8000, True)
