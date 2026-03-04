def create_block_prompt(block_df):

    data_text = ""
    for _, row in block_df.iterrows():
        data_text += " | ".join(
            f"{col}: {str(row[col])[:120]}"
            for col in block_df.columns
        ) + "\n"

    return f"""
Tu es un expert en ingénierie pédagogique.

Modernise et structure ce programme.

Contraintes :
- Supprime contenu obsolète.
- Respecte ordre pédagogique logique.
- Donne durées réalistes.
- Réponds STRICTEMENT en JSON valide.

Format attendu :

{{
  "ues": [
    {{
      "ue_name": "",
      "total_hours": 0,
      "lessons": [
        {{
          "lesson_name": "",
          "objective": "",
          "duration_hours": 0,
          "type": "theorie/pratique/projet"
        }}
      ]
    }}
  ]
}}

Programme source :
{data_text}
"""
