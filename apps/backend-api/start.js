#!/usr/bin/env node

// Script de démarrage pour Clever Cloud - Backend API
const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Démarrage de VIRIDA Backend API...');
console.log('📁 Répertoire de travail:', process.cwd());
console.log('🔧 PORT:', process.env.PORT || 'non défini');

// Démarrer l'application backend
const child = spawn('node', ['server.js'], {
  stdio: 'inherit',
  env: {
    ...process.env,
    PORT: process.env.PORT || '8080'
  }
});

child.on('error', (err) => {
  console.error('❌ Erreur lors du démarrage:', err);
  process.exit(1);
});

child.on('exit', (code) => {
  console.log(`🛑 Application arrêtée avec le code: ${code}`);
  process.exit(code);
});

// Gestion des signaux
process.on('SIGTERM', () => {
  console.log('🛑 Signal SIGTERM reçu, arrêt de l\'application...');
  child.kill('SIGTERM');
});

process.on('SIGINT', () => {
  console.log('🛑 Signal SIGINT reçu, arrêt de l\'application...');
  child.kill('SIGINT');
});
