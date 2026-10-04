from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database.db import Base, engine
from app.models.memory import Memory  # noqa: F401 -- needed so Base knows about this table
from app.models.user import User  # noqa: F401 -- needed so Base knows about this table
from app.api.auth import router as auth_router
from app.api.chat import router as chat_router
from app.api.memory import router as memory_router

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(auth_router, prefix="/auth")
app.include_router(chat_router, prefix="/chat")
app.include_router(memory_router, prefix="/memory")


@app.get("/health")
def health_check():
    return {"status": "ok"}


app = CORSMiddleware(
    app=app,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)