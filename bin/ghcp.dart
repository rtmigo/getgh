import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:ghcp/ghcp.dart' as ghcp_dart;

import 'constants.g.dart';

void run(String url) {
  final r = Process.runSync("gh", ["--version"]);
  print(r.stdout);
}

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addFlag("version", abbr: "v", negatable: false);

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
    print("https://github");
    exit(0);
  }

  if (results.rest.length != 1) {
    print("Usage:");
    print('   ghcp ${parser.usage} <url>');
  }

  final url = results.rest[0];
  run(url);
}
