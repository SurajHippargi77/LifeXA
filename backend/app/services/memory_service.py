import uuid

from google import genai
from google.genai import types
from sqlalchemy.orm import Session

from app.models.memory import Memory
from app.services.llm_service import LLM_API_KEY


def embed_text(text: str) -> list[float]:
    if not LLM_API_KEY:
        raise RuntimeError("LLM_API_KEY is not configured")

    client = genai.Client(api_key=LLM_API_KEY)
    response = client.models.embed_content(
        model="gemini-embedding-2",
        contents=text,
        config=types.EmbedContentConfig(output_dimensionality=768),
    )
    if not response.embeddings or not response.embeddings[0].values:
        raise RuntimeError("Gemini returned no embedding values")

    return list(response.embeddings[0].values)


def store_memory(db: Session, user_id: str, content: str) -> Memory:
    memory = Memory(user_id=uuid.UUID(user_id), content=content, embedding=embed_text(content))
    db.add(memory)
    db.commit()
    db.refresh(memory)
    return memory


def retrieve_relevant_memories(
    db: Session, user_id: str, query: str, limit: int = 3
) -> list[str]:
    query_embedding = embed_text(query)
    memories = (
        db.query(Memory)
        .filter(Memory.user_id == uuid.UUID(user_id))
        .order_by(Memory.embedding.cosine_distance(query_embedding))
        .limit(limit)
        .all()
    )
    return [memory.content for memory in memories]


def delete_memory(db: Session, user_id: str, memory_id: str) -> bool:
    memory = (
        db.query(Memory)
        .filter(Memory.id == uuid.UUID(memory_id), Memory.user_id == uuid.UUID(user_id))
        .first()
    )
    if not memory:
        return False

    db.delete(memory)
    db.commit()
    return True


def list_memories(db: Session, user_id: str) -> list[Memory]:
    return (
        db.query(Memory)
        .filter(Memory.user_id == uuid.UUID(user_id))
        .order_by(Memory.created_at.desc())
        .all()
    )