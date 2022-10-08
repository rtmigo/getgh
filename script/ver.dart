import 'dart:io';

import 'package:yaml/yaml.dart';

String gitShortHead() =>
    Process.runSync("git", ["rev-parse", "--short", "HEAD"])
        .stdout
        .toString()
        .trim();

void main(List<String> args) {
  final doc = loadYaml(File("pubspec.yaml").readAsStringSync());
  switch (args[0]) {
    case "archive":
      print(
          "ghcp_${doc["version"]}_${gitShortHead()}_${Platform.operatingSystem}");
      break;
    case "exe":
      print("ghcp${Platform.isWindows ? '.exe' : ''}");
      break;
    case "release":
      print(doc["version"]);
      break;
    default:
      throw Error();
  }
}
