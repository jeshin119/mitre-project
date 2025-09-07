# 🚀 Vintage Market - 빠른 시작 가이드

## ⚡ 원클릭 실행

### 🍎 macOS / 🐧 Linux
```bash
./start.sh
```

### 🪟 Windows
```cmd
start.bat
```

### 🌐 모든 플랫폼 (Node.js)
```bash
npm run setup && npm start
```

---

## 📊 실행 확인

서버가 시작되면 다음 URL들을 확인하세요:

- **🏠 홈**: http://localhost:3000
- **🔧 API**: http://localhost:3000/api
- **💊 헬스체크**: http://localhost:3000/api/health
- **👥 사용자**: http://localhost:3000/api/users
- **📦 상품**: http://localhost:3000/api/products

---

## 🛠️ 문제 해결

### 포트 충돌 시
```bash
# 다른 포트로 실행
PORT=3001 npm start
```

### 데이터 없을 시
```bash
npm run seed
```

### 완전 재시작
```bash
npm run clean && npm run setup && npm start
```

---

## 📞 지원

문제 발생시 [PLATFORM_GUIDE.md](./PLATFORM_GUIDE.md)를 참조하세요.