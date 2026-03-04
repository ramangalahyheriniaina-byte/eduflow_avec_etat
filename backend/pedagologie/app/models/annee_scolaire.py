"""
Modèle SQLAlchemy pour la table annee_scolaire
"""
from sqlalchemy import Column, Integer, Boolean, CheckConstraint
from app.database import Base


class AnneeScolaire(Base):
    __tablename__ = "annee_scolaire"

    id_annee_scolaire = Column(Integer, primary_key=True, autoincrement=True)
    start_year = Column(Integer, nullable=False)
    end_year = Column(Integer, nullable=False)
    is_active = Column(Boolean, default=True)

    __table_args__ = (
        CheckConstraint('end_year = start_year + 1', name='valid_years'),
    )

    def __repr__(self):
        return f"<AnneeScolaire(id={self.id_annee_scolaire}, {self.start_year}-{self.end_year})>"
