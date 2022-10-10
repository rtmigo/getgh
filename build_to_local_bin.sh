#!/bin/bash
set -e && cd "${0%/*}"

dart script/update_constants.dart
dart compile exe bin/hubget.dart -o build/hubget
mv -v build/hubget "$HOME/.local/bin/"
hubget -v