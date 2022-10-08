import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  final doc = loadYaml(File("pubspec.yaml").readAsStringSync());
  print(doc["version"]);
}