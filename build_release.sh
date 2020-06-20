#!/bin/bash
./build.sh release
rm lite.zip 2>/dev/null
cp winlib/SDL2-2.0.10/x86_64-w64-mingw32/bin/SDL2.dll SDL2.dll
strip lite
zip lite.zip lite data -r

