# 🍎 macOS Port Conflict Fix

This guide specifically addresses the `cross-env: command not found` error on macOS.

## 🚨 Quick Fix for macOS Users

### Issue: `sh: cross-env: command not found`

This happens because the `cross-env` package is not installed in the root project. Here are **multiple solutions**:

### ✅ Solution 1: Install Dependencies (Recommended)
```bash
# Install missing cross-env package
npm install

# Then start with auto-resolution
npm run start:auto
```

### ✅ Solution 2: Use Native Cross-Platform Script
```bash
# Use the native Node.js script (no cross-env needed)
node scripts/start-auto.js
```

### ✅ Solution 3: Manual Environment Variable
```bash
# Set environment variable manually and start
AUTO_RESOLVE_PORT=true node backend/src/server.js
```

### ✅ Solution 4: Interactive Helper
```bash
# Use the macOS interactive helper
./fix-port-macos.sh
```

## 🔧 Complete Setup Process for macOS

### Step 1: Re-run Setup
```bash
# This will install all missing dependencies including cross-env
npm run setup
```

### Step 2: Start Server
```bash
# Now this should work without errors
npm run start:auto
```

## 🆘 If Problems Persist

### Check Node.js Version
```bash
node --version  # Should be >= 18.0.0
npm --version   # Should be >= 8.0.0
```

### Verify Installation
```bash
# Check if cross-env is installed
npm list cross-env

# If not found, install it
npm install cross-env
```

### Alternative Port Methods
```bash
# Method 1: Use specific port
PORT=3001 npm start

# Method 2: Find available port automatically
npm run port:find

# Method 3: Kill existing processes
npm run port:kill 3000 && npm start
```

## 🎯 Root Cause Analysis

The issue occurred because:
1. `cross-env` was listed as a `devDependency` but needed as regular dependency
2. macOS terminal doesn't have `cross-env` in PATH by default
3. The setup script didn't install root project dependencies

## ✅ Prevention for Future

We've fixed this by:
1. ✅ Moving `cross-env` to regular dependencies
2. ✅ Creating native Node.js cross-platform script
3. ✅ Adding root dependency installation to setup script
4. ✅ Providing multiple fallback methods

## 🧪 Test Your Fix

After applying any solution, test with:
```bash
# Should start without errors
npm run start:auto

# Check server is running
curl http://localhost:3000/api/health
```

## 💡 Pro Tips for macOS Development

1. **Use Homebrew**: `brew install node npm` for better Node.js management
2. **Global PM2**: `npm install -g pm2` for process management
3. **Port Management**: Use `lsof -ti:3000` to check port usage
4. **Clean Installs**: Remove `node_modules` and run `npm install` if issues persist

## 🆘 Emergency Commands

If nothing else works:
```bash
# Nuclear option - clean everything and restart
rm -rf node_modules backend/node_modules frontend/node_modules
npm install
npm run setup
npm run start:auto
```

Your server should now start successfully on macOS! 🎉