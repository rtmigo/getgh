#!/bin/bash
set -e && cd "${0%/*}"

dart script/update_constants.dart
dart compile exe bin/ghfd.dart -o build/ghfd
mv -v build/ghfd "$HOME/.local/bin/"
ghfd -v