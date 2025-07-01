
from flask import Flask, request, Response, send_from_directory
from flask_cors import CORS
from proto import auth_pb2
import logging
from logging.handlers import RotatingFileHandler

app = Flask(__name__)
CORS(app)
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s | %(name)-10s | %(levelname)-8s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
write_error_logger = logging.getLogger("write_error_logger")
if not write_error_logger.handlers:
    handler = RotatingFileHandler("write_error.log", maxBytes=1_000_000, backupCount=3)
    formatter = logging.Formatter(
        "%(asctime)s | %(name)-10s | %(levelname)-8s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )
    handler.setFormatter(formatter)
    write_error_logger.setLevel(logging.INFO)
    write_error_logger.addHandler(handler)
    write_error_logger.propagate = False


@app.route("/api/<int:RPCMethod>", methods=["POST"])
def handle_request(RPCMethod):
    request_data = request.get_data()
    app.logger.debug(f"\n{'=' * 45} [/api/{RPCMethod}] {'=' * 45}")
    app.logger.debug(f"Received data of len: {len(request_data)}")

    handlers = {
        13: authenticate,
        27: create_join_room,
        601: social_request,
        50: write_error,
    }

    handler = handlers.get(RPCMethod, default_handler)
    return handler(request_data) if RPCMethod in handlers else handler()


def authenticate(request_data):
    auth_input = auth_pb2.AuthenticateArgs()
    if not parse_request_args(request_data, auth_input):
        return Response("Parse error", status=400)

    response_msg = auth_pb2.AuthenticateOutput()

    response_msg.token = "mock-auth-token-123456"
    response_msg.userId = "user123"
    response_msg.showBranding = False
    response_msg.playerInsightState = ""
    response_msg.isSocialNetworkUser = False
    response_msg.isInstalledByPublishingNetwork = False
    response_msg.deprecated1 = False
    response_msg.apiSecurity = ""
    response_msg.apiServerHosts.extend(["127.0.0.1:5000"])

    return serialize_message(response_msg)


def create_join_room(request_data):
    create_join_room_input = auth_pb2.CreateJoinRoomArgs()
    if not parse_request_args(request_data, create_join_room_input):
        return Response("Parse error", status=400)

    response_msg = auth_pb2.CreateJoinRoomOutput()
    response_msg.roomId = "defaultRoomId"
    response_msg.joinKey = "defaultJoinKey"
    endpoint = response_msg.endpoints.add()
    endpoint.address = "127.0.0.1"
    endpoint.port = 7777

    return serialize_message(response_msg)


def social_request(_=None):
    response_msg = auth_pb2.SocialRefreshOutput()
    response_msg.myProfile.userId = "user123"
    response_msg.myProfile.displayName = "John Doe"
    response_msg.myProfile.avatarUrl = "http://example.com/avatar.png"
    response_msg.myProfile.lastOnline = 1622547800
    response_msg.myProfile.countryCode = "US"
    response_msg.myProfile.userToken = "user-token-1"

    return serialize_message(response_msg)


def write_error(request_data):
    write_error_input = auth_pb2.WriteErrorArgs()
    if not parse_request_args(request_data, write_error_input):
        return Response("Parse error", status=400)

    write_error_logger.info(write_error_input)

    # Server can send error to client if needed
    response_msg = auth_pb2.WriteErrorError()
    response_msg.message = "anErrorMessage"
    response_msg.errorCode = 400

    return serialize_message(response_msg)


def default_handler():
    return Response(b"\x00\x00\x00\x00", content_type="application/octet-stream")


def serialize_message(response_msg):
    serialized_data = response_msg.SerializeToString()
    response_data = bytearray()
    response_data.append(0)
    response_data.append(1)
    response_data.extend(serialized_data)

    return Response(bytes(response_data), content_type="application/octet-stream")


def parse_request_args(data, message_obj):
    try:
        message_obj.ParseFromString(data)
        app.logger.debug(f"Parsed args:\n\n{message_obj}")
        return True
    except Exception as e:
        app.logger.error(f"Args parsing failed:\n\n{str(e)}")
        return False


@app.route("/crossdomain.xml", methods=["GET"])
def crossdomain():
    return send_from_directory(app.static_folder, "crossdomain.xml")


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
