from TCP import CommTCP
import json
from perception import get_action


print("Server started")
CommTCP.connect()  
    
while True:
    isData, data = CommTCP.receive()
    if not isData:
        continue  
            
    with open("data.json", "w") as f:
        f.write(data)
                        
    if not data:
        break
    
    # send json data of action: "chop" to the client
    desc, func, args = get_action(data)
    
    data = json.dumps({"desc": desc, "func": func, "args": args})
    # encode to bytes
    data = data.encode("utf-8")
    CommTCP.send(data)
            
                
                
