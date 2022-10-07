import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:either_dart/either.dart';
import 'package:ghcp/ghcp.dart' as ghcp_dart;

import 'constants.g.dart';

String urlToPath(String url) {
  // IN: https://github.com/rtmigo/cicd/blob/dev/stub.py
  // OUT: /repos/rtmigo/cicd/contents/stub.py
  final parts = url.split("github.com/").last.split("/");
  final newParts =
      ["repos"] + parts.sublist(0, 2) + ["contents"] + parts.sublist(4);
  return "/${newParts.join("/")}";
}

void run(String url) {
  final r = Process.runSync("gh", ["--version"]);
  print(r.stdout);
}

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addFlag("version",
      abbr: "v", negatable: false, help: "Print version and exit");

  late final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    print(e.message);
    exit(64);
  }

  if (results["version"]) {
    print("ghcp $buildVersion ($buildDate)");
    print("(c) 2022 Artsiom iG");
    print("https://github.com/rtmigo/ghcp_dart#readme");
    exit(0);
  }

  if (results.rest.length != 2) {
    print("Usage:");
    print('  ghcp <github-file-url> <target-path>');
    print('');
    print("Options:");
    print("  ${parser.usage}");
    print('');
    print("Examples:");
    print(
        '  ghcp https://github.com/rtmigo/ghcp_dart/README.md ghcp_readme.md');
    print('  ghcp https://github.com/rtmigo/ghcp_dart/README.md parent/dir/');

    exit(64);
  }

  final url = results.rest[0];
  run(url);
}
