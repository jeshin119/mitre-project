# 🚀 Full-Stack Execution Guide

이 가이드는 Vintage Market 애플리케이션의 백엔드와 프론트엔드를 함께 실행하는 방법을 설명합니다.

## 🎯 Quick Start (권장)

### 전체 애플리케이션 실행
```bash
# Windows
./start.bat

# macOS/Linux
./start.sh

# 또는 직접 명령어
npm run start:fullstack
```

이 명령어는 다음을 자동으로 수행합니다:
- ✅ 백엔드 서버 시작 (Express API)
- ✅ 프론트엔드 서버 시작 (Vite React)
- ✅ 포트 충돌 자동 해결
- ✅ 서버 간 통신 설정

## 📋 사용 가능한 포트

### 기본 포트 설정
- **백엔드 API**: `http://localhost:3000`
- **프론트엔드 웹**: `http://localhost:5173`

### 포트 충돌 시 자동 대체
- 백엔드: 3000 → 3001, 3002, ...
- 프론트엔드: 5173 → 5174, 5175, ...

## 🛠️ 개별 서버 실행

### 백엔드만 실행
```bash
# 자동 포트 해결
npm run start:backend

# 또는 기본 실행
npm start
```

### 프론트엔드만 실행
```bash
npm run start:frontend
```

## 🔧 개발 모드

### 전체 개발 환경
```bash
npm run dev  # start:fullstack와 동일
```

### 개별 개발 서버
```bash
# 백엔드 개발 서버 (nodemon)
npm run dev:backend

# 프론트엔드 개발 서버 (Vite HMR)
npm run dev:frontend
```

## ⚙️ PM2 프로세스 관리

### PM2로 백그라운드 실행
```bash
# 백엔드 + 프론트엔드 모두 시작
npm run pm2:start

# 상태 확인
pm2 status

# 로그 확인
npm run pm2:logs

# 개별 로그 확인
npm run pm2:logs:backend
npm run pm2:logs:frontend

# 중지
npm run pm2:stop

# 재시작
npm run pm2:restart
```

## 🌐 접속 URL 정보

실행 완료 후 표시되는 URL들:

```
╔════════════════════════════════════════════════════╗
║   🎉 Vintage Market Full-Stack Server Running    ║
║                                                    ║
║   🔧 Backend API Server                           ║
║   • Port: 3000                                    ║
║   • Local: http://localhost:3000                  ║
║   • Health: http://localhost:3000/api/health      ║
║                                                    ║
║   🎨 Frontend Web Application                     ║
║   • Port: 5173                                   ║
║   • Local: http://localhost:5173                 ║
║   • Network: http://0.0.0.0:5173               ║
║                                                    ║
║   📋 API Endpoints:                               ║
║   • Users: /api/users                             ║
║   • Products: /api/products                       ║
║   • Auth: /api/auth                               ║
║                                                    ║
╚════════════════════════════════════════════════════╝
```

## 🔍 문제 해결

### 포트 충돌 문제
```bash
# 포트 상태 확인
npm run port:check 3000
npm run port:check 5173

# 충돌 프로세스 종료
npm run port:kill 3000
npm run port:kill 5173

# 모든 포트 정리
npm run clean:ports

# 강제 재시작
npm run fix:port
```

### macOS에서 cross-env 오류
```bash
# 의존성 재설치
npm install

# 또는 네이티브 스크립트 사용
node scripts/start-fullstack.js
```

### 개별 서버 디버깅
```bash
# 백엔드 단독 테스트
curl http://localhost:3000/api/health

# 프론트엔드 접속 확인
curl http://localhost:5173
```

## 📚 추가 명령어

### 빌드 및 배포
```bash
# 전체 빌드
npm run build

# 프론트엔드만 빌드
npm run build:frontend

# 프로덕션 미리보기
cd frontend && npm run preview
```

### 데이터베이스 관리
```bash
# 데이터베이스 재설정
npm run seed

# 데이터베이스 정리
npm run clean:db
```

### 로그 관리
```bash
# 로그 정리
npm run clean:logs

# PM2 모니터링
npm run pm2:monitor
```

## ⚠️ 주의사항

1. **교육용 플랫폼**: 이 애플리케이션은 보안 취약점을 포함한 교육용입니다
2. **방화벽 설정**: 로컬 방화벽에서 포트 접근을 허용해야 할 수 있습니다
3. **Node.js 버전**: Node.js 18.0.0 이상 필요
4. **메모리 사용량**: 개발 서버 2개가 동시에 실행되므로 메모리 사용량이 증가합니다

## 🆘 응급 복구

모든 것이 작동하지 않을 때:

```bash
# 완전 초기화
npm run clean
rm -rf node_modules backend/node_modules frontend/node_modules
npm install
npm run setup
npm run start:fullstack
```

이제 `./start.sh` 또는 `npm run start:fullstack` 명령어로 백엔드와 프론트엔드를 모두 실행할 수 있습니다! 🎉