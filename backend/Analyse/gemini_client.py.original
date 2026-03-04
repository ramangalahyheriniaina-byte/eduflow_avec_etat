import os
import json
from dotenv import load_dotenv
from google import genai

load_dotenv()

def call_gemini(prompt: str):
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        raise ValueError("GEMINI_API_KEY not found")

    client = genai.Client(api_key=api_key)

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
        config={
            "response_mime_type": "application/json",
        }
    )

    raw = response.text.strip()

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        print("Réponse brute :", raw)
        raise

    return data
