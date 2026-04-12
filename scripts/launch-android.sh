#!/bin/bash

# launch-android.sh
# Detects host IP and connected Android device, ensures the Android platform is registered
# with the local Appwrite project, and then runs Flutter with dart-define flags.

# 1. Detect Host IP (Linux)
# On physical devices, 'localhost' points to the device itself.
# We need the local network IP of this machine.
HOST_IP=$(hostname -I | awk '{print $1}')

if [ -z "$HOST_IP" ]; then
  echo "Error: Could not detect host IP address."
  exit 1
fi

echo "Detected Host IP: $HOST_IP"

# 2. Detect configuration from .env.test or use defaults
PROJECT_ID="lumi-test"
API_KEY=""
if [ -f ".env.test" ]; then
  PROJECT_ID=$(grep APPWRITE_PROJECT_ID .env.test | cut -d '=' -f2)
  API_KEY=$(grep APPWRITE_API_KEY .env.test | cut -d '=' -f2)
fi

echo "Using Appwrite Project ID: $PROJECT_ID"

# 3. Handle Appwrite Login if requested
if [[ "$1" == "login" ]]; then
  echo "Logging into Appwrite Console..."
  appwrite login
  exit 0
fi

# 4. Ensure Android platform is registered in Appwrite
# Appwrite requires platforms to be registered with their bundle/package ID
# to authorize incoming requests.
PACKAGE_NAME="com.hejitech.lumi" # From android/app/build.gradle.kts

if [ -n "$API_KEY" ]; then
  echo "Ensuring Android platform registration for '$PACKAGE_NAME'..."
  # Try to create the platform. 
  # Note: For project-level API keys, use the Project ID as the X-Appwrite-Project header.
  # If the key lacks platforms.write scope, this may still fail.
  RESPONSE=$(curl -s -X POST "http://localhost/v1/projects/$PROJECT_ID/platforms" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $PROJECT_ID" \
    -H "X-Appwrite-Key: $API_KEY" \
    -d "{\"type\":\"flutter-android\",\"name\":\"Android Device\",\"key\":\"$PACKAGE_NAME\"}")

  if echo "$RESPONSE" | grep -q "$PACKAGE_NAME"; then
    echo "Platform registered successfully."
  elif echo "$RESPONSE" | grep -q "already exists"; then
    echo "Platform already registered."
  elif echo "$RESPONSE" | grep -q "unauthorized"; then
    echo "Error: API Key is unauthorized. You may need to add the 'platforms.write' scope to your API key or login via CLI."
    echo "Try running: ./scripts/launch-android.sh login"
    # Fallback to Appwrite CLI if available
    if command -v appwrite &> /dev/null; then
       echo "Attempting registration via Appwrite CLI..."
       appwrite projects create-platform --project-id "$PROJECT_ID" --type "flutter-android" --name "Android Device" --key "$PACKAGE_NAME" &> /dev/null
       if [ $? -eq 0 ]; then
         echo "Platform registered via CLI."
       else
         echo "CLI registration also failed. Please check your Appwrite console."
       fi
    fi
  else
    echo "Warning: Platform registration may have failed. Response: $RESPONSE"
  fi
else
  echo "Warning: No APPWRITE_API_KEY found in .env.test. Skipping platform registration check."
  echo "If you haven't logged in yet, run: ./scripts/launch-android.sh login"
fi

# 5. Detect Connected Android Device
# We look for lines containing 'android' and pick the first ID.
DEVICE_ID=$(flutter devices | grep "android" | head -n 1 | awk -F " • " '{print $2}' | xargs)

if [ -z "$DEVICE_ID" ]; then
  # Fallback for older/different formats: check if any device is connected
  DEVICE_ID=$(flutter devices | grep "mobile" | head -n 1 | awk -F " • " '{print $2}' | xargs)
fi

if [ -z "$DEVICE_ID" ]; then
  echo "Warning: No Android device detected via 'flutter devices'. Attempting to run on default device..."
else
  echo "Targeting Device: $DEVICE_ID"
fi

# 6. Construct APPWRITE_ENDPOINT
# Note: Physical devices use the Host IP. Emulators can use 10.0.2.2.
# This script assumes physical device by default.
ENDPOINT="http://$HOST_IP/v1"

echo "--------------------------------------------------------"
echo "Launching Lumi with local Appwrite support..."
echo "Endpoint: $ENDPOINT"
echo "Project:  $PROJECT_ID"
echo "--------------------------------------------------------"

# 7. Execute Flutter Run
# We pass the endpoint and project id as dart-defines which lib/core/init.dart reads.
# We skip API key for the client app (security best practice).
flutter run \
  ${DEVICE_ID:+-d $DEVICE_ID} \
  --dart-define=APPWRITE_ENDPOINT=$ENDPOINT \
  --dart-define=APPWRITE_PROJECT_ID=$PROJECT_ID
