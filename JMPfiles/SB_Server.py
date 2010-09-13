from socket import *
import time
import marshal
import SBMarch3

server_socket = socket(AF_INET,SOCK_STREAM)
server_socket.bind(("", 21688))

server_socket.listen(5)
count1 = 0
print "TCP server ready and waiting on port 21688"


while count1 < 1:
    client_socket, address = server_socket.accept()
    print "I got a connection from ", address
    while 1:
           
        data = client_socket.recv(1024000)
        
        if ( data == 'q' or data == 'Q'):
            client_socket.close()
            
            break
            
        elif (data == 'q2' or data == 'Q2'):
            client_socket.close()
            count1 = 1
            break
        
        else:
            #print "RECIEVED:", data
            data1 = eval(data)
            raw_data = SBMarch3.SimSeaBase(data1)
            char_data = str(raw_data)
            char_data= char_data.replace(",","")
            data_out = char_data.replace(") (",",")
            data_out = data_out.replace("(","")
            data_out= data_out.replace(")","")
            #print data_out
            client_socket.send(data_out)
            print "One python run done"
            
            
print "All Done!"
