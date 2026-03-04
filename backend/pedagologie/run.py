#!/usr/bin/env python
"""
Script de démarrage rapide pour l'application EduFlow

Usage:
    python run.py                    # Démarre en mode développement
    python run.py --prod             # Démarre en mode production
    python run.py --port 8080        # Spécifie un port personnalisé
"""

import argparse
import uvicorn

def main():
    parser = argparse.ArgumentParser(description="Démarrer l'application EduFlow")
    parser.add_argument(
        "--host",
        default="0.0.0.0",
        help="Hôte sur lequel démarrer le serveur (défaut: 0.0.0.0)"
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8000,
        help="Port sur lequel démarrer le serveur (défaut: 8000)"
    )
    parser.add_argument(
        "--prod",
        action="store_true",
        help="Démarrer en mode production (désactive le rechargement automatique)"
    )
    
    args = parser.parse_args()
    
    print(f"""
╔════════════════════════════════════════╗
║         EduFlow Backend API            ║
╚════════════════════════════════════════╝

🚀 Démarrage du serveur...
📍 Host: {args.host}
🔌 Port: {args.port}
🔧 Mode: {'Production' if args.prod else 'Développement'}

📚 Documentation disponible sur:
   → Swagger UI: http://{args.host if args.host != '0.0.0.0' else 'localhost'}:{args.port}/docs
   → ReDoc: http://{args.host if args.host != '0.0.0.0' else 'localhost'}:{args.port}/redoc

""")
    
    uvicorn.run(
        "app.main:app",
        host=args.host,
        port=args.port,
        reload=not args.prod,
        log_level="info"
    )

if __name__ == "__main__":
    main()
