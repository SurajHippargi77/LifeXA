from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.auth import get_current_user
from app.database.db import get_db
from app.services.llm_service import generate_response
from app.services.memory_service import retrieve_relevant_memories

router = APIRouter()


class ChatRequest(BaseModel):
    message: str


@router.post("")
def chat(
    request: ChatRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user),
):
    relevant_memories = retrieve_relevant_memories(db, user_id, request.message)
    prompt = request.message
    if relevant_memories:
        prompt = f"Relevant context about this user: {relevant_memories}\n\nUser message: {request.message}"
    return {"reply": generate_response(prompt)}