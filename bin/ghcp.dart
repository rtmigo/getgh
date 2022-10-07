import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:ghcp/ghcp.dart' as ghcp_dart;

import 'constants.g.dart';

String urlToPath(String url) {
  // IN: https://github.com/rtmigo/cicd/blob/dev/stub.py
  // OUT: /repos/rtmigo/cicd/contents/stub.py
  final parts = url
      .split("github.com/")
      .last
      .split("/");
  final newParts = ["repos"] + parts.sublist(0, 2) +
      ["contents"] + parts.sublist(4);
  return "/${newParts.join("/")}";
}

/// Считает хэш так же, как это делает GH. 
String bytesToSha1(Uint8List bytes) =>
    sha1.convert(ascii.encode("blob ${bytes.length}\u0000")+bytes).toString();

String fileToSha1(File file) => bytesToSha1(file.readAsBytesSync());


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
    print("https://github.com/rtmigo/ghcp_dart#readme");
    exit(0);
  }

  if (results.rest.length != 1) {
    print("Usage:");
    print('   ghcp ${parser.usage} <url>');
  }

  final url = results.rest[0];
  run(url);
}
