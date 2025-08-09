#!/bin/sh

mkdir -p ./tools/create-dmg/content
cp -R "$1" ./tools/create-dmg/content/MemoryActivity.app

create-dmg \
  --background "./tools/create-dmg/background.png" \
  --window-size 480 360 \
  --icon-size 90 \
  --icon "MemoryActivity.app" 120 180 \
  --app-drop-link 360 180 \
  "./tools/create-dmg/MemoryActivity.dmg" \
  "./tools/create-dmg/content"

rm -rf ./tools/create-dmg/content
