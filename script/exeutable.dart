import 'dart:io';

import 'package:yaml/yaml.dart';

String gitShortHead() =>
    Process.runSync("git", ["rev-parse", "--short", "HEAD"])
        .stdout.toString().trim();

void main() {
  final doc = loadYaml(File("pubspec.yaml").readAsStringSync());
  print("ghcp_${doc["version"]}_${gitShortHead()}_${Platform.operatingSystem}");
}