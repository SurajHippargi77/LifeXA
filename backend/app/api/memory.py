from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.auth import get_current_user
from app.database.db import get_db
from app.services.memory_service import delete_memory, list_memories, store_memory

router = APIRouter()


class MemoryRequest(BaseModel):
    content: str


@router.post("", status_code=status.HTTP_201_CREATED)
def create_memory(
    request: MemoryRequest,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user),
):
    return store_memory(db, user_id, request.content)


@router.get("")
def get_memories(db: Session = Depends(get_db), user_id: str = Depends(get_current_user)):
    return list_memories(db, user_id)


@router.delete("/{memory_id}")
def remove_memory(
    memory_id: str,
    db: Session = Depends(get_db),
    user_id: str = Depends(get_current_user),
):
    if not delete_memory(db, user_id, memory_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found")
    return {"success": True}