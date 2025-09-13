#!/bin/sh

cp "$1" ./tools/generate-appcast/MemoryActivity.dmg
cp ./project/Sparkle/appcast.xml ./tools/generate-appcast
./artifacts/sparkle/Sparkle/bin/generate_appcast ./tools/generate-appcast
