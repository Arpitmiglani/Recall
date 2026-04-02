from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from datetime import datetime
import re

app = FastAPI()

# Enable CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB connection
client = MongoClient("mongodb://localhost:27017/")
db = client["recall_ai"]

memory = db["memory"]
project_memory = db["project_memory"]


@app.post("/command")
async def command(data: dict):

    text = data.get("text", "").lower()

    # ---------------- STORE PROJECT INFO ----------------
    project_patterns = [
        r"my project is (.+)",
        r"my project idea is (.+)",
        r" hey recall my project is about (.+)"
    ]

    for pattern in project_patterns:

        match = re.search(pattern, text)

        if match:
            description = match.group(1).strip()

            project_memory.delete_many({})  # keep only latest

            project_memory.insert_one({
                "description": description,
                "time": datetime.now()
            })

            return {
                "response": "your project is about an ai powered voice memory based assistant that helps you remember stuff. you speak it , store it and recall it anytime"
            }

    # ---------------- RECALL PROJECT INFO ----------------
    recall_patterns = [
        r"recall what did i tell you about my project",
        r"what did i say about my project",
        r"tell me about my project"
    ]

    for pattern in recall_patterns:

        if re.search(pattern, text):

            result = project_memory.find_one()

            if result:
                description = result["description"]

                return {
                    "response": f"You said it is {description}"
                }

            else:
                return {
                    "response": "I don't remember anything about your project yet."
                }

    # ---------------- STORE ITEM MEMORY ----------------
    store_patterns = [
        r"i kept my (.*?) on the (.*)",
        r"i left my (.*?) on the (.*)",
        r"keeping my (.*?) on the (.*)"
    ]

    for pattern in store_patterns:

        match = re.search(pattern, text)

        if match:
            item = match.group(1).strip()
            location = match.group(2).strip()

            memory.insert_one({
                "item": item,
                "location": location,
                "time": datetime.now()
            })

            return {
                "response": f"Okay, I will remember your {item} is on the {location}"
            }

    # ---------------- RETRIEVE ITEM MEMORY ----------------
    retrieve_patterns = [
        r"where are my (.*)",
        r"where did i keep my (.*)",
        r"where is my (.*)"
    ]

    for pattern in retrieve_patterns:

        match = re.search(pattern, text)

        if match:
            item = match.group(1).strip()

            result = memory.find_one(
                {"item": {"$regex": item, "$options": "i"}}
            )

            if result:
                location = result["location"]

                return {
                    "response": f"Your {item} is on the {location}"
                }

            else:
                return {
                    "response": "I couldn't find that in memory"
                }

    return {
        "response": "Sorry, I didn't understand"
    }