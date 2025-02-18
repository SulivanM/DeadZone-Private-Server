import socket
import threading

class GameServer:
    def __init__(self, host="127.0.0.1", port=8000):
        self.server_address = (host, port)
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.running = True

    def start(self):
        self.server_socket.bind(self.server_address)
        self.server_socket.listen(5)
        print(f"Server started on {self.server_address[0]}:{self.server_address[1]}")

        try:
            while self.running:
                client_socket, client_address = self.server_socket.accept()
                print(f"New connection from {client_address}")
                threading.Thread(target=self.handle_client, args=(client_socket,)).start()
        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.stop()

    def handle_client(self, client_socket):
        try:
            while True:
                data = client_socket.recv(4096)
                if not data:
                    break

                print(f"Received: {data}")
                print(f"Received (Hex): {data.hex()}")

                if data.startswith(b'<policy-file-request/>\x00'):
                    print("Policy file request received")
                    response = b"<cross-domain-policy><allow-access-from domain='*' to-ports='*' /></cross-domain-policy>"
                    client_socket.sendall(response)
                    print("Policy file response sent")
        except ConnectionResetError:
            print("Connection reset by client")
        except Exception as e:
            print(f"Error handling client: {e}")
        finally:
            client_socket.close()
            print("Client disconnected")

    def stop(self):
        self.running = False
        self.server_socket.close()
        print("Server stopped")

if __name__ == "__main__":
    server = GameServer()
    try:
        server.start()
    except KeyboardInterrupt:
        print("Shutting down server...")
        server.stop()
