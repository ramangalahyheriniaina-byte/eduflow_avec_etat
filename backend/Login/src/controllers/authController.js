const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log(`🔐 Tentative de connexion: ${email}`);

    // Validation simple
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email et mot de passe requis'
      });
    }

    // 1. Chercher l'utilisateur
    const result = await db.query(
      'SELECT id, email, full_name, role, password_hash FROM users WHERE email = $1 AND is_active = true',
      [email.toLowerCase()]
    );

    if (result.rows.length === 0) {
      console.log(`❌ Utilisateur non trouvé: ${email}`);
      return res.status(401).json({
        success: false,
        message: 'Identifiants incorrects'
      });
    }

    const user = result.rows[0];
    console.log(`👤 Utilisateur trouvé: ${user.full_name} (${user.role})`);

    // 2. Vérifier le mot de passe
    // Pour le moment, les mots de passe sont "temp" - on va les mettre à jour après
    let isValidPassword = false;
    
    if (user.password_hash === 'temp') {
      // Mode développement: accepter les mots de passe par défaut
      const defaultPasswords = {
        'admin@eduflows.com': 'admin123',
        'prof@eduflows.com': 'prof123',
        'etudiant@eduflows.com': 'etudiant123'
      };
      
      isValidPassword = password === defaultPasswords[user.email];
    } else {
      // Mode normal: vérifier avec bcrypt
      isValidPassword = await bcrypt.compare(password, user.password_hash);
    }
    
    if (!isValidPassword) {
      console.log(`❌ Mot de passe incorrect pour: ${email}`);
      return res.status(401).json({
        success: false,
        message: 'Identifiants incorrects'
      });
    }

    // 3. Créer le token JWT
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        name: user.full_name,
        role: user.role
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    // 4. Mettre à jour last_login
    await db.query(
      'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1',
      [user.id]
    );

    console.log(`✅ Connexion réussie: ${user.email} (${user.role})`);

    // 5. Retourner la réponse
    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.full_name,
        role: user.role
      }
    });

  } catch (error) {
    console.error('🔥 Erreur login:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
};

const register = async (req, res) => {
  try {
    const { email, password, full_name, role } = req.body;

    // Validation
    if (!email || !password || !full_name || !role) {
      return res.status(400).json({
        success: false,
        message: 'Tous les champs sont requis'
      });
    }

    // Vérifier si l'email existe déjà
    const existingUser = await db.query(
      'SELECT id FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cet email est déjà utilisé'
      });
    }

    // Hasher le mot de passe
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Créer l'utilisateur
    const result = await db.query(
      'INSERT INTO users (email, password_hash, full_name, role) VALUES ($1, $2, $3, $4) RETURNING id, email, full_name, role',
      [email.toLowerCase(), passwordHash, full_name, role]
    );

    const newUser = result.rows[0];

    // Créer le token
    const token = jwt.sign(
      {
        id: newUser.id,
        email: newUser.email,
        name: newUser.full_name,
        role: newUser.role
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.status(201).json({
      success: true,
      token,
      user: newUser
    });

  } catch (error) {
    console.error('Erreur register:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
};

const logout = (req, res) => {
  res.json({
    success: true,
    message: 'Déconnexion réussie'
  });
};

const verifyToken = async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Token manquant'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Vérifier si l'utilisateur existe toujours
    const userResult = await db.query(
      'SELECT id, email, full_name, role FROM users WHERE id = $1 AND is_active = true',
      [decoded.id]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }

    res.json({
      success: true,
      user: userResult.rows[0]
    });

  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Token invalide'
    });
  }
};

const hashPasswords = async (req, res) => {
  try {
    // Récupérer tous les utilisateurs
    const users = await db.query('SELECT id, email, password_hash FROM users');
    
    for (const user of users.rows) {
      if (user.password_hash === 'temp') {
        let password = '';
        
        // Assigner le bon mot de passe selon l'email
        switch(user.email) {
          case 'admin@eduflows.com':
            password = 'admin123';
            break;
          case 'prof@eduflows.com':
            password = 'prof123';
            break;
          case 'etudiant@eduflows.com':
            password = 'etudiant123';
            break;
          default:
            password = 'password123';
        }
        
        // Hasher le mot de passe
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(password, salt);
        
        // Mettre à jour dans la base
        await db.query(
          'UPDATE users SET password_hash = $1 WHERE id = $2',
          [passwordHash, user.id]
        );
        
        console.log(`🔑 Mot de passe hashé pour: ${user.email}`);
      }
    }
    
    res.json({
      success: true,
      message: 'Mots de passe hashés avec succès'
    });
    
  } catch (error) {
    console.error('Erreur hashPasswords:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
};

module.exports = { login, register, logout, verifyToken, hashPasswords };
