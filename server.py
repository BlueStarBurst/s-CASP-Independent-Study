# create a server that listens for incoming connections
# and sends the current time to the client
# The server will run on port 12345

import socket
import time
import json


HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
PORT = 12345  # Port to listen on (non-privileged ports are > 1023)

print("Server started")

# print all the ip addresses of the server
print("IP addresses of the server")
print(socket.gethostbyname_ex(socket.gethostname()))

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    while True:
        s.listen()
        conn, addr = s.accept()
        with conn:
            print(f"Connected by {addr}")
            while True:
                data = conn.recv(1024*10000)
                print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
                # decode the data from json
                data = data.decode("utf-8")
                print(data)
                
                with open("data.json", "w") as f:
                    f.write(data)
                
                # # print out every key value pair on a new line
                # for key, value in data.items():
                #     print(key, ":", value)
                
                
                
                if not data:
                    break
                # conn.sendall(data)