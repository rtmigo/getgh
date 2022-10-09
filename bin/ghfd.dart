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
  print("Target: ${target.path}");

  return ghApi(ep).map((apiResult) {
    if (target.existsSync() && fileToGhSha(target) == apiResult.sha) {
      print("The file is up to date (not modified)");
      return Right(Object());
    } else {
      target.writeAsBytesSync(apiResult.content());
      print("File updated");
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

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addFlag("version",
      abbr: "v", negatable: false, help: "Print version and exit");
  parser.addFlag("whatareyou", negatable: false, hide: true);

  late final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    print(e.message);
    exit(64);
  }

  if (results["whatareyou"]) {
    print("ghfd-$buildVersion-$buildShortHead-$buildOs.exe");
    exit(0);
  }

  if (results["version"]) {
    print(buildVersion);
    exit(0);
  }

  if (results.rest.length != 2) {
    print("GHFD (c) Artsiom iG");
    print("version $buildVersion ($buildDate)");
    print("https://github.com/rtmigo/ghfd#readme");
    print("");
    print("Downloads files from GitHub repos.\n"
        "Does not create/modify local Git repos.\n"
        "Files may be public or private.");
    print("");

    print("Usage:");
    print('  ghfd <github-file-url> <target-path>');
    print('');
    print("Options:");
    print("  ${parser.usage}");
    print('');
    print("Examples:");
    print(
        '  ghfd https://github.com/rtmigo/ghfd/README.md saved.md');
    print('  ghfd https://github.com/rtmigo/ghfd/README.md target/dir/');

    exit(64);
  }

  download(results.rest[0], results.rest[1]);
}
