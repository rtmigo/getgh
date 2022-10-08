import 'dart:io';

import 'package:yaml/yaml.dart';

//String nowStr() => "${DateTime.now().toUtc().toString().substring(0, 19)} UTC";

String nowDate() => DateTime.now().toUtc().toString().substring(0, 10);

void main() {

  final doc = loadYaml(File("pubspec.yaml").readAsStringSync());
  File("bin/source/constants.g.dart").writeAsStringSync(
      "// Do not edit. Auto-generated\n"
          "const buildVersion='${doc["version"]}';\n"
          "const buildDate='${nowDate()}';\n"
          "const buildOs='${Platform.operatingSystem}';");

  //print(nowStr());
}