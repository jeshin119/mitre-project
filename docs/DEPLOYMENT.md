# 🚀 Deployment Guide

## Production Deployment

### Docker Deployment (Recommended)

```bash
# Production build and deploy
npm run docker:prod

# Or manually
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
```

### Manual Deployment

1. **Build the application**:
```bash
NODE_ENV=production npm run build
```

2. **Start production servers**:
```bash
NODE_ENV=production npm start
```

### Environment Configuration

For production, update `.env`:

```env
NODE_ENV=production
BACKEND_PORT=3000
FRONTEND_PORT=5173

# Security (CHANGE THESE!)
JWT_SECRET=your-production-jwt-secret-here
SESSION_SECRET=your-production-session-secret-here

# Performance
RATE_LIMIT_ENABLED=true
HTTPS_ENABLED=true
```

## Security Considerations

⚠️ **IMPORTANT**: This is an educational security testing platform with intentional vulnerabilities.

### For Educational Use Only
- Contains intentional security flaws
- Do NOT deploy to production internet
- Use in isolated environments only
- Review code for learning purposes

### Production Hardening (If Needed)
1. Remove intentional vulnerabilities
2. Enable proper authentication
3. Add input validation
4. Implement rate limiting
5. Use HTTPS everywhere
6. Regular security updates

## Infrastructure Requirements

### Minimum Resources
- **CPU**: 2 cores
- **Memory**: 2GB RAM
- **Storage**: 10GB SSD
- **Network**: 1Gbps

### Recommended Resources
- **CPU**: 4 cores
- **Memory**: 4GB RAM  
- **Storage**: 20GB SSD
- **Network**: Load balancer

### Database
- SQLite (development)
- PostgreSQL/MySQL (production)
- MongoDB (if needed)

## Monitoring & Logs

### Log Locations
```
logs/                # Application logs
backend/logs/        # Backend specific
frontend/logs/       # Frontend specific
```

### Health Checks
- Backend: `GET /api/health`
- Frontend: `GET /` (status 200)

### Performance Monitoring
- Response time tracking
- Error rate monitoring
- Resource usage alerts

## Backup & Recovery

### Database Backup
```bash
# Backup SQLite
cp database/app.sqlite backup/app-$(date +%Y%m%d).sqlite

# Backup with Docker
docker-compose exec database cp /data/app.sqlite /backup/
```

### Full Backup
```bash
# Application + data
tar -czf vintage-market-backup-$(date +%Y%m%d).tar.gz \
  --exclude=node_modules \
  --exclude=.git \
  .
```