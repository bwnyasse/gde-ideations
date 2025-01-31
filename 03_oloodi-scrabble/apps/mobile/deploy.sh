#!/bin/bash

readonly BASEDIR=$( cd $( dirname $0 ) && pwd )
FIREBASE_PROJECT_NAME='learning-box-369917'

# Set the project ID
SITE_ID="oloodi-scrabble-companion"

# Build the Flutter web app for release
flutter build web --release

firebase use $FIREBASE_PROJECT_NAME
firebase deploy --only hosting:$SITE_ID  --non-interactive