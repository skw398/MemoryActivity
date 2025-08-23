#!/bin/sh

cp ./MemoryActivity/Localizable.xcstrings ./tools/loctable2xcstrings

if swift ./tools/loctable2xcstrings/loctable2xcstrings.swift ./tools/loctable2xcstrings/Localizable.xcstrings; then
    sw_vers > ./tools/loctable2xcstrings/macosversion.txt
    cp ./tools/loctable2xcstrings/Localizable.xcstrings ./MemoryActivity
fi

rm -f ./tools/loctable2xcstrings/Localizable.xcstrings
