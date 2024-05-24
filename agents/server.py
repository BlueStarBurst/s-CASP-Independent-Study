from perception import get_action

HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
PORT = 48782  # Port to listen on (non-privileged ports are > 1023)

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
    timeOfDay: dict
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

@app.post("/action_from_perception/")
async def get_action(data: Data):
    return data
    
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server:app", host=HOST, port=PORT, reload=True)
    

