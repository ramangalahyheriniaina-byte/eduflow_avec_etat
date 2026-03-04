"""
Modèle SQLAlchemy pour la table matiere
"""
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base


class Matiere(Base):
    __tablename__ = "matiere"

    id_matiere = Column(Integer, primary_key=True, autoincrement=True)
    nom_matiere = Column(String(100))
    heure_totale = Column(Integer)
    id_classe = Column(Integer, ForeignKey("classe.id_classe"))

    # Relations
    classe = relationship("Classe", back_populates="matieres")
    cours = relationship("Cours", back_populates="matiere")

    def __repr__(self):
        return f"<Matiere(id={self.id_matiere}, nom={self.nom_matiere}, heures={self.heure_totale})>"
