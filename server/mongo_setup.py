import pymongo
from pymongo import MongoClient



def connect_mongo_db_users():
    cluster =MongoClient("mongodb+srv://cyber:521242@orenproject.su4av.mongodb.net/?retryWrites=true&w=majority&appName=OrenProject")
    db = cluster["community_net"]
    collection = db["users"]
    return collection



        


