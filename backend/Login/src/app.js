const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware CORS - AJOUTEZ le port 8080
app.use(cors({
  origin: [
    'http://localhost:8080',  // ← FLUTTER WEB PORT
    'http://127.0.0.1:8080',
    'http://localhost:5555', 
    'http://localhost:3000', 
    'http://localhost:3001'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // ← Ajoutez OPTIONS
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'] // ← Headers autorisés
}));

// Gérer les requêtes OPTIONS (préflight CORS)
app.options('*', cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging des requêtes
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  console.log(`Origin: ${req.headers.origin}`);
  console.log(`Headers: ${JSON.stringify(req.headers)}`);
  next();
});

// Routes
app.use('/api/auth', authRoutes);

// Route de test
app.get('/api/health', (req, res) => {
  res.json({ 
    success: true, 
    message: '🚀 API EduFlows en ligne!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    allowedOrigins: [
      'http://localhost:8080',
      'http://127.0.0.1:8080',
      'http://localhost:5555'
    ]
  });
});

// Route 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée',
    path: req.originalUrl
  });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log('='.repeat(50));
  console.log('🚀 SERVEUR EDUFLOWS BACKEND');
  console.log('='.repeat(50));
  console.log(`📡 Port: ${PORT}`);
  console.log(`🌍 Environnement: ${process.env.NODE_ENV}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🔐 Login: POST http://localhost:${PORT}/api/auth/login`);
  console.log(`🌐 CORS autorisé pour: localhost:8080`);
  console.log('='.repeat(50));
});