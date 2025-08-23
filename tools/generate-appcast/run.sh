#!/bin/sh

cp "$1" ./tools/generate_appcast/MemoryActivity.dmg
cp ./project/Sparkle/appcast.xml ./tools/generate_appcast
./artifacts/sparkle/Sparkle/bin/generate_appcast ./tools/generate_appcast
