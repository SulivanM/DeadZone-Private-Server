from flask import Flask, request, Response, send_from_directory
import auth_pb2

app = Flask(__name__)

@app.route('/api/<int:RPCMethod>', methods=['POST'])
def handle_request(RPCMethod):
    if RPCMethod == 13:
        response_msg = auth_pb2.AuthenticateOutput()
        response_msg.success = 1
        response_msg.token = "abcdef123456"
        response_msg.userId = "user_12345"
        
        response_data = response_msg.SerializeToString()
        
        return Response(response_data, content_type="application/octet-stream")

    return Response(b"\x00\x00\x00\x00", content_type="application/octet-stream")

@app.route('/crossdomain.xml', methods=['GET'])
def crossdomain():
    return send_from_directory(app.static_folder, 'crossdomain.xml')

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)
