from flask import Flask, request, Response
from handlers.rpc_handler import process_request
from handlers.error_handler import create_error_response
import logging
import struct

app = Flask(__name__)

logging.basicConfig(
    level=logging.DEBUG, format="\033[92m[%(levelname)s]\033[0m %(message)s"
)


@app.route("/crossdomain.xml", methods=["GET"])
def crossdomain():
    xml_content = """
    <cross-domain-policy>
        <allow-access-from domain="*" />
        <allow-http-request-headers-from domain="*" headers="*"/>
    </cross-domain-policy>
    """
    return Response(xml_content, mimetype="application/xml")


@app.route("/api/<int:rpc_method>", methods=["POST", "GET", "OPTIONS"])
def api_handler(rpc_method):
    if request.method == "OPTIONS":
        response = app.make_default_options_response()
        response.headers.add(
            "Access-Control-Allow-Headers", "Content-Type,Authorization"
        )
        response.headers.add("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
        return response

    data = request.get_data() if request.method == "POST" else b""

    logging.info(f"RPC Method: {rpc_method}")
    logging.info(f"Data (hex): {data.hex()}")
    try:
        logging.info(f"Data (str): {data.decode('utf-8', errors='replace')}")
    except Exception as e:
        logging.error(f"Error decoding data: {e}")

    token = request.headers.get("playertoken")
    if not validate_token(token):
        return Response(status=401)

    try:
        response_data = process_request(rpc_method, data)
    except Exception as e:
        logging.error(f"Error processing request: {e}")
        response_data = create_error_response(str(e))

    response_data = b"\x00" + response_data

    logging.info(f"Sending response (hex): {response_data.hex()}")

    return response_data, 200, {"Content-Type": "application/octet-stream"}


def validate_token(token):
    return True


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
