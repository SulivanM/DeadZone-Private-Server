
import socket
import threading
import logging
import msgpack
import serde

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
        # unpacker = msgpack.Unpacker(raw=False)
        serializer = serde.BinarySerializer()
        deserializer = serde.BinaryDeserializer()

        try:
            while True:
                data = sock.recv(4096)
                if not data:
                    break
                logger.info(f"[{addr}] Received: {data}")

                if data.startswith(b"<policy-file-request/>"):
                    sock.sendall(CROSS_DOMAIN_POLICY)
                    logger.info(f"[{addr}] Sent cross-domain policy")
                    break

                # In the connect handler, the client writes byte 0 and immediately flushes it. Ignoring it as it is probably a new message indication.
                if data[0] == 0x00:
                    logger.info(f"[{addr}] Received x00 --- ignoring")
                    data = data[1:]

                try:
                    deserialized = deserializer.deserialize(data)
                    logger.info(f"[{addr}] Deserialized: {deserialized}")
                except Exception as e:
                    logger.warning(f"[{addr}] Deserialization failed: {e}")
                    continue

                # Client sends join message (from API server)
                if data.startswith(b'\x87\xc4join\xcedefaultJoinKey'):
                    logger.info(f"[{addr}] Join room request received")

                    # Assume the client joined successfully
                    successful_join = True
                    if successful_join:
                        msg = ["playerio.joinresult", True]
                    else:
                        # If failed, send back PlayerIOError of type 11
                        msg = ["playerio.joinresult", False, 11, "Failed to join room: Unknown connection"]

                    try:
                        serialized = serializer.serialize(msg)
                        logger.info(f"[{addr}] Sending: {serialized}")
                        sock.sendall(serialized)

                    except Exception as e:
                        logger.error(f"[{addr}] Serialization/send failed: {e}")

                    # Simulate uncaught exception to test API 50
                    # Supposed to be a game ready message (gr)
                    msg = "gr first second"
                    logger.info(f"[{addr}] Sending: {msg}")
                    sock.sendall(msg)

        except Exception as e:
            logger.error(f"[{addr}] Connection error: {e}")
        finally:
            sock.close()
            logger.info(f"[{addr}] Connection closed")

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
