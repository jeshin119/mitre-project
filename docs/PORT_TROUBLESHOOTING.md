# 🔧 Port Conflict Resolution Guide

This guide helps you resolve port conflicts when starting the Vintage Market server.

## Quick Solutions

### 🚀 Automatic Resolution (Recommended)
```bash
# Windows
npm run start:auto

# Unix/macOS/Linux
npm run start:auto
```

### 🧹 Clean & Start
```bash
npm run fix:port
```

## Manual Port Management

### Check Port Status
```bash
# Check if port 3000 is available
npm run port:check 3000

# Get detailed port information
npm run port:info 3000
```

### Find Available Port
```bash
# Find next available port starting from 3000
npm run port:find 3000
```

### Kill Conflicting Processes

#### Windows
```batch
# Find processes using port 3000
netstat -ano | findstr :3000

# Kill specific process (replace PID with actual process ID)
taskkill /PID [PID] /F

# Or use our utility
npm run port:kill 3000
```

#### macOS/Linux
```bash
# Find processes using port 3000
lsof -ti:3000

# Kill processes using port 3000
kill -9 $(lsof -ti:3000)

# Or use our utility
npm run port:kill 3000

# Interactive helper (macOS/Linux)
./fix-port-macos.sh
```

### Clean Multiple Ports
```bash
# Clean common development ports
npm run clean:ports

# Clean specific ports
npm run ports clean 3000 8000 8080
```

## Port Management Commands

| Command | Description | Example |
|---------|-------------|---------|
| `npm run ports check <port>` | Check if port is available | `npm run ports check 3000` |
| `npm run ports kill <port>` | Kill processes using port | `npm run ports kill 3000` |
| `npm run ports find <start>` | Find available port | `npm run ports find 3000` |
| `npm run ports info <port>` | Show port information | `npm run ports info 3000` |
| `npm run ports clean` | Clean common dev ports | `npm run ports clean` |
| `npm run ports resolve <port>` | Resolve port conflicts | `npm run ports resolve 3000` |

## Environment Variables

### Set Alternative Port
```bash
# Windows
set PORT=3001 && npm start

# Unix/macOS/Linux
PORT=3001 npm start
```

### Permanent Port Configuration
Edit `.env` file:
```env
PORT=3001
AUTO_RESOLVE_PORT=true
```

## Common Port Conflicts

### Port 3000 Conflicts
**Common causes:**
- React development server
- Other Node.js applications
- System services

**Solutions:**
1. Use automatic resolution: `npm run start:auto`
2. Use alternative port: `PORT=3001 npm start`
3. Kill conflicting process: `npm run port:kill 3000`

### Multiple Port Conflicts
**When multiple ports are occupied:**
```bash
# Clean all common development ports
npm run clean:ports

# Or specify specific ports
npm run ports clean 3000 3001 8000 8080
```

## Platform-Specific Issues

### Windows Issues
- **EADDRINUSE Error**: Use `npm run start:auto`
- **Permission Denied**: Run as Administrator
- **Antivirus Blocking**: Add project folder to exclusions

### macOS Issues
- **Missing cross-env**: Install dependencies: `npm install`
- **Port Permission**: Ports below 1024 require sudo
- **Firewall Blocking**: Check System Preferences > Security & Privacy
- **Interactive Helper**: Use `./fix-port-macos.sh` for guided resolution

### Linux Issues
- **Port Permission**: Use ports above 1024 for non-root users
- **Systemd Services**: Check for conflicting system services

## Advanced Troubleshooting

### Debug Port Issues
```bash
# Show detailed port information
npm run port:info 3000

# List all listening processes
# Windows
netstat -ano | findstr LISTENING

# Unix/macOS/Linux
netstat -tuln | grep LISTEN
```

### Automated Resolution Script
```bash
# Automatically resolve conflicts and start server
npm run fix:port
```

### PM2 Process Management
```bash
# Check PM2 processes
pm2 list

# Stop all PM2 processes
pm2 kill

# Restart with clean state
npm run pm2:start
```

## Prevention Tips

1. **Use Unique Ports**: Choose ports like 3001, 3002 for different projects
2. **Environment Configuration**: Set `PORT` in `.env` file
3. **Process Cleanup**: Always stop services when done
4. **Port Monitoring**: Use `npm run port:check` before starting

## Integration with Development Workflow

### VS Code Tasks
Add to `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start with Auto Port",
      "type": "shell",
      "command": "npm run start:auto",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      }
    }
  ]
}
```

### Package.json Scripts Integration
The following scripts are already configured:
- `start:auto` - Start with automatic port resolution
- `fix:port` - Clean ports and start with auto-resolution
- `clean:ports` - Clean common development ports
- `port:*` - Various port management utilities

## Support

If you continue to experience port conflicts:

1. **Check the logs** for specific error messages
2. **Use verbose mode**: `DEBUG=* npm run start:auto`
3. **Try different ports**: `PORT=8080 npm start`
4. **Restart your system** if all else fails

For persistent issues, refer to the main README.md or create an issue in the project repository.