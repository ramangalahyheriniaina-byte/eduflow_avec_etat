"""
Modèle SQLAlchemy pour la table cours
"""
from sqlalchemy import Column, Integer, String, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.database import Base
import enum


class StatutCours(str, enum.Enum):
    """Énumération pour le statut d'un cours"""
    NON_COMMENCE = "non_commence"
    EN_COURS = "en_cours"
    TERMINE = "termine"


class Cours(Base):
    __tablename__ = "cours"

    id_cours = Column(Integer, primary_key=True, autoincrement=True)
    statut = Column(Enum(StatutCours, name="statut_cours"), default=StatutCours.NON_COMMENCE)
    id_matiere = Column(Integer, ForeignKey("matiere.id_matiere"))
    id_prof = Column(Integer, ForeignKey("prof.id_prof"))
    cumul = Column(Integer)

    # Relations
    matiere = relationship("Matiere", back_populates="cours")
    prof = relationship("Prof", back_populates="cours")
    seances = relationship("Seance", back_populates="cours")

    def __repr__(self):
        return f"<Cours(id={self.id_cours}, statut={self.statut}, cumul={self.cumul})>"
