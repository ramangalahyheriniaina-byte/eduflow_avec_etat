const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'postgres', // IMPORTANT: 'postgres' pour Docker
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'eduflows_db',
  user: process.env.DB_USER || 'eduflows_user',
  password: process.env.DB_PASSWORD || 'eduflows_password',
});

// Test de connexion
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ Erreur connexion PostgreSQL:', err.message);
    console.log('📋 Configuration utilisée:');
    console.log('- Host:', process.env.DB_HOST || 'postgres');
    console.log('- Port:', process.env.DB_PORT || 5432);
    console.log('- Database:', process.env.DB_NAME || 'eduflows_db');
    console.log('- User:', process.env.DB_USER || 'eduflows_user');
  } else {
    console.log('✅ Connecté à PostgreSQL avec succès!');
    client.query('SELECT NOW()', (err, result) => {
      release();
      if (err) {
        console.error('❌ Erreur query test:', err.message);
      } else {
        console.log('✅ Test query PostgreSQL réussi:', result.rows[0]);
      }
    });
  }
});

module.exports = {
  query: (text, params) => pool.query(text, params),
};