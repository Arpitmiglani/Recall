from fastapi import FastAPI
from pymongo import MongoClient
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS FIX
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



client = MongoClient("mongodb://localhost:27017/")
db = client["recall_ai"]
memory = db["memory"]


@app.post("/command")
async def command(data: dict):

    text = data["text"].lower().strip()

    # STORE MEMORY
    if "keeping my" in text or "i kept my" in text:

        text = text.replace("i kept my", "keeping my")

        try:
            part = text.split("keeping my")[1].strip()

            if " on " in part:
                item, location = part.split(" on ", 1)

            elif " in " in part:
                item, location = part.split(" in ", 1)

            elif " at " in part:
                item, location = part.split(" at ", 1)

            else:
                return {"response": "Please tell where you kept it."}

            item = item.strip()
            location = location.strip()

            memory.insert_one({
                "item": item,
                "location": location,
                "time": datetime.now()
            })

            return {
                "response": f"Okay, I will remember you kept your {item} on the {location}"
            }

        except:
            return {"response": "I couldn't understand the location."}


    # RETRIEVE MEMORY
    if "where did i keep my" in text:

        item = text.split("where did i keep my")[1].strip()

        result = memory.find_one({
            "item": {"$regex": item, "$options": "i"}
        })

        if result:
            return {
                "response": f"You kept your {result['item']} on the {result['location']}"
            }

        return {"response": "I cannot find that memory."}


    return {"response": "Sorry, I didn't understand."}
    