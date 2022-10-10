// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';

import 'package:path/path.dart' as path;

import 'source/constants.g.dart';
import 'source/exceptions.dart';
import 'source/gh_api.dart';
import 'source/saving.dart';

/// Программе на вход подали [pathArg], но мы не знаем, это каталог или имя
/// целевого файла. Также мы знаем, что файл в репозитории называется
/// [remoteBasename].
///
/// Возвращаем целевое имя файла, куда и правда собираемся сохранить.
File argToTargetFile(String pathArg, Endpoint ep) {
  bool endsWithSlash() => pathArg.endsWith('/') || pathArg.endsWith('\\');
  bool isExistingDir() =>
      File(pathArg).statSync().type == FileSystemEntityType.directory;

  if (endsWithSlash() || isExistingDir()) {
    return File(path.join(pathArg, ep.filename()));
  } else {
    return File(pathArg);
  }
}

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

  if (parsedArgs.rest.length != 2 && !(parsedArgs["version"] as bool)) {
    throw ProgramArgsException("Invalid number of arguments.");
  }

  return parsedArgs;
}

void main(List<String> arguments) {
  try {
    final parsedArgs = parseArgs(arguments);
    if (parsedArgs["version"] as bool) {
      print("getgh $buildVersion | $buildDate | $buildShortHead");
      print("(c) Artsiom iG (rtmigo.github.io)");
      exit(0);
    } else {
      updateLocal(
          argToEndpoint(parsedArgs.rest[0]), parsedArgs.rest[1]);
    }
  } on ProgramArgsException catch (e) {
    print("ERROR: ${e.message}");
    print("");

    print("Usage:");
    print('  getgh <github-file-url> <target-path>');
    print('');
    print("Options:");
    print("  ${theParser().usage}");
    print('');
    print("Examples:");
    print('  getgh https://github.com/user/repo/file.ext target/dir/');
    print('  getgh https://github.com/user/repo/ target/dir/');
    print('');
    print("See also: https://github.com/rtmigo/getgh#readme");

    exit(64);
  } on ExpectedException catch (e) {
    print("ERROR: ${e.message}");
    exit(1);
  }
}
