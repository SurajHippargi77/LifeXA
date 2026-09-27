from fastapi import APIRouter
from pydantic import BaseModel

from app.services.llm_service import generate_response

router = APIRouter()


class ChatRequest(BaseModel):
    message: str


@router.post("")
def chat(request: ChatRequest):
    return {"reply": generate_response(request.message)}