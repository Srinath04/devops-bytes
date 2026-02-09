from google import genai
import os
from dotenv import load_dotenv
from pathlib import Path

# Loading .env from project root
ROOT_DIR = Path(__file__).resolve().parents[1]
load_dotenv(ROOT_DIR / ".env")

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise RuntimeError("GEMINI_API_KEY not found")

client = genai.Client(api_key=api_key)

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Hi, my name is Srinath. I love to DevOps using Python. Write a short bio about me.",
)

print(response.text)
