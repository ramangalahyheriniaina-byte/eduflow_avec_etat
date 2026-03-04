require('dotenv').config();
const bcrypt = require('bcryptjs');
const { pool } = require('../src/config/database');

async function hashUserPasswords() {
  const client = await pool.connect();
  
  try {
    console.log('🔄 Hachage des mots de passe utilisateurs...');
    
    await client.query('BEGIN');
    
    // Liste des utilisateurs et leurs mots de passe
    const users = [
      { email: 'admin@eduflows.com', password: 'admin123' },
      { email: 'prof@eduflows.com', password: 'prof123' },
      { email: 'etudiant@eduflows.com', password: 'etudiant123' }
    ];
    
    for (const user of users) {
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(user.password, salt);
      
      await client.query(
        'UPDATE users SET password_hash = $1 WHERE email = $2',
        [passwordHash, user.email]
      );
      
      console.log(`✅ ${user.email} : mot de passe hashé`);
    }
    
    await client.query('COMMIT');
    console.log('🎉 Tous les mots de passe ont été hashés avec succès!');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Erreur:', error.message);
  } finally {
    client.release();
    process.exit();
  }
}

hashUserPasswords();
