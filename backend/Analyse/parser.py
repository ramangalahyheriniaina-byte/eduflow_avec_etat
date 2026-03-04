import json

def parse_json_output(text):
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        print("JSON invalide retourné par Gemini")
        return None
