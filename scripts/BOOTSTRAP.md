Using the appwrite MCP server, perform the following steps in order. Confirm each step before proceeding to the next.

1. Create a project with ID "lumi-test" and name "Lumi Test".
2. Create an API key with all available scopes. Print the key.
3. Enable the Email/Password authentication method.
4. Add a Flutter platform with bundle ID "com.lumi.app".
5. Configure SMTP: host=mailhog, port=1025, sender=noreply@lumi.test, TLS=false.
6. Create a user with email "test@lumi.com", password "TestPass123!", name "Test User".
7. Create a user with email "reset@lumi.com", password "TestPass123!", name "Reset User".
8. Write a file ".env.test" at the project root with the following content, substituting the actual project ID and API key:

APPWRITE_ENDPOINT=http://localhost/v1
APPWRITE_PROJECT_ID=lumi-test
APPWRITE_API_KEY=<key-from-step-2>
TEST_USER_EMAIL=test@lumi.com
TEST_USER_PASSWORD=TestPass123!
TEST_RESET_EMAIL=reset@lumi.com
MAILHOG_URL=http://localhost:8025
