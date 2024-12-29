import os
from http.server import SimpleHTTPRequestHandler, HTTPServer

def load_crossdomain_file():
    crossdomain_path = os.path.join(os.path.dirname(__file__), "crossdomain.xml")
    if not os.path.exists(crossdomain_path):
        raise FileNotFoundError(f"The file {crossdomain_path} is required and missing.")
    with open(crossdomain_path, "r", encoding="utf-8") as file:
        return file.read()

class MyHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/crossdomain.xml":
            crossdomain_content = load_crossdomain_file()
            self.send_response(200)
            self.send_header("Content-type", "application/xml")
            self.end_headers()
            self.wfile.write(crossdomain_content.encode('utf-8'))
        elif self.path == "/418":
            self.send_response(418)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b"I'm a teapot: Short and stout!")
        else:
            super().do_GET()

    def do_POST(self):
        if self.path == "/418":
            self.send_response(418)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b"I'm a teapot: Short and stout! (POST method)")
        else:
            self.send_response(405)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Method Not Allowed")

HOST = '127.0.0.1'
PORT = 8000
server_address = (HOST, PORT)

httpd = HTTPServer(server_address, MyHandler)
print(f"Server listening on http://{HOST}:{PORT}")
httpd.serve_forever()