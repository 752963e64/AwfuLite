#!/bin/bash

cflags="-pipe -Wall -std=gnu11 -Isrc"
lflags="-lSDL2 -lm"

platform="unix"
outfile="lite"
compiler="gcc"
cflags="$cflags -DLUA_USE_POSIX -D_MYSDL2_"
lflags="$lflags -o $outfile"


if command -v ccache >/dev/null; then
  compiler="ccache $compiler"
fi

echo "compiling ($platform)..."
for f in `find src -name "*.c"`; do
  $compiler -c $cflags $f -o "${f//\//_}.o"
  if [[ $? -ne 0 ]]; then
    got_error=true
  fi
done

if [[ ! $got_error ]]; then
  echo "linking..."
  $compiler *.o $lflags
fi

sed -i "s:x11_clipboard = true:x11_clipboard = false:" ./data/core/config.lua

echo "cleaning up..."
rm *.o
rm res.res 2>/dev/null
echo "done"
