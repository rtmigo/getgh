// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  final doc = loadYaml(File("pubspec.yaml").readAsStringSync());
  print(doc["version"]);
}
