from flask import Flask, request, Response, send_from_directory
import auth_pb2

app = Flask(__name__)

@app.route('/api/<int:RPCMethod>', methods=['POST'])
def handle_request(RPCMethod):
    if RPCMethod == 13:
        response_msg = auth_pb2.AuthenticateOutput()
        response_msg.token = "abcdef123456"
        response_msg.userId = "user_12345"
        response_msg.showBranding = False
        response_msg.gameFSRedirectMap = ""
        response_msg.playerInsightState = ""
        response_msg.startDialogs = ""
        response_msg.isSocialNetworkUser = False
        response_msg.newPlayCodes = ""
        response_msg.notificationClickPayload = ""
        response_msg.isInstalledByPublishingNetwork = True
        response_msg.deprecated1 = ""
        response_msg.apiSecurity = ""
        response_msg.apiServerHosts = ""

        serialized_data = response_msg.SerializeToString()

        print(f"Serialized data length: {len(serialized_data)}")
        print(f"Serialized data (hex): {serialized_data.hex()}")

        response_data = bytearray()
        response_data.append(0)
        response_data.append(1)
        response_data.extend(serialized_data)

        print(f"Full response (hex): {bytes(response_data).hex()}")

        return Response(bytes(response_data), content_type="application/octet-stream")

    return Response(b"\x00\x00\x00\x00", content_type="application/octet-stream")

@app.route('/crossdomain.xml', methods=['GET'])
def crossdomain():
    return send_from_directory(app.static_folder, 'crossdomain.xml')

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)