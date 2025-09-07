#!/usr/bin/env node

/**
 * Environment Setup Script
 * Sets up environment files and directories
 */

const fs = require('fs');
const path = require('path');

console.log('🔧 Setting up environment...');

// Create directories
const dirs = [
  'logs',
  'database', 
  'backend/logs',
  'backend/uploads',
  'frontend/logs'
];

dirs.forEach(dir => {
  const fullPath = path.join(process.cwd(), dir);
  if (!fs.existsSync(fullPath)) {
    fs.mkdirSync(fullPath, { recursive: true });
    console.log(`✅ Created directory: ${dir}`);
  }
});

// Setup environment file
const envExample = path.join(process.cwd(), '.env.example');
const envFile = path.join(process.cwd(), '.env');

if (fs.existsSync(envExample) && !fs.existsSync(envFile)) {
  fs.copyFileSync(envExample, envFile);
  console.log('✅ Created .env from .env.example');
}

// Setup backend environment
const backendEnvExample = path.join(process.cwd(), 'backend', '.env.example');
const backendEnvFile = path.join(process.cwd(), 'backend', '.env');

if (fs.existsSync(backendEnvExample) && !fs.existsSync(backendEnvFile)) {
  fs.copyFileSync(backendEnvExample, backendEnvFile);
  console.log('✅ Created backend/.env from backend/.env.example');
}

console.log('✅ Environment setup completed!');