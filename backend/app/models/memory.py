import os
import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Text, func
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.types import Uuid

from app.database.db import Base

# pgvector is only available when using PostgreSQL.
# Fall back to storing embeddings as Text (JSON) for SQLite dev environments.
_DATABASE_URL = os.getenv("DATABASE_URL", "")
_USE_VECTOR = _DATABASE_URL.startswith("postgresql")

if _USE_VECTOR:
    from pgvector.sqlalchemy import Vector  # type: ignore
    _EmbeddingColumn = Vector(768)
else:
    _EmbeddingColumn = Text()


class Memory(Base):
    __tablename__ = "memories"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    content: Mapped[str] = mapped_column(Text, nullable=False)
    embedding: Mapped[str] = mapped_column(_EmbeddingColumn, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
