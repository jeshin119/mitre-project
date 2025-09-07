# 🔒 보안 패치 가이드

## 개요
이 가이드는 Vintage Market 플랫폼의 취약점을 해결하는 방법을 설명합니다.
실습을 완료한 후 이 가이드를 따라 보안 패치를 적용하세요.

---

## 1. SQL Injection 패치

### 문제점
```javascript
// 취약한 코드 - /backend/src/routes/products.js
const query = `SELECT * FROM products WHERE title LIKE '%${searchTerm}%'`;
db.query(query);
```

### 해결방안
```javascript
// 안전한 코드 - Prepared Statements 사용
const query = 'SELECT * FROM products WHERE title LIKE ?';
db.query(query, [`%${searchTerm}%`]);

// 또는 ORM 사용 (Sequelize 예시)
const products = await Product.findAll({
    where: {
        title: {
            [Op.like]: `%${searchTerm}%`
        }
    }
});
```

### 추가 보안 조치
```javascript
// 입력 검증 및 sanitization
const validator = require('validator');

function validateSearchTerm(searchTerm) {
    if (!searchTerm || typeof searchTerm !== 'string') {
        throw new Error('Invalid search term');
    }
    
    // 길이 제한
    if (searchTerm.length > 100) {
        throw new Error('Search term too long');
    }
    
    // 특수문자 검증
    if (!validator.isAlphanumeric(searchTerm, 'ko-KR', {ignore: ' '})) {
        throw new Error('Invalid characters in search term');
    }
    
    return validator.escape(searchTerm);
}
```

---

## 2. XSS 방지

### 문제점
```javascript
// 취약한 코드
res.send(`<h1>Search results for: ${searchTerm}</h1>`);
```

### 해결방안
```javascript
// 서버 사이드 - HTML 이스케이핑
const escapeHtml = require('escape-html');
res.send(`<h1>Search results for: ${escapeHtml(searchTerm)}</h1>`);

// 클라이언트 사이드 - React 자동 이스케이핑
function SearchResults({ searchTerm }) {
    return <h1>Search results for: {searchTerm}</h1>; // React가 자동 이스케이핑
}

// DOMPurify 사용 (사용자 HTML 입력이 필요한 경우)
import DOMPurify from 'dompurify';
const cleanHtml = DOMPurify.sanitize(userInput);
```

### Content Security Policy (CSP) 설정
```javascript
// helmet 미들웨어 사용
const helmet = require('helmet');

app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'", "'unsafe-inline'"], // 개발환경에서만
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https:"],
            objectSrc: ["'none'"],
            upgradeInsecureRequests: []
        }
    }
}));
```

---

## 3. 안전한 인증 시스템

### 패스워드 해싱 개선
```javascript
// 취약한 코드
const crypto = require('crypto');
const hashedPassword = crypto.createHash('md5').update(password).digest('hex');

// 안전한 코드 - bcrypt 사용
const bcrypt = require('bcryptjs');

// 회원가입시
const saltRounds = 12;
const hashedPassword = await bcrypt.hash(password, saltRounds);

// 로그인시
const isValid = await bcrypt.compare(password, hashedPassword);
```

### JWT 보안 강화
```javascript
// 안전한 JWT 구성
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

// 강력한 시크릿 키 생성
const JWT_SECRET = crypto.randomBytes(64).toString('hex');

// JWT 생성 (짧은 만료시간)
const token = jwt.sign(
    { userId: user.id, role: user.role },
    JWT_SECRET,
    { 
        expiresIn: '15m',
        issuer: 'vintage-market',
        audience: 'vintage-market-users'
    }
);

// Refresh Token 패턴 구현
const refreshToken = crypto.randomBytes(64).toString('hex');
// 데이터베이스에 저장하여 관리
```

### 세션 보안
```javascript
const session = require('express-session');
const MongoStore = require('connect-mongo');

app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    store: MongoStore.create({
        mongoUrl: process.env.MONGODB_URI
    }),
    cookie: {
        secure: process.env.NODE_ENV === 'production', // HTTPS only in production
        httpOnly: true, // XSS 방지
        maxAge: 1000 * 60 * 30, // 30분
        sameSite: 'strict' // CSRF 방지
    },
    name: 'sessionId' // 기본 이름 변경
}));
```

---

## 4. 파일 업로드 보안

### 안전한 파일 업로드
```javascript
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');

// 안전한 파일 업로드 설정
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, './uploads/');
    },
    filename: (req, file, cb) => {
        // 안전한 파일명 생성
        const uniqueName = crypto.randomUUID() + path.extname(file.originalname);
        cb(null, uniqueName);
    }
});

// 파일 필터링
const fileFilter = (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    
    const ext = path.extname(file.originalname).toLowerCase();
    
    if (allowedTypes.includes(file.mimetype) && allowedExtensions.includes(ext)) {
        cb(null, true);
    } else {
        cb(new Error('Invalid file type'), false);
    }
};

const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB 제한
    }
});

// 파일 검증 미들웨어
const validateFile = async (req, res, next) => {
    if (req.file) {
        // 실제 파일 타입 검증 (magic number 확인)
        const FileType = await import('file-type');
        const fileTypeResult = await FileType.fileTypeFromFile(req.file.path);
        
        const allowedMimes = ['image/jpeg', 'image/png', 'image/gif'];
        
        if (!fileTypeResult || !allowedMimes.includes(fileTypeResult.mime)) {
            // 위험한 파일 삭제
            fs.unlinkSync(req.file.path);
            return res.status(400).json({ error: 'Invalid file type' });
        }
    }
    next();
};
```

---

## 5. 비즈니스 로직 보안

### 가격 조작 방지
```javascript
// 클라이언트 측 가격 정보 제거
// 서버에서 가격 재확인
const purchaseProduct = async (req, res) => {
    const { productId, quantity } = req.body;
    
    // 서버에서 실제 상품 정보 조회
    const product = await Product.findById(productId);
    if (!product) {
        return res.status(404).json({ error: 'Product not found' });
    }
    
    // 서버에서 최종 가격 계산
    const totalPrice = product.price * quantity;
    
    // 거래 생성
    const transaction = await Transaction.create({
        buyerId: req.user.id,
        sellerId: product.sellerId,
        productId: productId,
        quantity: quantity,
        amount: totalPrice // 서버에서 계산된 가격 사용
    });
    
    res.json(transaction);
};
```

### Race Condition 방지
```javascript
// 데이터베이스 트랜잭션 사용
const { sequelize } = require('./database');

const purchaseProduct = async (req, res) => {
    const t = await sequelize.transaction();
    
    try {
        // 락을 사용한 재고 확인
        const product = await Product.findByPk(productId, {
            lock: t.LOCK.UPDATE,
            transaction: t
        });
        
        if (product.stock < quantity) {
            await t.rollback();
            return res.status(400).json({ error: 'Insufficient stock' });
        }
        
        // 재고 차감
        await product.update(
            { stock: product.stock - quantity },
            { transaction: t }
        );
        
        // 거래 기록
        const transaction = await Transaction.create({
            // ... transaction data
        }, { transaction: t });
        
        await t.commit();
        res.json(transaction);
        
    } catch (error) {
        await t.rollback();
        throw error;
    }
};
```

---

## 6. 민감한 데이터 보호

### 데이터 암호화
```javascript
const crypto = require('crypto');

class DataEncryption {
    constructor() {
        this.algorithm = 'aes-256-gcm';
        this.secretKey = process.env.ENCRYPTION_KEY; // 32 bytes
    }
    
    encrypt(text) {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipher(this.algorithm, this.secretKey);
        cipher.setAAD(Buffer.from('vintage-market'));
        
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        
        const authTag = cipher.getAuthTag();
        
        return {
            encrypted,
            iv: iv.toString('hex'),
            authTag: authTag.toString('hex')
        };
    }
    
    decrypt(encryptedData) {
        const decipher = crypto.createDecipher(this.algorithm, this.secretKey);
        decipher.setAAD(Buffer.from('vintage-market'));
        decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
        
        let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        
        return decrypted;
    }
}

// 사용 예시 - 민감한 데이터 저장시
const encryption = new DataEncryption();
const encryptedSSN = encryption.encrypt(user.ssn);

// 데이터베이스에는 암호화된 데이터 저장
await User.update({
    ssn_encrypted: JSON.stringify(encryptedSSN)
}, {
    where: { id: user.id }
});
```

---

## 7. 입력 검증 및 Sanitization

### 종합적인 입력 검증
```javascript
const { body, validationResult } = require('express-validator');
const DOMPurify = require('isomorphic-dompurify');

// 검증 규칙 정의
const productValidation = [
    body('title')
        .isLength({ min: 1, max: 255 })
        .withMessage('Title must be between 1 and 255 characters')
        .matches(/^[a-zA-Z0-9가-힣\s\-_]+$/)
        .withMessage('Title contains invalid characters'),
    
    body('description')
        .isLength({ max: 2000 })
        .withMessage('Description too long')
        .customSanitizer(value => {
            return DOMPurify.sanitize(value);
        }),
    
    body('price')
        .isFloat({ min: 0 })
        .withMessage('Price must be a positive number')
        .toFloat(),
    
    body('category')
        .isIn(['electronics', 'clothing', 'books', 'home', 'sports'])
        .withMessage('Invalid category')
];

// 검증 결과 처리
const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ 
            error: 'Validation failed',
            details: errors.array()
        });
    }
    next();
};

// 라우트에 적용
router.post('/products', 
    productValidation,
    handleValidationErrors,
    createProduct
);
```

---

## 8. 로깅 및 모니터링

### 보안 이벤트 로깅
```javascript
const winston = require('winston');

// 보안 로거 설정
const securityLogger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
    ),
    transports: [
        new winston.transports.File({ 
            filename: 'security.log',
            maxsize: 5242880, // 5MB
            maxFiles: 10
        })
    ]
});

// 보안 이벤트 로깅 함수
const logSecurityEvent = (event, req, additional = {}) => {
    securityLogger.info({
        event: event,
        timestamp: new Date().toISOString(),
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        userId: req.user?.id,
        sessionId: req.sessionID,
        ...additional
    });
};

// 사용 예시
app.use('/api', (req, res, next) => {
    // 의심스러운 요청 탐지
    if (req.body && typeof req.body === 'string' && 
        req.body.includes('script') || req.body.includes('SELECT')) {
        
        logSecurityEvent('SUSPICIOUS_INPUT', req, {
            payload: req.body.substring(0, 500)
        });
    }
    next();
});
```

---

## 9. 환경 설정 보안

### 프로덕션 환경 설정
```javascript
// config/production.js
module.exports = {
    database: {
        host: process.env.DB_HOST,
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        dialect: 'mysql',
        logging: false, // 프로덕션에서는 쿼리 로깅 비활성화
        ssl: true,
        dialectOptions: {
            ssl: {
                require: true,
                rejectUnauthorized: false
            }
        }
    },
    
    session: {
        secret: process.env.SESSION_SECRET,
        secure: true, // HTTPS only
        httpOnly: true,
        sameSite: 'strict'
    },
    
    security: {
        enableCSRFProtection: true,
        enableRateLimiting: true,
        maxRequestsPerMinute: 100
    }
};
```

### .env 보안 설정
```bash
# 강력한 비밀키들
JWT_SECRET=복잡하고_긴_랜덤한_문자열_최소_64자
SESSION_SECRET=또다른_복잡한_랜덤_문자열
ENCRYPTION_KEY=32바이트의_AES_키

# 데이터베이스 보안
DB_HOST=secure.database.host
DB_PASSWORD=강력한_데이터베이스_패스워드

# 보안 설정
NODE_ENV=production
BCRYPT_ROUNDS=12
COOKIE_SECURE=true
ENABLE_HTTPS=true

# 기능 비활성화
ENABLE_SQL_INJECTION=false
ENABLE_XSS=false
ENABLE_CSRF=true
DISABLE_RATE_LIMITING=false
ALLOW_UNSAFE_UPLOADS=false
```

---

## 10. 정기 보안 점검

### 보안 체크리스트
- [ ] 모든 사용자 입력에 대한 검증 및 sanitization
- [ ] SQL 쿼리에 Prepared Statements 사용
- [ ] 파일 업로드 시 적절한 검증
- [ ] 강력한 패스워드 해싱 (bcrypt, scrypt 등)
- [ ] HTTPS 사용
- [ ] 적절한 CSP 헤더 설정
- [ ] 세션 보안 설정
- [ ] 민감한 데이터 암호화
- [ ] 적절한 에러 처리
- [ ] 보안 로깅 구현
- [ ] 정기적인 의존성 업데이트
- [ ] 보안 테스트 자동화

### 자동화된 보안 검사
```bash
# 의존성 취약점 검사
npm audit
npm audit fix

# 코드 보안 검사
npm install -g eslint-plugin-security
eslint --ext .js src/ --plugin security

# SAST 도구 사용
npx semgrep --config=auto src/
```

이 가이드를 따라 단계별로 보안 패치를 적용하면 안전한 애플리케이션으로 변환할 수 있습니다.