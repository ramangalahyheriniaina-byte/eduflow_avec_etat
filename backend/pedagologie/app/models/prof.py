"""
Modèle SQLAlchemy pour la table prof
"""
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.database import Base


class Prof(Base):
    __tablename__ = "prof"

    id_prof = Column(Integer, primary_key=True, autoincrement=True)
    nom_prof = Column(String(100))
    nb_abs = Column(Integer, default=0)

    # Relations
    cours = relationship("Cours", back_populates="prof")

    def __repr__(self):
        return f"<Prof(id={self.id_prof}, nom={self.nom_prof}, absences={self.nb_abs})>"
