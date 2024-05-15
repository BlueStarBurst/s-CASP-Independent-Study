import sys
import signal
import socket
import json

HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
PORT = 12345  # Port to listen on (non-privileged ports are > 1023)

print("Server started")

# print all the ip addresses of the server
print("IP addresses of the server:", socket.gethostbyname_ex(socket.gethostname()))

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    def signal_handler(sig, frame):
        s.close()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)
    
    while True:
        s.listen()
        conn, addr = s.accept()
        with conn:
            print(f"Connected by {addr}")
            while True:
                data = conn.recv(1024*10000)
                data = data.decode("utf-8") # decode the data from json
                
                with open("data.json", "w") as f:
                    f.write(data)
                                    
                if not data:
                    break
                
                # send json data of action: "chop" to the client
                data = json.dumps({"action": "chop_tree"})
                # encode to bytes
                data = data.encode("utf-8")
                
                conn.sendall(data)
                
                
