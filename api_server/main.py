from flask import Flask, request, Response, send_from_directory
from proto import auth_pb2
import logging
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
logging.basicConfig(level=logging.DEBUG)


def default_message():
    return Response(b"\x00\x00\x00\x00", content_type="application/octet-stream")


def serialize_message(response_msg):
    serialized_data = response_msg.SerializeToString()
    response_data = bytearray()
    response_data.append(0)
    response_data.append(1)
    response_data.extend(serialized_data)
    return Response(bytes(response_data), content_type="application/octet-stream")


def social_request():
    request_data = request.get_data()
    app.logger.debug(f"Raw request data: {request_data}")
    app.logger.debug(f"Request data length: {len(request_data)}")

    response_msg = auth_pb2.SocialRefreshOutput()

    response_msg.myProfile.userId = "user123"
    response_msg.myProfile.displayName = "John Doe"
    response_msg.myProfile.avatarUrl = "http://example.com/avatar.png"
    response_msg.myProfile.lastOnline = 1622547800
    response_msg.myProfile.countryCode = "US"
    response_msg.myProfile.userToken = "user-token-1"

    return serialize_message(response_msg)


@app.route("/api/<int:RPCMethod>", methods=["POST"])
def handle_request(RPCMethod):
    if RPCMethod == 13:
        request_data = request.get_data()
        app.logger.debug(f"Raw request data: {request_data}")
        app.logger.debug(f"Request data length: {len(request_data)}")

        if len(request_data) == 0:
            app.logger.error("Request data is empty, cannot parse")
            return Response("Invalid request data", status=400)

        auth_input = auth_pb2.AuthenticateArgs()
        try:
            auth_input.ParseFromString(request_data)
            app.logger.debug(
                f"Parsed gameId: {auth_input.gameId}, userId: {auth_input.userId}"
            )
        except Exception as e:
            app.logger.error(f"Failed to parse AuthenticateArgs: {str(e)}")
            return Response(f"Parse error: {str(e)}", status=400)

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

        serialized_data = response_msg.SerializeToString()
        response_data = bytearray()
        response_data.append(0)
        response_data.append(1)
        response_data.extend(serialized_data)

        return Response(bytes(response_data), content_type="application/octet-stream")
    elif RPCMethod == 27:
        response_msg = auth_pb2.CreateJoinRoomOutput()
        response_msg.roomId = "defaultRoomId"
        response_msg.joinKey = "defaultJoinKey"
        endpoint = response_msg.endpoints.add()
        endpoint.address = "127.0.0.1"
        endpoint.port = 7777

        serialized_data = response_msg.SerializeToString()
        response_data = bytearray()
        response_data.append(0)
        response_data.append(1)
        response_data.extend(serialized_data)

        return Response(bytes(response_data), content_type="application/octet-stream")
    elif RPCMethod == 601:
        return social_request()

    return Response(b"\x00\x00\x00\x00", content_type="application/octet-stream")


@app.route("/crossdomain.xml", methods=["GET"])
def crossdomain():
    return send_from_directory(app.static_folder, "crossdomain.xml")


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
