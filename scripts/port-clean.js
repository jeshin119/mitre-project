#!/usr/bin/env node

/**
 * Port Cleanup Utility
 */

const { exec } = require('child_process');
const os = require('os');

async function killProcessOnPort(port) {
  return new Promise((resolve) => {
    const platform = os.platform();
    let command;
    
    if (platform === 'win32') {
      command = `for /f "tokens=5" %a in ('netstat -ano ^| findstr :${port}') do taskkill /PID %a /F`;
    } else {
      command = `lsof -ti:${port} | xargs kill -9`;
    }
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.log(`ℹ️  No processes found on port ${port}`);
      } else {
        console.log(`✅ Cleaned processes on port ${port}`);
      }
      resolve();
    });
  });
}

async function main() {
  const ports = process.argv.slice(2).map(p => parseInt(p)).filter(p => p > 0);
  const defaultPorts = ports.length > 0 ? ports : [3000, 5173, 8000, 8080];
  
  console.log('🧹 Cleaning ports...');
  console.log('═'.repeat(30));
  
  for (const port of defaultPorts) {
    await killProcessOnPort(port);
  }
  
  console.log('');
  console.log('✅ Port cleanup completed!');
}

main().catch(console.error);