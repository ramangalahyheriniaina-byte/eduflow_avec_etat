import json
import time
import os
import re
from flask import Flask, request, jsonify
from flask_cors import CORS
from pdf_extractor import extract_pdf
from prompt_builder import create_block_prompt
from gemini_client import call_gemini
from parser import parse_json_output
import pandas as pd
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'pdf'}
BLOCK_SIZE = 4
MAX_BLOCKS = 10

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def filtrer_matieres_et_heures(programme_complet):
    """Filtre le JSON pour ne garder que le nom des matières et les heures totales"""
    resultat_filtre = []
    
    for bloc in programme_complet:
        if isinstance(bloc, dict) and 'ues' in bloc:
            for ue in bloc['ues']:
                if isinstance(ue, dict) and 'ue_name' in ue and 'total_hours' in ue:
                    nom_matiere = ue['ue_name']
                    if ':' in nom_matiere:
                        nom_matiere = nom_matiere.split(':', 1)[1].strip()
                    
                    resultat_filtre.append({
                        'nom_matiere': nom_matiere,
                        'total_hours': ue['total_hours']
                    })
    
    # Supprimer les doublons
    resultat_unique = []
    seen = set()
    for item in resultat_filtre:
        key = f"{item['nom_matiere']}_{item['total_hours']}"
        if key not in seen:
            seen.add(key)
            resultat_unique.append(item)
    
    return resultat_unique

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'ok',
        'message': 'IA EduFlow service is running'
    })

@app.route('/upload', methods=['POST'])
def upload_pdf():
    """Endpoint principal pour l'analyse PDF"""
    try:
        print("🔄 Réception du PDF...")
        
        if 'file' not in request.files:
            return jsonify({'error': 'Aucun fichier envoyé'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'Nom de fichier vide'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': 'Format non autorisé. Utilisez PDF uniquement.'}), 400
        
        # Sauvegarder temporairement
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        print(f"✅ Fichier sauvegardé: {filepath}")
        print("🔄 Début de l'analyse IA...")
        
        # Extraire le texte du PDF
        try:
            df = extract_pdf(filepath)
            print(f"📊 PDF extrait: {len(df)} lignes")
        except Exception as e:
            return jsonify({'error': f'Erreur extraction PDF: {str(e)}'}), 500
        
        # Analyser par blocs
        programme_modernise = []
        
        total_lignes = len(df)
        for start in range(0, min(total_lignes, MAX_BLOCKS * BLOCK_SIZE), BLOCK_SIZE):
            end = min(start + BLOCK_SIZE, total_lignes)
            print(f"📝 Analyse bloc {start}-{end-1}")
            
            try:
                block = df.iloc[start:end]
                prompt = create_block_prompt(block)
                
                data_dict = call_gemini(prompt)
                
                response_text = json.dumps(data_dict, ensure_ascii=False)
                print(f"📄 Réponse reçue, longueur: {len(response_text)} caractères")
                
                if data_dict and isinstance(data_dict, dict):
                    programme_modernise.append(data_dict)
                    if 'ues' in data_dict:
                        print(f"   ✅ Bloc analysé: {len(data_dict['ues'])} UE(s)")
                        for ue in data_dict['ues'][:2]:
                            if 'ue_name' in ue:
                                print(f"      - {ue['ue_name'][:50]}...")
                    else:
                        print(f"   ✅ Bloc analysé (pas de clé 'ues')")
                else:
                    print(f"   ⚠️ Bloc ignoré (vide ou invalide)")
                
                time.sleep(1)
                
            except Exception as e:
                print(f"   ❌ Erreur sur bloc {start}: {str(e)}")
                continue
        
        # ⚠️ Aucun bloc analysé
        if not programme_modernise:
            print("⚠️ Aucun bloc analysé par Gemini, aucun résultat retourné.")
            return jsonify({'error': 'Aucun bloc analysé par Gemini'}), 500
        
        # Sauvegarder le JSON complet (optionnel)
        json_path = os.path.join(app.config['UPLOAD_FOLDER'], 'programme_moderne.json')
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(programme_modernise, f, indent=2, ensure_ascii=False)
        
        # Filtrer pour Flutter
        resultat_filtre = filtrer_matieres_et_heures(programme_modernise)
        
        print(f"✅ Analyse terminée: {len(resultat_filtre)} matières extraites")
        for i, matiere in enumerate(resultat_filtre[:5]):
            print(f"   - {matiere['nom_matiere']}: {matiere['total_hours']}h")
        
        os.remove(filepath)
        
        return jsonify(resultat_filtre), 200
        
    except Exception as e:
        print(f"❌ Erreur générale: {str(e)}")
        import traceback
        traceback.print_exc()
        if 'filepath' in locals() and os.path.exists(filepath):
            try:
                os.remove(filepath)
            except:
                pass
        return jsonify({'error': str(e)}), 500

@app.route('/debug', methods=['POST'])
def debug_upload():
    """Version debug qui retourne plus d'informations"""
    try:
        print("🔄 [DEBUG] Réception du PDF...")
        
        if 'file' not in request.files:
            return jsonify({'error': 'Aucun fichier'}), 400
        
        file = request.files['file']
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        
        df = extract_pdf(filepath)
        programme_modernise = []
        stats = {
            'blocs_traites': 0,
            'blocs_success': 0,
            'total_ues': 0
        }
        
        total_lignes = len(df)
        for start in range(0, total_lignes, BLOCK_SIZE):
            end = min(start + BLOCK_SIZE, total_lignes)
            stats['blocs_traites'] += 1
            print(f"📝 Analyse bloc {start}")
            
            try:
                block = df.iloc[start:end]
                prompt = create_block_prompt(block)
                
                data_dict = call_gemini(prompt)
                
                if data_dict and isinstance(data_dict, dict):
                    programme_modernise.append(data_dict)
                    stats['blocs_success'] += 1
                    if 'ues' in data_dict:
                        stats['total_ues'] += len(data_dict['ues'])
                
                time.sleep(1)
            except Exception as e:
                print(f"   ❌ Erreur: {e}")
        
        debug_path = os.path.join(app.config['UPLOAD_FOLDER'], 'programme_moderne_debug.json')
        with open(debug_path, "w", encoding="utf-8") as f:
            json.dump(programme_modernise, f, indent=2, ensure_ascii=False)
        
        resultat_filtre = filtrer_matieres_et_heures(programme_modernise)
        os.remove(filepath)
        
        return jsonify({
            'success': True,
            'matieres': resultat_filtre,
            'debug': {
                'blocs_traites': stats['blocs_traites'],
                'blocs_success': stats['blocs_success'],
                'total_ues_brutes': stats['total_ues'],
                'total_matieres_filtrees': len(resultat_filtre),
                'debug_file': 'programme_moderne_debug.json'
            }
        }), 200
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    print("="*60)
    print("🚀 Serveur IA EduFlow - Démarrage...")
    print("="*60)
    print("📡 Endpoints disponibles:")
    print("   - GET  /health")
    print("   - POST /upload")
    print("   - POST /debug")
    print("="*60)
    print("🌐 Serveur démarré sur http://localhost:5000")
    print("📁 Les fichiers uploadés sont dans: uploads/")
    print("="*60)
    
    app.run(host='0.0.0.0', port=5000, debug=True)
