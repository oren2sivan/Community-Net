import socket
import threading
import json
import subprocess
#from client_setup import setup
class Client:

    def __init__(self,ip):
        self.ip=ip
        self.client_socket=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client_socket.connect((ip,52124))
        print(f"connected to server")
        self.chat_with_server()
    
    
    def chat_with_server(self):
        self.send_thread = threading.Thread(target=self.send_to_server)
        self.recv_thread = threading.Thread(target=self.recieve_from_server)

        
        self.send_thread.start()
        self.recv_thread.start()
 
        

    def send_to_server(self):
        username=input("enter username:")
        password=input("enter password:")
        creds = json.dumps({"username": username, "password": password}) 
        self.client_socket.send(creds.encode())
        print("sent creds ")




    def recieve_from_server(self):
        while True:
            try:
                message = self.client_socket.recv(1024).decode()
                if not message:
                    print("error in message")
                elif message == "success_log_in":
                    #setup.total_setup()
                    print(message)
                    break
                else:
                    print("unable to login")
                    self.send_to_server()
            except ConnectionResetError:
                print("Connection closed by the server.")
                self.client_socket.close()
        self.connect_ipfs()


    def connect_ipfs(self):
        subprocess.run("python client\client_setup.py",shell=True)
        
            
    

exm=Client("127.0.0.1")