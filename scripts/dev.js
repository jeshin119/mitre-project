#!/usr/bin/env node

/**
 * Unified Development Server
 * Starts both backend and frontend with proper dependency management
 */

const { spawn } = require('child_process');
const path = require('path');
const waitOn = require('wait-on');

class DevServer {
  constructor() {
    this.processes = [];
    this.setupGracefulShutdown();
  }

  async start() {
    console.log('🚀 Starting Vintage Market Development Server');
    console.log('═'.repeat(50));

    try {
      // Step 1: Start backend first
      await this.startBackend();

      // Step 2: Wait for backend to be ready
      await this.waitForBackend();

      // Step 3: Start frontend
      await this.startFrontend();

      console.log('\n✅ Development environment ready!');
      console.log('🌐 Frontend: http://localhost:8080');
      console.log('🔧 Backend: http://localhost:3000');
      console.log('📊 Health: http://localhost:3000/api/health');
      console.log('\n💡 Press Ctrl+C to stop all servers');

    } catch (error) {
      console.error('❌ Failed to start development server:', error.message);
      await this.cleanup();
      process.exit(1);
    }
  }

  startBackend() {
    return new Promise((resolve, reject) => {
      console.log('🔧 Starting backend server...');
      
      const backend = spawn('npm', ['run', 'dev'], {
        cwd: path.join(process.cwd(), 'backend'),
        stdio: ['inherit', 'pipe', 'pipe'],
        env: { ...process.env, AUTO_RESOLVE_PORT: 'true' }
      });

      this.processes.push(backend);

      backend.stdout.on('data', (data) => {
        process.stdout.write(`[BACKEND] ${data}`);
      });

      backend.stderr.on('data', (data) => {
        process.stderr.write(`[BACKEND] ${data}`);
      });

      backend.on('error', reject);
      
      // Give backend some time to start
      setTimeout(resolve, 2000);
    });
  }

  async waitForBackend() {
    console.log('⏳ Waiting for backend to be ready...');
    
    try {
      await waitOn({
        resources: ['http://localhost:3000/api/health'],
        timeout: 30000,
        interval: 1000
      });
      console.log('✅ Backend is ready!');
    } catch (error) {
      console.log('⚠️ Backend health check timeout, continuing...');
    }
  }

  startFrontend() {
    return new Promise((resolve, reject) => {
      console.log('🎨 Starting frontend server...');
      
      const frontend = spawn('npm', ['run', 'dev'], {
        cwd: path.join(process.cwd(), 'frontend'),
        stdio: ['inherit', 'pipe', 'pipe'],
        env: { ...process.env, VITE_API_URL: 'http://localhost:3000' }
      });

      this.processes.push(frontend);

      frontend.stdout.on('data', (data) => {
        process.stdout.write(`[FRONTEND] ${data}`);
      });

      frontend.stderr.on('data', (data) => {
        process.stderr.write(`[FRONTEND] ${data}`);
      });

      frontend.on('error', reject);
      
      setTimeout(resolve, 3000);
    });
  }

  setupGracefulShutdown() {
    const shutdown = async () => {
      console.log('\n🛑 Shutting down development servers...');
      await this.cleanup();
      process.exit(0);
    };

    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
    process.on('uncaughtException', async (error) => {
      console.error('❌ Uncaught Exception:', error);
      await this.cleanup();
      process.exit(1);
    });
  }

  async cleanup() {
    console.log('🧹 Cleaning up processes...');
    
    for (const process of this.processes) {
      if (process && !process.killed) {
        process.kill('SIGTERM');
      }
    }

    // Wait for processes to terminate
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}

// Start development server if called directly
if (require.main === module) {
  const server = new DevServer();
  server.start();
}

module.exports = DevServer;