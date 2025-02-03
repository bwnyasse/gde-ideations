#!/bin/bash

readonly BASEDIR=$( cd $( dirname $0 ) && pwd )

 # Source the .env file (for NON-SENSITIVE variables) for the run command too
source .env

# Check for command (deploy or run)
if [ "$1" == "deploy" ]; then
  # Deploy to Firebase
  echo "Nothing to do for now"

elif [ "$1" == "run" ]; then
  # Run the Flutter app

  fvm flutter run -d 3fb285a7  --dart-define-from-file=.env

elif [ -z "$1" ]; then # No arguments provided
  echo "Usage: $0 [deploy|run]"
  exit 1
else
  echo "Invalid command: $1"
  exit 1
fi