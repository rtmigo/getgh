#!/bin/bash
set -e && cd "${0%/*}"

dart script/update_constants.dart
dart compile exe bin/getgh.dart -o build/getgh
mv -v build/getgh "$HOME/.local/bin/"
getgh -v