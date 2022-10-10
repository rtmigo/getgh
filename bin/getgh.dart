// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:io';

import 'package:args/args.dart';

import 'source/constants.g.dart';
import 'source/exceptions.dart';
import 'source/gh_api.dart';
import 'source/saving.dart';

class ProgramArgsException extends ExpectedException {
  ProgramArgsException(String s) : super(s);
}

ArgParser theParser() {
  final parser = ArgParser();
  parser.addFlag("version",
      abbr: "v", negatable: false, help: "Print version and exit");
  return parser;
}

ArgResults parseArgs(List<String> arguments) {
  final ArgResults parsedArgs;
  try {
    parsedArgs = theParser().parse(arguments);
  } on FormatException catch (e) {
    throw ProgramArgsException(e.message);
  }

  if (![1, 2].contains(parsedArgs.rest.length) &&
      !(parsedArgs["version"] as bool)) {
    throw ProgramArgsException("Invalid number of arguments.");
  }

  return parsedArgs;
}

void main(List<String> arguments) async {
  try {
    final parsedArgs = parseArgs(arguments);
    if (parsedArgs["version"] as bool) {
      print("getgh $buildVersion | $buildDate | $buildShortHead");
      print("(c) Artsiom iG (rtmigo.github.io)");
      exit(0);
    }

    final endpoint = argToEndpoint(parsedArgs.rest[0]);
    switch (parsedArgs.rest.length) {
      case 1:
        stdout.add(await getFileContent(endpoint));
        break;
      case 2:
        await updateLocal(endpoint, parsedArgs.rest[1]);
        break;
      default:
        throw StateError("Unexpected count of args");
    }
  } on ProgramArgsException catch (e) {
    print("ERROR: ${e.message}");
    print("");

    print("Usage:");
    print('  getgh <github-url> <target-path>');
    print('');
    print("Options:");
    print("  ${theParser().usage}");
    print('');
    print("# File to stdout:");
    print('  getgh https://github.com/user/repo/file.ext');
    print('');
    print("# File into target dir:");
    print('  getgh https://github.com/user/repo/file.ext target/dir/');
    print('');
    print("# Dir to target dir:");
    print('  getgh https://github.com/user/repo/ target/dir/');
    print('');
    print("See also: https://github.com/rtmigo/getgh#readme");

    exit(64);
  } on ExpectedException catch (e) {
    print("ERROR: ${e.message}");
    exit(1);
  }
}
