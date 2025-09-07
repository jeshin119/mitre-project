# 🖥️ Vintage Market - 플랫폼별 실행 가이드

이 프로젝트는 **Windows**, **macOS**, **Linux**에서 모두 동일하게 작동하도록 설계되었습니다.

## 🚀 빠른 시작 (모든 플랫폼 공통)

```bash
# 1. 프로젝트 클론
git clone <repository-url>
cd vintage-market

# 2. 자동 설정 실행
npm run setup

# 3. 서버 시작
npm start
```

## 📱 플랫폼별 상세 가이드

### 🍎 **macOS**

#### 필수 요구사항
```bash
# Node.js 설치 확인
node --version  # v18.0.0 이상
npm --version

# 없다면 설치
brew install node
```

#### 실행 방법
```bash
# 방법 1: 직접 실행
npm run setup
npm start

# 방법 2: PM2 사용
npm run pm2:start

# 방법 3: Docker 사용
npm run docker:up
```

#### 포트 충돌 해결 (macOS)
```bash
# 포트 사용 프로세스 확인
lsof -i :3000

# Docker가 포트를 사용 중인 경우
docker stop $(docker ps -q)

# 프로세스 강제 종료
sudo kill -9 [PID]
```

---

### 🪟 **Windows**

#### 필수 요구사항
```cmd
# Node.js 설치 확인
node --version
npm --version

# 없다면 https://nodejs.org 에서 다운로드
```

#### 실행 방법
```cmd
# PowerShell 또는 Command Prompt에서

# 방법 1: 직접 실행
npm run setup
npm start

# 방법 2: PM2 사용
npm run pm2:start

# 방법 3: Docker 사용 (Docker Desktop 필요)
npm run docker:up
```

#### 포트 충돌 해결 (Windows)
```cmd
# 포트 사용 프로세스 확인
netstat -ano | findstr :3000

# 프로세스 강제 종료
taskkill /PID [PID] /F

# 또는 다른 포트 사용
set PORT=3001 && npm start
```

#### Windows 특별 주의사항
- **관리자 권한**으로 터미널 실행 권장
- **Windows Defender** 방화벽 예외 추가 필요할 수 있음
- **PowerShell** 사용 권장 (Command Prompt보다 안정적)

---

### 🐧 **Linux (Ubuntu/Debian)**

#### 필수 요구사항
```bash
# Node.js 설치
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 또는 snap 사용
sudo snap install node --classic
```

#### 실행 방법
```bash
# 방법 1: 직접 실행
npm run setup
npm start

# 방법 2: PM2 사용
npm run pm2:start

# 방법 3: Docker 사용
sudo npm run docker:up
```

#### 포트 충돌 해결 (Linux)
```bash
# 포트 사용 프로세스 확인
sudo netstat -tlnp | grep :3000

# 프로세스 강제 종료
sudo kill -9 [PID]
```

---

## 🛠️ 문제 해결 가이드

### 일반적인 문제들

#### 1. **포트 이미 사용 중**
```bash
# 모든 플랫폼 공통
npm run clean
PORT=3001 npm start
```

#### 2. **데이터베이스 빈 배열**
```bash
# 데이터베이스 재초기화
npm run clean:db
npm run seed
npm start
```

#### 3. **의존성 설치 실패**
```bash
# 캐시 정리 후 재설치
npm cache clean --force
npm run setup
```

#### 4. **PM2 관련 문제**
```bash
# PM2 완전 재시작
npm run pm2:stop
pm2 kill
npm run pm2:start
```

---

## 🔍 헬스 체크

서버가 정상적으로 실행되었는지 확인:

```bash
# API 헬스 체크
npm run health

# 또는 브라우저에서
# http://localhost:3000/api/health
# http://localhost:3000/api/users
```

---

## 🐳 Docker 사용 (권장)

모든 플랫폼에서 **동일한 환경**을 보장:

```bash
# Docker 설치 후
npm run docker:build

# 접속 URL
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
# phpMyAdmin: http://localhost:8080
```

---

## 📞 지원

문제가 발생하면:

1. **로그 확인**: `npm run pm2:logs` 또는 `docker-compose logs`
2. **헬스 체크**: `npm run health`
3. **완전 재시작**: `npm run clean && npm run setup && npm start`

---

## 🎯 요약

| 플랫폼 | 권장 방법 | 포트 확인 | 프로세스 종료 |
|--------|-----------|-----------|---------------|
| **macOS** | `npm start` | `lsof -i :3000` | `sudo kill -9 [PID]` |
| **Windows** | `npm start` | `netstat -ano \| findstr :3000` | `taskkill /PID [PID] /F` |
| **Linux** | `npm start` | `sudo netstat -tlnp \| grep :3000` | `sudo kill -9 [PID]` |
| **공통 (Docker)** | `npm run docker:up` | `docker-compose ps` | `docker-compose down` |