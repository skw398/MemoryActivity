#!/bin/sh

cp -r ./MemoryActivity/Localizable.xcstrings ./tools/loctable2xcstrings
if swift ./tools/loctable2xcstrings/loctable2xcstrings.swift "./tools/loctable2xcstrings/Localizable.xcstrings"; then
    sw_vers > "./tools/loctable2xcstrings/macosversion.txt"
fi
mv -f ./tools/loctable2xcstrings/Localizable.xcstrings ./MemoryActivity
