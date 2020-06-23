#!/bin/bash
./build.sh release
rm lite.zip 2>/dev/null
strip lite
zip lite.zip lite data -r

