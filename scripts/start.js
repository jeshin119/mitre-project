#!/usr/bin/env node

/**
 * Production Startup Script
 * Optimized for production deployment
 */

const { spawn } = require('child_process');
const path = require('path');

class ProductionServer {
  constructor() {
    this.processes = [];
    this.setupGracefulShutdown();
  }

  async start() {
    console.log('🚀 Starting Vintage Market Production Server');
    console.log('═'.repeat(50));

    const isProduction = process.env.NODE_ENV === 'production';
    console.log(`📦 Environment: ${isProduction ? 'Production' : 'Development'}`);

    try {
      if (isProduction) {
        await this.buildProduction();
      }
      
      await this.startBackend();
      await this.startFrontend();

      console.log('\n✅ Production server ready!');
      console.log('🌐 Application: http://localhost:5173');
      console.log('🔧 API: http://localhost:3000');

    } catch (error) {
      console.error('❌ Failed to start production server:', error.message);
      await this.cleanup();
      process.exit(1);
    }
  }

  async buildProduction() {
    console.log('🏗️ Building production assets...');
    
    return new Promise((resolve, reject) => {
      const build = spawn('npm', ['run', 'build'], {
        cwd: process.cwd(),
        stdio: 'inherit'
      });

      build.on('close', (code) => {
        if (code === 0) {
          console.log('✅ Production build completed');
          resolve();
        } else {
          reject(new Error(`Build failed with exit code ${code}`));
        }
      });
    });
  }

  startBackend() {
    return new Promise((resolve) => {
      console.log('🔧 Starting backend server...');
      
      const backend = spawn('npm', ['start'], {
        cwd: path.join(process.cwd(), 'backend'),
        stdio: ['inherit', 'pipe', 'pipe'],
        env: process.env
      });

      this.processes.push(backend);

      backend.stdout.on('data', (data) => {
        process.stdout.write(`[BACKEND] ${data}`);
      });

      backend.stderr.on('data', (data) => {
        process.stderr.write(`[BACKEND] ${data}`);
      });

      setTimeout(resolve, 3000);
    });
  }

  startFrontend() {
    return new Promise((resolve) => {
      console.log('🎨 Starting frontend server...');
      
      const command = process.env.NODE_ENV === 'production' ? 'preview' : 'dev';
      
      const frontend = spawn('npm', ['run', command], {
        cwd: path.join(process.cwd(), 'frontend'),
        stdio: ['inherit', 'pipe', 'pipe'],
        env: process.env
      });

      this.processes.push(frontend);

      frontend.stdout.on('data', (data) => {
        process.stdout.write(`[FRONTEND] ${data}`);
      });

      frontend.stderr.on('data', (data) => {
        process.stderr.write(`[FRONTEND] ${data}`);
      });

      setTimeout(resolve, 2000);
    });
  }

  setupGracefulShutdown() {
    const shutdown = async () => {
      console.log('\n🛑 Shutting down servers...');
      await this.cleanup();
      process.exit(0);
    };

    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
  }

  async cleanup() {
    for (const process of this.processes) {
      if (process && !process.killed) {
        process.kill('SIGTERM');
      }
    }

    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}

if (require.main === module) {
  const server = new ProductionServer();
  server.start();
}

module.exports = ProductionServer;