const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Routes publiques
router.post('/login', authController.login);
router.post('/register', authController.register);
router.post('/verify', authController.verifyToken);
router.post('/hash-passwords', authController.hashPasswords); // Route spéciale pour hasher les mots de passe

// Route protégée (exemple)
router.post('/logout', authController.logout);

module.exports = router;
