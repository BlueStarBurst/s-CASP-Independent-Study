from perception import convert_json_to_predicate, get_actionJson_from_predicate

HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
PORT = 8080  # Port to listen on (non-privileged ports are > 1023)

from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

class Data(BaseModel):
    isInLight: bool
    sanity: str
    hunger: str
    health: str
    inventory: list
    equipped: list
    entitiesOnScreen: list
    time: dict
    season: str
    biome: str

app = FastAPI(debug=True)

#Set up cors to allow all localhost origins requests, with LUA
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/action_from_perception/")
async def get_action(jsonPreceptionData: Data):    
    predicate = convert_json_to_predicate(jsonPreceptionData.dict())
    actionJson = get_actionJson_from_predicate(predicate)
    return actionJson
    
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server:app", host=HOST, port=PORT, reload=True)
    

