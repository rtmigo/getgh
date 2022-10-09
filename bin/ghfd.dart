// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:either_dart/either.dart';
import 'package:path/path.dart' as path;

import 'source/constants.g.dart';
import 'source/gh_api.dart';
import 'source/sha.dart';

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

Uint8List? readIfExists(File file) {
  try {
    return file.readAsBytesSync();
  } on OSError {
    return null;
  }
}

Either<String, Object> downloadToFile(Endpoint ep, File target) {
  print("Endpoint: ${ep.string}");
  print("  Target: ${target.path}");

  return ghApi(ep).map((apiResult) {
    if (target.existsSync() && fileToGhSha(target) == apiResult.sha) {
      print("  The file was up to date (not modified)");
      return Right(Object());
    } else {
      target.writeAsBytesSync(apiResult.content());
      print("  File updated");
      return Right(Object());
    }
  });
}

void download(String srcAddr, String targetFileOrDir) {
  argToEndpoint(srcAddr)
      .then((ep) => downloadToFile(ep, argToTargetFile(targetFileOrDir, ep)))
      .either((left) {
    print("ERROR: $left");
    exit(1);
  }, (right) => null);
}

ArgParser theParser() {
  final parser = ArgParser();
  parser.addFlag("version",
      abbr: "v", negatable: false, help: "Print version and exit");
  return parser;
}

Either<String, ArgResults> parseArgs(List<String> arguments) {
  final ArgResults parsedArgs;
  try {
    parsedArgs = theParser().parse(arguments);
  } on FormatException catch (e) {
    return Left(e.message);
  }

  if (parsedArgs.rest.length != 2 && !parsedArgs["version"]) {
    return Left("Incorrect number of arguments.");
  }

  return Right(parsedArgs);
}

void main(List<String> arguments) {
  parseArgs(arguments).either((left) {
    print("ERROR: $left");
    print("");

    print("Usage:");
    print('  ghfd <github-file-url> <target-path>');
    print('');
    print("Options:");
    print("  ${theParser().usage}");
    print('');
    print("Examples:");
    print('  ghfd https://github.com/user/repo/file.ext saved.ext');
    print('  ghfd https://github.com/user/repo/file.ext target/dir/');
    print('');
    print("See also: https://github.com/rtmigo/ghfd#readme");

    exit(64);
  }, (parsedArgs) {
    if (parsedArgs["version"]) {
      print("ghfd $buildVersion | $buildDate | $buildShortHead");
      print("(c) Artsiom iG (rtmigo.github.io)");
      //print("built on ($buildOsLong)");
      exit(0);
    } else {
      download(parsedArgs.rest[0], parsedArgs.rest[1]);
    }
  });
}
