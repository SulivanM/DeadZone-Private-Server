import socket
import threading
import logging
import msgpack

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("EndpointServer")

CROSS_DOMAIN_POLICY = (
    "<cross-domain-policy>"
    '<allow-access-from domain="*" to-ports="7777"/>'
    "</cross-domain-policy>\x00"
).encode("utf-8")


class EndpointServer:
    def __init__(self, host="127.0.0.1", port=7777):
        self.host = host
        self.port = port
        self.server_socket = None
        self.running = False

    def start(self):
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(5)
            self.running = True
            logger.info(f"Server started on {self.host}:{self.port}")
            threading.Thread(target=self.accept_loop, daemon=True).start()
        except Exception as e:
            logger.error(f"Error starting server: {e}")
            self.stop()

    def accept_loop(self):
        while self.running:
            try:
                client_socket, client_address = self.server_socket.accept()
                logger.info(f"New connection from {client_address}")
                threading.Thread(target=self.handle_client, args=(client_socket, client_address), daemon=True).start()
            except Exception as e:
                logger.error(f"Error accepting connection: {e}")

    def handle_client(self, sock, addr):
        unpacker = msgpack.Unpacker(raw=False)
        try:
            while True:
                data = sock.recv(4096)
                if not data:
                    break
                logger.info(f"Data received from {addr}: {data}")

                if data.startswith(b"<policy-file-request/>"):
                    sock.sendall(CROSS_DOMAIN_POLICY)
                    logger.info(f"Sent cross-domain policy to {addr}")
                    break

                unpacker.feed(data)
                for obj in unpacker:
                    logger.info(f"Decoded MessagePack from {addr}: {obj}")
        except Exception as e:
            logger.error(f"Error with client {addr}: {e}")
        finally:
            sock.close()
            logger.info(f"Connection closed with {addr}")

    def stop(self):
        self.running = False
        if self.server_socket:
            try:
                self.server_socket.close()
            except Exception as e:
                logger.error(f"Error closing socket: {e}")
        logger.info("Server stopped")


def main():
    server = EndpointServer()
    server.start()
    try:
        while True:
            threading.Event().wait(1)
    except KeyboardInterrupt:
        logger.info("Shutdown requested")
    finally:
        server.stop()


if __name__ == "__main__":
    main()
