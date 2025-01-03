import socket
import threading
import mongo_setup
import json
class Server:
    

    def __init__(self,ip):

        self.ip = ip 
        self.clients_list=[]
        self.users_collection=mongo_setup.connect_mongo_db_users()

        self.server=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.bind((self.ip,52124))
        self.server.listen(5)
        print("server running and listening for connections")
        
        self.accept_connections()
    

    def accept_connections(self):
        while True:
            client_socket,addr=self.server.accept()

            print(f"accepted connection from  {addr}")
            self.clients_list.append((client_socket,addr))
            print(self.clients_list)

            thread1=threading.Thread(target=self.authenticate_log_in, args=(client_socket,addr))        
            thread1.start()



    

    def send_message(self, client_socket, message,addr):
        try:
            client_socket.sendall(message.encode())
        except:
            print(f"Error sending message to client {client_socket}")
            self.clients_list.remove((client_socket, addr))
            client_socket.close()   

    def authenticate_log_in(self, client_socket, addr):
        while True:
            print("starting authentication")
            data=client_socket.recv(1024).decode()
            print(f"received message from {addr}: {data}")
            message=json.loads(data)
            username=message.get("username")
            password=int(message.get("password"))
            user=self.users_collection.find_one({"username":username,"password":password})
            if user:
                self.send_message(client_socket, "success_log_in", addr)
                print(f"sent success message")
                break
            
            else:
                print(f"Client {addr} failed to log in")
                self.send_message(client_socket, "failed_log_in", addr)
            



exm=Server("127.0.0.1")



