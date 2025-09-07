#!/bin/bash

# Vintage Market 보안 테스트 자동화 스크립트
# 취약점 검증을 위한 자동화된 테스트 도구

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 기본 설정
API_BASE="http://localhost:5000/api"
WEB_BASE="http://localhost:3000"
TARGET_HOST="localhost"

# 로그 파일
LOG_FILE="./security_test_results.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 함수 정의
print_header() {
    echo -e "\n${BLUE}[TEST]${NC} $1"
    echo "[${TIMESTAMP}] TEST: $1" >> "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    echo "[${TIMESTAMP}] PASS: $1" >> "$LOG_FILE"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo "[${TIMESTAMP}] FAIL: $1" >> "$LOG_FILE"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
    echo "[${TIMESTAMP}] INFO: $1" >> "$LOG_FILE"
}

# 서버 상태 확인
check_server_status() {
    print_header "서버 상태 확인"
    
    if curl -s "$API_BASE/health" > /dev/null; then
        print_success "API 서버가 실행 중입니다"
    else
        print_fail "API 서버에 연결할 수 없습니다"
        exit 1
    fi
    
    if curl -s "$WEB_BASE" > /dev/null; then
        print_success "웹 서버가 실행 중입니다"
    else
        print_fail "웹 서버에 연결할 수 없습니다"
    fi
}

# SQL Injection 테스트
test_sql_injection() {
    print_header "SQL Injection 테스트"
    
    # 기본 SQL Injection 페이로드들
    local payloads=(
        "' OR 1=1 --"
        "'; DROP TABLE users; --"
        "' UNION SELECT 1,username,password FROM users --"
        "admin'--"
    )
    
    for payload in "${payloads[@]}"; do
        print_info "테스트 페이로드: $payload"
        
        # 로그인 SQL Injection 테스트
        response=$(curl -s -X POST "$API_BASE/auth/login" \
            -H "Content-Type: application/json" \
            -d "{\"username\":\"$payload\",\"password\":\"test\"}" \
            -w "%{http_code}")
        
        if [[ "$response" == *"200"* ]] || [[ "$response" == *"token"* ]]; then
            print_fail "SQL Injection 취약점 발견 (로그인)"
        else
            print_info "로그인 SQL Injection 차단됨"
        fi
        
        # 검색 SQL Injection 테스트
        search_response=$(curl -s "$API_BASE/products/search?q=$payload" -w "%{http_code}")
        
        if [[ "$search_response" == *"error"* ]] && [[ "$search_response" == *"SQL"* ]]; then
            print_fail "SQL Injection 에러 메시지 노출"
        fi
    done
}

# XSS 테스트
test_xss() {
    print_header "XSS (Cross-Site Scripting) 테스트"
    
    local xss_payloads=(
        "<script>alert('XSS')</script>"
        "<img src=x onerror=alert('XSS')>"
        "javascript:alert('XSS')"
        "<svg onload=alert('XSS')>"
    )
    
    for payload in "${xss_payloads[@]}"; do
        print_info "XSS 페이로드 테스트: $payload"
        
        # 댓글에 XSS 페이로드 삽입 시도
        response=$(curl -s -X POST "$API_BASE/comments" \
            -H "Content-Type: application/json" \
            -d "{\"content\":\"$payload\",\"product_id\":1}" \
            -w "%{http_code}")
        
        if [[ "$response" == *"200"* ]] || [[ "$response" == *"201"* ]]; then
            print_fail "XSS 페이로드가 저장됨 - Stored XSS 취약점"
        fi
        
        # 검색에서 Reflected XSS 테스트
        search_response=$(curl -s "$WEB_BASE/search?q=$payload")
        
        if [[ "$search_response" == *"$payload"* ]]; then
            print_fail "Reflected XSS 취약점 발견"
        fi
    done
}

# 파일 업로드 테스트
test_file_upload() {
    print_header "파일 업로드 취약점 테스트"
    
    # 위험한 파일 확장자들
    local dangerous_files=(
        "shell.php"
        "backdoor.jsp"
        "webshell.asp"
        "malware.exe"
        "script.js"
    )
    
    for file in "${dangerous_files[@]}"; do
        print_info "위험한 파일 업로드 테스트: $file"
        
        # 임시 파일 생성
        echo "<?php system(\$_GET['cmd']); ?>" > "/tmp/$file"
        
        # 파일 업로드 시도
        response=$(curl -s -X POST "$API_BASE/upload" \
            -F "file=@/tmp/$file" \
            -w "%{http_code}")
        
        if [[ "$response" == *"200"* ]] || [[ "$response" == *"success"* ]]; then
            print_fail "위험한 파일 업로드 허용됨: $file"
        else
            print_success "위험한 파일 업로드 차단됨: $file"
        fi
        
        # 임시 파일 삭제
        rm -f "/tmp/$file"
    done
    
    # Path Traversal 테스트
    print_info "Path Traversal 테스트"
    local path_payloads=(
        "../../../etc/passwd"
        "..\\..\\..\\windows\\system32\\drivers\\etc\\hosts"
        "....//....//....//etc//passwd"
    )
    
    for payload in "${path_payloads[@]}"; do
        response=$(curl -s "$API_BASE/uploads/$payload")
        
        if [[ "$response" == *"root:"* ]] || [[ "$response" == *"bin:"* ]]; then
            print_fail "Path Traversal 취약점 발견"
        fi
    done
}

# 인증 우회 테스트
test_authentication_bypass() {
    print_header "인증 우회 테스트"
    
    # JWT 토큰 조작 테스트
    print_info "JWT 토큰 조작 테스트"
    
    # 약한 시크릿으로 JWT 생성 시도
    weak_secrets=("secret" "123456" "admin" "password" "jwt" "key")
    
    for secret in "${weak_secrets[@]}"; do
        # JWT 생성 시도 (실제로는 외부 도구 필요)
        print_info "약한 시크릿 테스트: $secret"
    done
    
    # 세션 고정 공격 테스트
    print_info "세션 고정 공격 테스트"
    
    # 로그인 전 쿠키 확인
    session_before=$(curl -s -c cookies.txt "$WEB_BASE/login" | grep -o 'sessionId=[^;]*' || echo "")
    
    # 로그인 수행
    curl -s -b cookies.txt -c cookies.txt \
        -X POST "$API_BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"username":"testuser","password":"password"}' > /dev/null
    
    # 로그인 후 쿠키 확인
    session_after=$(curl -s -b cookies.txt "$WEB_BASE/" | grep -o 'sessionId=[^;]*' || echo "")
    
    if [[ "$session_before" == "$session_after" ]] && [[ -n "$session_before" ]]; then
        print_fail "세션 고정 취약점 발견"
    else
        print_success "세션 고정 공격 차단됨"
    fi
    
    rm -f cookies.txt
}

# 비즈니스 로직 테스트
test_business_logic() {
    print_header "비즈니스 로직 취약점 테스트"
    
    # 가격 조작 테스트
    print_info "가격 조작 테스트"
    
    # 음수 가격으로 상품 구매 시도
    response=$(curl -s -X POST "$API_BASE/purchase" \
        -H "Content-Type: application/json" \
        -d '{"product_id":1,"price":-100}' \
        -w "%{http_code}")
    
    if [[ "$response" == *"200"* ]]; then
        print_fail "음수 가격으로 구매 가능 - 가격 조작 취약점"
    fi
    
    # Race Condition 테스트
    print_info "Race Condition 테스트"
    
    # 동시에 여러 구매 요청 (백그라운드에서 실행)
    for i in {1..5}; do
        curl -s -X POST "$API_BASE/purchase" \
            -H "Content-Type: application/json" \
            -d '{"product_id":1,"quantity":1}' &
    done
    wait
    
    # 쿠폰 남용 테스트
    print_info "쿠폰 남용 테스트"
    
    # 동일한 쿠폰으로 여러 번 할인 시도
    for i in {1..3}; do
        response=$(curl -s -X POST "$API_BASE/coupon/apply" \
            -H "Content-Type: application/json" \
            -d '{"code":"WELCOME10","product_id":1}' \
            -w "%{http_code}")
        
        if [[ "$response" == *"200"* ]]; then
            print_info "쿠폰 사용 횟수: $i"
        fi
    done
}

# 정보 노출 테스트
test_information_disclosure() {
    print_header "정보 노출 테스트"
    
    # 에러 메시지 분석
    print_info "상세한 에러 메시지 확인"
    
    # 존재하지 않는 엔드포인트 접근
    error_response=$(curl -s "$API_BASE/nonexistent" -w "%{http_code}")
    
    if [[ "$error_response" == *"stack"* ]] || [[ "$error_response" == *"trace"* ]]; then
        print_fail "상세한 스택 트레이스 노출"
    fi
    
    # 디렉토리 리스팅 확인
    print_info "디렉토리 리스팅 확인"
    
    dir_response=$(curl -s "$WEB_BASE/uploads/")
    
    if [[ "$dir_response" == *"Index of"* ]] || [[ "$dir_response" == *"Directory listing"* ]]; then
        print_fail "디렉토리 리스팅 활성화됨"
    fi
    
    # 백업 파일 확인
    print_info "백업 파일 노출 확인"
    
    backup_files=(
        ".env"
        ".env.backup"
        "config.php.bak"
        "database.sql"
        ".git/config"
    )
    
    for file in "${backup_files[@]}"; do
        response=$(curl -s "$WEB_BASE/$file" -w "%{http_code}")
        
        if [[ "${response: -3}" == "200" ]]; then
            print_fail "민감한 파일 노출: $file"
        fi
    done
}

# SSRF 테스트
test_ssrf() {
    print_header "SSRF (Server-Side Request Forgery) 테스트"
    
    local ssrf_payloads=(
        "http://169.254.169.254/latest/meta-data/"  # AWS 메타데이터
        "http://localhost:3306/"                     # MySQL
        "http://localhost:27017/"                    # MongoDB
        "file:///etc/passwd"                         # 파일 접근
        "http://127.0.0.1:22"                       # SSH
    )
    
    for payload in "${ssrf_payloads[@]}"; do
        print_info "SSRF 페이로드 테스트: $payload"
        
        # 이미지 URL 가져오기 기능에서 SSRF 테스트
        response=$(curl -s -X POST "$API_BASE/image/fetch" \
            -H "Content-Type: application/json" \
            -d "{\"url\":\"$payload\"}" \
            -w "%{http_code}")
        
        if [[ "$response" == *"200"* ]] && [[ "$response" != *"error"* ]]; then
            print_fail "SSRF 취약점 발견: $payload"
        fi
    done
}

# 보고서 생성
generate_report() {
    print_header "보안 테스트 결과 요약"
    
    local total_tests=$(grep -c "TEST:" "$LOG_FILE" 2>/dev/null || echo "0")
    local passed_tests=$(grep -c "PASS:" "$LOG_FILE" 2>/dev/null || echo "0")
    local failed_tests=$(grep -c "FAIL:" "$LOG_FILE" 2>/dev/null || echo "0")
    
    echo -e "\n===== 보안 테스트 결과 요약 ====="
    echo "총 테스트 수: $total_tests"
    echo "성공한 테스트: $passed_tests"
    echo "실패한 테스트: $failed_tests"
    echo "로그 파일: $LOG_FILE"
    
    if [ "$failed_tests" -gt 0 ]; then
        echo -e "\n${RED}⚠️  보안 취약점이 발견되었습니다!${NC}"
        echo "자세한 내용은 로그 파일을 확인하세요."
    else
        echo -e "\n${GREEN}✅ 모든 보안 테스트를 통과했습니다.${NC}"
    fi
    
    echo -e "\n보안 강화 권장사항은 /security/PATCH_GUIDE.md를 참조하세요."
}

# 메인 실행 함수
main() {
    echo "🔒 Vintage Market 보안 테스트 자동화"
    echo "======================================"
    echo "시작 시간: $TIMESTAMP"
    echo "로그 파일: $LOG_FILE"
    echo ""
    
    # 로그 파일 초기화
    echo "Vintage Market Security Test - $TIMESTAMP" > "$LOG_FILE"
    
    case "${1:-all}" in
        "server")
            check_server_status
            ;;
        "sqli")
            test_sql_injection
            ;;
        "xss")
            test_xss
            ;;
        "upload")
            test_file_upload
            ;;
        "auth")
            test_authentication_bypass
            ;;
        "logic")
            test_business_logic
            ;;
        "info")
            test_information_disclosure
            ;;
        "ssrf")
            test_ssrf
            ;;
        "all"|*)
            check_server_status
            test_sql_injection
            test_xss
            test_file_upload
            test_authentication_bypass
            test_business_logic
            test_information_disclosure
            test_ssrf
            generate_report
            ;;
    esac
    
    echo -e "\n테스트 완료!"
}

# 스크립트 실행
main "$@"