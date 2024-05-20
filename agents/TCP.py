import socket

class CommTCP(object):
    TCP_IP_SENDER, TCP_PORT_SENDER = "127.0.0.1", 25000
    TCP_IP_RECEIVER, TCP_PORT_RECEIVER = "127.0.0.1", 55000
    BUFFER_SIZE = 50 # 16
    conn = []
    addr = []
    s = []
    soketSender = []

    def connect(self):
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.bind((self.TCP_IP_RECEIVER, self.TCP_PORT_RECEIVER))
        self.s.listen(1)
        self.conn, self.addr = self.s.accept()

        self.soketSender = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.soketSender.connect((self.TCP_IP_SENDER, self.TCP_PORT_SENDER))

        self.conn.setblocking(False)
        print('TCP Connection success: Address is', self.addr)

    def receive(self):
        isData = False
        try:
            dataFromLua = self.conn.recv(self.BUFFER_SIZE)
            # receivedData = np.array(np.frombuffer(byte_data, dtype='S'))
            # print("Received: ", dataFromUnity, ', Length:', len(dataFromUnity))
            isData=True
            dataFromLua = dataFromLua.decode("utf-8")
            return isData, dataFromLua
        except BlockingIOError:
            return isData, ""


    def send(self, dataToLua):
        self.soketSender.send(dataToLua.encode())
    