import pdfplumber
import pandas as pd

def extract_pdf(path):
    rows = []
    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            for table in page.extract_tables():
                if table and len(table) > 1:
                    rows.extend(table)

    df = pd.DataFrame(rows[1:], columns=rows[0])
    df = df.dropna(how="all")
    return df
