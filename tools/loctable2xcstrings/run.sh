cp -r ../../MemoryActivity/Localizable.xcstrings ./
swift loctable2xcstrings.swift
mv -f ./Localizable.xcstrings ../../MemoryActivity/

sw_vers > "macosversion.txt"
