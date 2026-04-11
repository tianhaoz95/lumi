#!/usr/bin/env bash
set -euo pipefail
ENDPOINT="http://localhost/v1"
API_KEY="${APPWRITE_API_KEY:-}"   # from GitHub secret

if [ -z "${API_KEY}" ]; then
  echo "Warning: APPWRITE_API_KEY not set. CI must provide this via secrets."
fi

# Create test users via Appwrite REST
curl -sf -X POST "$ENDPOINT/users" \
  -H "x-appwrite-project: lumi-test" \
  -H "x-appwrite-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"userId":"test-user","email":"test@lumi.com","password":"TestPass123!","name":"Test User"}'

curl -sf -X POST "$ENDPOINT/users" \
  -H "x-appwrite-project: lumi-test" \
  -H "x-appwrite-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"userId":"reset-user","email":"reset@lumi.com","password":"TestPass123!","name":"Reset User"}'

# Write .env.test
cat > .env.test <<EOF
APPWRITE_ENDPOINT=http://localhost/v1
APPWRITE_PROJECT_ID=lumi-test
APPWRITE_API_KEY=${API_KEY}
TEST_USER_EMAIL=test@lumi.com
TEST_USER_PASSWORD=TestPass123!
TEST_RESET_EMAIL=reset@lumi.com
MAILHOG_URL=http://localhost:8025
EOF

echo "✓ .env.test written"