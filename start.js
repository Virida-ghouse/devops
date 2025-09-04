#!/usr/bin/env node

// Script de démarrage pour Clever Cloud
// Ce script s'assure que l'application démarre dans le bon répertoire

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Démarrage de VIRIDA Frontend 3D...');
console.log('📁 Répertoire de travail:', process.cwd());
console.log('🔧 PORT:', process.env.PORT || 'non défini');

// Changer vers le répertoire de l'application
process.chdir(path.join(__dirname, 'apps', 'frontend-3d'));

console.log('📁 Nouveau répertoire de travail:', process.cwd());

// Démarrer l'application
const child = spawn('node', ['server.js'], {
  stdio: 'inherit',
  env: process.env
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
