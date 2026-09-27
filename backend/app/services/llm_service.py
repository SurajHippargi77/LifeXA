import os

import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

LLM_API_KEY = os.getenv("LLM_API_KEY")
if LLM_API_KEY:
    genai.configure(api_key=LLM_API_KEY)


def generate_response(message: str) -> str:
    if not LLM_API_KEY:
        raise RuntimeError("LLM_API_KEY is not configured")

    model = genai.GenerativeModel("gemini-3.8-flash")
    response = model.generate_content(message)
    return response.text