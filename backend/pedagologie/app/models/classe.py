"""
Modèle SQLAlchemy pour la table classe
"""
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.database import Base


class Classe(Base):
    __tablename__ = "classe"

    id_classe = Column(Integer, primary_key=True, autoincrement=True)
    nom_classe = Column(String(100))

    # Relations
    matieres = relationship("Matiere", back_populates="classe")

    def __repr__(self):
        return f"<Classe(id={self.id_classe}, nom={self.nom_classe})>"
