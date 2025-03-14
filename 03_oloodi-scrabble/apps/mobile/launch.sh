#!/bin/bash

readonly BASEDIR=$( cd $( dirname $0 ) && pwd )

 # Source the .env file (for NON-SENSITIVE variables) for the run command too
source .env

# Check for command (deploy or run)
if [ "$1" == "deploy" ]; then
  # Deploy to Firebase

  # Build the Flutter web app for release, passing the key
  fvm flutter build web --release --dart-define-from-file=.env

  firebase use "$FIREBASE_PROJECT_ID" # Quote variable for safety
  firebase deploy --only hosting:"$FIREBASE_HOSTING_SITE_ID" --non-interactive

elif [ "$1" == "run" ]; then
  # Run the Flutter app

  fvm flutter run -d chrome  --dart-define-from-file=.env

elif [ -z "$1" ]; then # No arguments provided
  echo "Usage: $0 [deploy|run]"
  exit 1
else
  echo "Invalid command: $1"
  exit 1
fi