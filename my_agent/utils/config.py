import os
import google.auth
from dotenv import load_dotenv

load_dotenv()

ROOT_AGENT_MODEL = os.getenv("ROOT_AGENT_MODEL", "gemini-2.5-flash")
_, project_id = google.auth.default()

os.environ.setdefault("GOOGLE_CLOUD_PROJECT", project_id)
os.environ.setdefault("GOOGLE_CLOUD_LOCATION", "global")
os.environ.setdefault("GOOGLE_GENAI_USE_VERTEXAI", "True")
