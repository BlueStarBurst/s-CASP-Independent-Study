# create a server that listens for incoming connections
# and sends the current time to the client
# The server will run on port 12345

import socket
import time


HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
PORT = 12345  # Port to listen on (non-privileged ports are > 1023)

print("Server started")

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    while True:
        s.listen()
        conn, addr = s.accept()
        with conn:
            print(f"Connected by {addr}")
            while True:
                data = conn.recv(1024)
                print(data)
                if not data:
                    break
                conn.sendall(data)