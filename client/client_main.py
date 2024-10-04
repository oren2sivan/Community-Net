import socket
import threading
#
class Client:

    def __init__(self,ip):
        self.ip=ip
        self.client_socket=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client_socket.connect((ip,52124))
        print(f"connected to server")
        self.chat_with_server()
    
    
    def chat_with_server(self):
        send_thread = threading.Thread(target=self.send_to_server)
        recv_thread = threading.Thread(target=self.recieve_from_server)

        
        send_thread.start()
        recv_thread.start()
 
        

    def send_to_server(self):
        while True:
            message=input("--")
            if message=="exit":
                print("end of convo")
                self.client_socket.close()
            else:
                self.client_socket.send(message.encode())


    def recieve_from_server(self):
        while True:
            try:
                message = self.client_socket.recv(1024).decode()
                if not message:
                    pass
                if message == "exit":
                    print("End of convo")
                    self.client_socket.close()
                    break
                print(f"Server: {message}")
            except ConnectionResetError:
                print("Connection closed by the server.")
                self.client_socket.close()
                break

            
    

exm=Client("127.0.0.1")