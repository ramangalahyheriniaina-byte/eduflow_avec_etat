"""
Modèle SQLAlchemy pour la table seance
"""
from sqlalchemy import Column, Integer, Date, Time, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.database import Base
import enum


class StatutSeance(str, enum.Enum):
    """Énumération pour le statut d'une séance"""
    ANNULE = "annule"
    PREVU = "prevu"
    EN_COURS = "en_cours"


class Seance(Base):
    __tablename__ = "seance"

    id_seance = Column(Integer, primary_key=True, autoincrement=True)
    id_cours = Column(Integer, ForeignKey("cours.id_cours"))
    date_seance = Column(Date)
    heure_debut = Column(Time)
    heure_fin = Column(Time)
    statut = Column(Enum(StatutSeance, name="statut_seance"), default=StatutSeance.PREVU)

    # Relations
    cours = relationship("Cours", back_populates="seances")

    def __repr__(self):
        return f"<Seance(id={self.id_seance}, date={self.date_seance}, statut={self.statut})>"

