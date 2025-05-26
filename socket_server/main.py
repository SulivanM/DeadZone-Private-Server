import socket
import threading
import logging

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
        self.clients = []

    def start(self):
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(5)
            self.running = True
            logger.info(f"Server started on {self.host}:{self.port}")
            accept_thread = threading.Thread(target=self.accept_connections)
            accept_thread.daemon = True
            accept_thread.start()
        except Exception as e:
            logger.error(f"Error starting the server: {e}")
            self.stop()

    def accept_connections(self):
        while self.running:
            try:
                client_socket, client_address = self.server_socket.accept()
                logger.info(f"New connection from {client_address}")
                self.clients.append(client_socket)
                client_thread = threading.Thread(
                    target=self.handle_client, args=(client_socket, client_address)
                )
                client_thread.daemon = True
                client_thread.start()
            except Exception as e:
                if self.running:
                    logger.error(f"Error accepting connection: {e}")

    def handle_client(self, client_socket, client_address):
        try:
            while self.running:
                data = client_socket.recv(1024)
                if not data:
                    break
                logger.info(f"Data received from {client_address}: {data}")
                if data.startswith(b"<policy-file-request/>"):
                    client_socket.send(CROSS_DOMAIN_POLICY)
                    logger.info(f"Sent policy file to {client_address}")
                else:
                    client_socket.send(data)
        except Exception as e:
            logger.error(f"Error with client {client_address}: {e}")
        finally:
            client_socket.close()
            if client_socket in self.clients:
                self.clients.remove(client_socket)
            logger.info(f"Client {client_address} disconnected")

    def stop(self):
        self.running = False
        if self.server_socket:
            try:
                self.server_socket.close()
            except Exception as e:
                logger.error(f"Error closing the socket: {e}")
        for client_socket in self.clients[:]:
            try:
                client_socket.close()
            except Exception as e:
                logger.error(f"Error closing a client connection: {e}")
        self.clients.clear()
        logger.info("Server stopped")


def main():
    server = EndpointServer(host="127.0.0.1", port=7777)
    server.start()
    try:
        while True:
            threading.Event().wait(1)
    except KeyboardInterrupt:
        logger.info("Shutdown requested by user")
    finally:
        server.stop()


if __name__ == "__main__":
    main()
