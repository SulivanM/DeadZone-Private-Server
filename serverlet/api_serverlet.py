from flask import Flask, request, Response, send_from_directory
import auth_pb2
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.DEBUG)

@app.route('/api/<int:RPCMethod>', methods=['POST'])
def handle_request(RPCMethod):
    if RPCMethod == 418:
        response_msg = auth_pb2.FacebookOAuthConnectOutput()
        response_msg.token = ""
        response_msg.userId = ""
        response_msg.showBranding = False
        response_msg.gameFSRedirectMap = "cdnmap|http://localhost:8000"
        response_msg.facebookUserId = ""
        response_msg.partnerId = ""
        response_msg.playerInsightState = ""

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

    return Response(b"\x00\x00\x00\x00", content_type="application/octet-stream")

@app.route('/crossdomain.xml', methods=['GET'])
def crossdomain():
    return send_from_directory(app.static_folder, 'crossdomain.xml')

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)