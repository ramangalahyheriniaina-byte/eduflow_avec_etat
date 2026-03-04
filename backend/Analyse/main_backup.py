import json
import time
from pdf_extractor import extract_pdf
from prompt_builder import create_block_prompt
from gemini_client import call_gemini
from parser import parse_json_output

#PDF_PATH = "exemple_de_programme_eduflow.pdf"
PDF_PATH = "syllabus_table_rows.pdf"
#  Par exemple :
# PDF_PATH = "mon_programme.pdf"
# Ou avec chemin complet :
# PDF_PATH = "C:/Users/Tiavina/Documents/mon_cours.pdf"

BLOCK_SIZE = 4

if __name__ == "__main__":

    df = extract_pdf(PDF_PATH)
    programme_modernise = []

    for start in range(0, len(df), BLOCK_SIZE):
        block = df.iloc[start:start + BLOCK_SIZE]
        print(f"Analyse bloc {start}-{start + len(block) - 1}")

        prompt = create_block_prompt(block)
        parsed = call_gemini(prompt)


        if parsed:
            programme_modernise.append(parsed)
        else:
            print("Bloc ignoré")

        time.sleep(1)

    with open("programme_moderne.json", "w", encoding="utf-8") as f:
        json.dump(programme_modernise, f, indent=2, ensure_ascii=False)

    print("Programme modernisé généré.")