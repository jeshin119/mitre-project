# 🛠️ Development Guide - Vintage Market

## 🚀 Quick Start

### 1. Environment Setup
```bash
# Clone and setup
git clone <repository-url>
cd vintage-market

# Install dependencies and setup environment  
make setup
# or
npm install && npm run setup
```

### 2. Start Development
```bash
# Start both frontend and backend
make dev
# or
npm run dev

# Alternative: Start individually
npm run backend    # Backend only (port 3000)
npm run frontend   # Frontend only (port 5173)
```

### 3. Access Application
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **Health Check**: http://localhost:3000/api/health

## 📊 Test Accounts

The application comes with pre-seeded test data:

### User Accounts
| Email | Password | Role | Description |
|-------|----------|------|-------------|
| `admin@vintage-market.com` | `admin123` | admin | System administrator |
| `user1@test.com` | `password123` | user | Regular user (김철수) |
| `user2@test.com` | `test123` | user | Regular user (이영희) |
| `seller@marketplace.com` | `seller123` | user | Seller account (박상인) |
| `buyer@shop.com` | `buyer123` | user | Buyer account (최구매) |

### Sample Products
- 7 pre-loaded products across different categories
- Various conditions (new, good, fair)
- Different price ranges and locations

## 🏗️ Project Structure

```
vintage-market/
├── backend/                 # Express.js API Server
│   ├── src/
│   │   ├── config/         # Database & app configuration
│   │   ├── controllers/    # Route handlers
│   │   ├── middleware/     # Custom middleware
│   │   ├── models/         # Sequelize models
│   │   ├── routes/         # API routes
│   │   ├── scripts/        # Database seeding & migrations
│   │   ├── utils/          # Utility functions
│   │   └── server.js       # Main server file
│   ├── uploads/            # File upload directory
│   ├── logs/               # Server logs
│   └── database/           # SQLite database files
├── frontend/               # React + Vite Web App
│   ├── src/
│   │   ├── components/     # Reusable React components
│   │   ├── pages/          # Page components
│   │   ├── hooks/          # Custom React hooks
│   │   ├── services/       # API service functions
│   │   ├── utils/          # Utility functions
│   │   └── App.jsx         # Main app component
│   └── public/             # Static assets
├── scripts/                # Build & utility scripts
├── docs/                   # Documentation
└── docker/                 # Docker configurations
```

## 🔧 Configuration

### Environment Variables

The application uses a unified `.env` file in the root directory:

```env
# Environment
NODE_ENV=development

# Server Ports  
PORT=3000                    # Backend port
BACKEND_PORT=3000
FRONTEND_PORT=5173

# API Configuration
VITE_API_URL=http://localhost:3000
FRONTEND_URL=http://localhost:5173

# Database
DB_PATH=./database/app.sqlite

# Security (Intentionally Weak)
JWT_SECRET=your-super-secret-jwt-key-change-in-production
SESSION_SECRET=your-session-secret-change-in-production

# Upload Configuration
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760

# Development Settings
DEBUG=vintage-market:*
AUTO_RESOLVE_PORT=true
```

### Backend Configuration
The backend also has its own `.env` file with additional settings for development purposes.

## 🗄️ Database

### SQLite Development Database
- **Location**: `./backend/database/app.sqlite`
- **Models**: Users, Products, Transactions, Messages
- **Seeding**: Automatic on first setup

### Database Operations
```bash
# Seed database with test data
npm run db:seed

# Reset database (drop + recreate + seed)
npm run db:reset

# Manual database operations
npm run --workspace=backend seed
```

## 🛠️ Development Workflow

### 1. Making Changes
- Backend changes trigger automatic restart (nodemon)
- Frontend changes trigger hot module replacement (Vite HMR)
- No manual restarts needed during development

### 2. Adding Dependencies
```bash
# Root level dependencies
npm install <package>

# Backend dependencies
npm install <package> --workspace=backend

# Frontend dependencies  
npm install <package> --workspace=frontend
```

### 3. Database Schema Changes
1. Update models in `backend/src/models/`
2. Run `npm run db:reset` to apply changes
3. Update seed data in `backend/src/scripts/seedData.js` if needed

## 🧪 Testing

### API Testing
```bash
# Health check
curl http://localhost:3000/api/health

# List users
curl http://localhost:3000/api/users

# List products
curl http://localhost:3000/api/products
```

### Frontend Testing
```bash
# Run frontend tests
npm run test --workspace=frontend

# Run all workspace tests
npm test
```

## 🐛 Debugging

### Backend Debugging
- Logs are available in `./backend/logs/`
- Use `DEBUG=vintage-market:*` environment variable
- SQL queries are logged in development mode

### Frontend Debugging
- React DevTools recommended
- Vite provides detailed error overlay
- API calls visible in browser Network tab

### Common Issues

#### Port Conflicts
```bash
# Check port availability
make port-check

# Clean conflicting processes
make port-clean
```

#### Database Issues
```bash
# Reset database completely
make db-reset

# Clean all runtime files
make clean
```

#### Permission Issues
```bash
# Fix file permissions
chmod +x scripts/*.js
```

## 📱 Process Management

### Development (PM2)
The application uses PM2 for process management:

```bash
# Check running processes
npx pm2 status

# View logs
npx pm2 logs --nostream

# Restart services
npx pm2 restart all

# Stop services
npx pm2 stop all
```

### Process Configuration
- **Backend**: Node.js with auto-restart on file changes
- **Frontend**: Vite dev server with HMR
- **Logs**: Centralized in `./logs/` directory

## 🔒 Security Features (Educational)

This platform includes intentional vulnerabilities for learning:

### Backend Vulnerabilities
- SQL Injection in user queries
- XSS vulnerabilities in product descriptions
- Weak JWT implementation
- Insecure file upload handling
- Information disclosure in error messages

### Frontend Vulnerabilities  
- DOM XSS possibilities
- Insecure local storage usage
- CSRF vulnerabilities
- Client-side validation bypasses

## 🎯 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### Users
- `GET /api/users` - List all users
- `GET /api/users/:id` - Get user details
- `PUT /api/users/:id` - Update user

### Products  
- `GET /api/products` - List products
- `POST /api/products` - Create product
- `GET /api/products/:id` - Get product details
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

### Utilities
- `GET /api/health` - Health check endpoint

## 🚢 Production Considerations

While this is an educational platform, for production deployment:

1. **Security Hardening**: Fix all intentional vulnerabilities
2. **Database**: Switch to PostgreSQL or MySQL
3. **Environment**: Use proper production environment variables
4. **Monitoring**: Implement proper logging and monitoring
5. **Performance**: Enable caching and optimization

---

**Remember**: This is an educational platform with intentional security vulnerabilities. Never deploy to production without proper security hardening.