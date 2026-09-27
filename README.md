# LifeXA — Personalized AI Assistant Manager

LifeXA is a foundation for a personalized AI assistant manager that will bring together everyday tasks, conversations, memory, and intelligent assistance in one place.

## Getting Started

To run the backend locally:

```bash
cd backend
python -m venv venv
# Activate the virtual environment for your operating system
pip install -r requirements.txt
uvicorn main:app --reload
```

## Project Structure

- `frontend/`: Client applications, including the Flutter app.
- `backend/`: FastAPI backend and its application modules.
- `ml/`: Machine learning datasets, notebooks, training, models, and evaluation.
- `docs/`: Architecture documentation, research, and diagrams.
