// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT


import 'dart:io';

import 'package:yaml/yaml.dart';

String nowDate() => DateTime.now().toUtc().toString().substring(0, 10);

String gitShortHead() =>
    Process.runSync("git", ["rev-parse", "--short", "HEAD"])
        .stdout.toString().trim();

void main() {
  final doc = loadYaml(File("pubspec.yaml").readAsStringSync());
  File("bin/source/constants.g.dart").writeAsStringSync(
      "// Do not edit. Auto-generated\n"
          "const buildVersion='${doc["version"]}';\n"
          "const buildDate='${nowDate()}';\n"
          "const buildOs='${Platform.operatingSystem}';\n"
          "const buildOsLong='${Platform.operatingSystemVersion}';\n"
          "const buildShortHead='${gitShortHead()}';\n");
}