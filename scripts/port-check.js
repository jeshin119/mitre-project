#!/usr/bin/env node

/**
 * Port Availability Checker
 */

const net = require('net');

async function checkPort(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    
    server.listen(port, () => {
      server.close(() => resolve(true));
    });
    
    server.on('error', () => resolve(false));
  });
}

async function main() {
  const ports = process.argv.slice(2).map(p => parseInt(p)).filter(p => p > 0);
  const defaultPorts = ports.length > 0 ? ports : [3000, 5173];
  
  console.log('🔍 Checking port availability...');
  console.log('═'.repeat(40));
  
  for (const port of defaultPorts) {
    const available = await checkPort(port);
    const status = available ? '✅ Available' : '❌ In use';
    console.log(`Port ${port}: ${status}`);
  }
  
  const allAvailable = await Promise.all(defaultPorts.map(checkPort));
  const unavailablePorts = defaultPorts.filter((_, i) => !allAvailable[i]);
  
  if (unavailablePorts.length > 0) {
    console.log('');
    console.log('⚠️  Some ports are in use. Try:');
    console.log('   npm run port:clean');
    console.log('   or use different ports in .env');
    process.exit(1);
  } else {
    console.log('');
    console.log('✅ All ports are available!');
    process.exit(0);
  }
}

main().catch(console.error);