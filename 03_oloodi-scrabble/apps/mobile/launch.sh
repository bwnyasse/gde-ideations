#!/bin/bash

# Source the .env file (for NON-SENSITIVE variables)
source .env  # Note: space after source is important

readonly BASEDIR=$( cd $( dirname $0 ) && pwd )
FIREBASE_PROJECT_NAME='learning-box-369917'
SITE_ID="oloodi-scrabble-companion"

# Check for command (deploy or run)
if [ "$1" == "deploy" ]; then
  # Deploy to Firebase

  # 1. Get the API key from the environment
  GOOGLE_CLOUD_API_KEY="$GOOGLE_CLOUD_API_KEY"

  # 2. Check if the key is set (important!)
  if [ -z "$GOOGLE_CLOUD_API_KEY" ]; then
    echo "Error: GOOGLE_CLOUD_API_KEY environment variable not set."
    exit 1
  fi

  # Build the Flutter web app for release, passing the key
  flutter build web --release --dart-define=GOOGLE_CLOUD_API_KEY="$GOOGLE_CLOUD_API_KEY"

  firebase use "$FIREBASE_PROJECT_NAME" # Quote variable for safety
  firebase deploy --only hosting:"$SITE_ID" --non-interactive

elif [ "$1" == "run" ]; then
  # Run the Flutter app

  # Source the .env file (for NON-SENSITIVE variables) for the run command too
  source .env

  flutter run -d chrome --dart-define=GOOGLE_CLOUD_API_KEY="$GOOGLE_CLOUD_API_KEY" # Pass the key for run as well

elif [ -z "$1" ]; then # No arguments provided
  echo "Usage: $0 [deploy|run]"
  exit 1
else
  echo "Invalid command: $1"
  exit 1
fi