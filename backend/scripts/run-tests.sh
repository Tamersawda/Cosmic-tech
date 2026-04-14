#!/bin/bash

# ============================================================
# Authentication System Testing Script (Bash)
#
# Usage: ./run-tests.sh
#
# This script performs comprehensive tests for the auth system
# ============================================================

set -e

API_URL="http://localhost:8000"
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "============================================================"
echo "  Therapy Booking Backend - Test Suite"
echo "============================================================"
echo ""

# ============================================================
# Helper function to make requests and check responses
# ============================================================
test_endpoint() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local token=$5
    local expected_status=$6

    echo "[TEST] $test_name"
    
    local cmd="curl -s -w '\n%{http_code}' -X $method '$API_URL$endpoint'"
    
    if [ ! -z "$data" ]; then
        cmd="$cmd -H 'Content-Type: application/json' -d '$data'"
    fi
    
    if [ ! -z "$token" ]; then
        cmd="$cmd -H 'Authorization: Bearer $token'"
    fi
    
    local response=$(eval $cmd)
    local body=$(echo "$response" | head -n -1)
    local status=$(echo "$response" | tail -n 1)
    
    echo "  Status: $status"
    echo "  Response: $body"
    echo ""
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "  ${GREEN}✓ PASS${NC}"
        ((PASS_COUNT++))
        echo "$body"
    else
        echo -e "  ${RED}✗ FAIL${NC} (expected $expected_status, got $status)"
        ((FAIL_COUNT++))
    fi
    
    echo ""
}

# ============================================================
# Test 1: Registration - Doctor
# ============================================================
DOCTOR_EMAIL="doctor_$(date +%s)@test.com"
DOCTOR_PASSWORD="DocPass123"

test_endpoint \
    "Registration - Doctor" \
    "POST" \
    "/api/auth/register" \
    "{\"email\":\"$DOCTOR_EMAIL\",\"password\":\"$DOCTOR_PASSWORD\",\"userType\":\"doctor\",\"fullName\":\"Dr. Test User\"}" \
    "" \
    "201"

# Extract token from response for later tests
DOCTOR_TOKEN=$(echo "$response" | head -n -1 | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4 || echo "")

# ============================================================
# Test 2: Registration - Patient
# ============================================================
PATIENT_EMAIL="patient_$(date +%s)@test.com"
PATIENT_PASSWORD="PatPass123"

test_endpoint \
    "Registration - Patient" \
    "POST" \
    "/api/auth/register" \
    "{\"email\":\"$PATIENT_EMAIL\",\"password\":\"$PATIENT_PASSWORD\",\"userType\":\"patient\",\"fullName\":\"John Doe\"}" \
    "" \
    "201"

PATIENT_TOKEN=$(echo "$response" | head -n -1 | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4 || echo "")

# ============================================================
# Test 3: Duplicate Email Registration
# ============================================================
test_endpoint \
    "Duplicate Email Registration (Should Fail)" \
    "POST" \
    "/api/auth/register" \
    "{\"email\":\"$DOCTOR_EMAIL\",\"password\":\"DifferentPass123\",\"userType\":\"patient\",\"fullName\":\"Different User\"}" \
    "" \
    "409"

# ============================================================
# Test 4: Invalid User Type
# ============================================================
test_endpoint \
    "Invalid User Type (Should Fail)" \
    "POST" \
    "/api/auth/register" \
    "{\"email\":\"invalid_type_$(date +%s)@test.com\",\"password\":\"Pass123\",\"userType\":\"admin\",\"fullName\":\"Hacker\"}" \
    "" \
    "400"

# ============================================================
# Test 5: Login - Valid Credentials
# ============================================================
test_endpoint \
    "Login - Valid Credentials" \
    "POST" \
    "/api/auth/login" \
    "{\"email\":\"$DOCTOR_EMAIL\",\"password\":\"$DOCTOR_PASSWORD\"}" \
    "" \
    "200"

LOGIN_TOKEN=$(echo "$response" | head -n -1 | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4 || echo "")

# ============================================================
# Test 6: Login - Invalid Password
# ============================================================
test_endpoint \
    "Login - Invalid Password (Should Fail)" \
    "POST" \
    "/api/auth/login" \
    "{\"email\":\"$DOCTOR_EMAIL\",\"password\":\"WrongPassword123\"}" \
    "" \
    "401"

# ============================================================
# Test 7: Login - Non-existent Email
# ============================================================
test_endpoint \
    "Login - Non-existent Email (Should Fail)" \
    "POST" \
    "/api/auth/login" \
    "{\"email\":\"nonexistent@test.com\",\"password\":\"AnyPass123\"}" \
    "" \
    "401"

# ============================================================
# Test 8: Get Current User - Valid Token
# ============================================================
if [ ! -z "$LOGIN_TOKEN" ]; then
    test_endpoint \
        "Get Current User - Valid Token" \
        "GET" \
        "/api/me" \
        "" \
        "$LOGIN_TOKEN" \
        "200"
fi

# ============================================================
# Test 9: Get Current User - No Token
# ============================================================
test_endpoint \
    "Get Current User - No Token (Should Fail)" \
    "GET" \
    "/api/me" \
    "" \
    "" \
    "401"

# ============================================================
# Test 10: Get Current User - Invalid Token
# ============================================================
test_endpoint \
    "Get Current User - Invalid Token (Should Fail)" \
    "GET" \
    "/api/me" \
    "" \
    "invalid.token.here" \
    "401"

# ============================================================
# Summary
# ============================================================
echo "============================================================"
echo "  Test Summary"
echo "============================================================"
echo -e "  ${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "  ${RED}Failed: $FAIL_COUNT${NC}"
echo -e "  Total:  $((PASS_COUNT + FAIL_COUNT))"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "  ${GREEN}✓ All tests passed!${NC}"
    echo ""
    exit 0
else
    echo -e "  ${RED}✗ Some tests failed${NC}"
    echo ""
    exit 1
fi
