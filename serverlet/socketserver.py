import socket
import threading
import struct
import time
import logging
import zlib
import json

# Configuration des logs
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class SimpleGameServer:
    def __init__(self, host='127.0.0.1', port=8184):
        self.host = host
        self.port = port
        self.server_socket = None
        self.clients = {}
        self.running = False

    def start(self):
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(5)
        self.running = True

        logger.info(f"Serveur démarré sur {self.host}:{self.port}")

        accept_thread = threading.Thread(target=self.accept_connections)
        accept_thread.daemon = True
        accept_thread.start()

    def accept_connections(self):
        while self.running:
            try:
                client_socket, address = self.server_socket.accept()
                logger.info(f"Nouvelle connexion depuis {address}")

                client_thread = threading.Thread(
                    target=self.handle_client,
                    args=(client_socket, address)
                )
                client_thread.daemon = True
                client_thread.start()

                self.clients[address] = client_socket

            except Exception as e:
                if self.running:
                    logger.error(f"Erreur lors de l'acceptation d'une connexion : {e}")

    def handle_client(self, client_socket, address):
        try:
            while self.running:
                raw_length = client_socket.recv(4)
                if not raw_length:
                    break

                message_length = struct.unpack('>I', raw_length)[0]
                if message_length > 1024:
                    logger.warning(f"Longueur reçue trop grande ({message_length}), ajustée à 1024")
                    message_length = 1024

                data = client_socket.recv(message_length)
                if data:
                    logger.info(f"Reçu de {address} (longueur: {message_length}): {data.hex()}")
                    message_str = data.decode('ascii', errors='ignore')
                    if "icy-file-request" in message_str:
                        self.send_game_ready_response(client_socket, address)
                    elif "auth" in message_str:
                        self.send_auth_response(client_socket, address)
                else:
                    break

        except Exception as e:
            logger.error(f"Erreur avec le client {address}: {e}")
        finally:
            self.disconnect_client(client_socket, address)

    def send_game_ready_response(self, client_socket, address):
        message_type = "GAME_READY"
        server_time = float(time.time() * 1000)

        config_xml = '''<config>
            <playerio>
                <game_id>fake-game-id</game_id>
                <conn_id>fake-conn-id</conn_id>
            </playerio>
            <logger_url>http://127.0.0.1:5000/log</logger_url>
        </config>'''.encode('utf-8')
        compressed_xml = zlib.compress(config_xml)

        binaries = bytearray()
        binaries.append(1)  # Nombre de fichiers : 1
        binaries.extend(struct.pack('>H', len("config.xml")))
        binaries.extend("config.xml".encode('utf-8'))
        binaries.extend(struct.pack('>I', len(compressed_xml)))
        binaries.extend(compressed_xml)

        cost_table = json.dumps({"version": 1}).encode('utf-8')
        survivor_class = json.dumps([{"id": "scavenger", "name": "Scavenger"}]).encode('utf-8')
        login_state = json.dumps({
            "settings": {},
            "invsize": 10,
            "upgrades": "",
            "allianceId": None,
            "allianceTag": None
        }).encode('utf-8')

        response = bytearray()
        response.extend(struct.pack('>I', len(message_type)))
        response.extend(message_type.encode('utf-8'))
        response.extend(struct.pack('>I', 5))  # 5 arguments

        response.append(6)  # Double
        response.extend(struct.pack('>d', server_time))

        response.append(9)  # ByteArray
        response.extend(struct.pack('>I', len(binaries)))
        response.extend(binaries)

        response.append(5)  # String
        response.extend(struct.pack('>I', len(cost_table)))
        response.extend(cost_table)

        response.append(5)  # String
        response.extend(struct.pack('>I', len(survivor_class)))
        response.extend(survivor_class)

        response.append(5)  # String
        response.extend(struct.pack('>I', len(login_state)))
        response.extend(login_state)

        message = struct.pack('>I', len(response)) + response
        client_socket.sendall(message)
        logger.info(f"Réponse GAME_READY envoyée à {address} (longueur: {len(message)}, hex: {message.hex()})")

    def send_auth_response(self, client_socket, address):
        message_type = "auth_response"
        response = bytearray()
        response.extend(struct.pack('>I', len(message_type)))
        response.extend(message_type.encode('utf-8'))
        response.extend(struct.pack('>I', 1))  # 1 argument
        response.append(1)  # Type booléen
        response.append(1)  # True
        message = struct.pack('>I', len(response)) + response
        client_socket.sendall(message)
        logger.info(f"Réponse auth envoyée à {address} (longueur: {len(message)}, hex: {message.hex()})")

    def disconnect_client(self, client_socket, address):
        if address in self.clients:
            logger.info(f"Déconnexion de {address}")
            try:
                client_socket.close()
            except:
                pass
            del self.clients[address]

    def stop(self):
        self.running = False
        if self.server_socket:
            self.server_socket.close()
        for client_socket in self.clients.values():
            try:
                client_socket.close()
            except:
                pass
        self.clients.clear()
        logger.info("Serveur arrêté")

def main():
    server = SimpleGameServer()
    try:
        server.start()
        while True:
            command = input("Entrez 'stop' pour arrêter le serveur : ")
            if command.lower() == 'stop':
                break
    except KeyboardInterrupt:
        logger.info("Arrêt du serveur via interruption")
    finally:
        server.stop()

if __name__ == "__main__":
    main()