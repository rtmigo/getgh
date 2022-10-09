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
    print("ghcp-$buildVersion-$buildShortHead-$buildOs.exe");
    exit(0);
  }

  if (results["version"]) {
    print(buildVersion);
    exit(0);
  }

  if (results.rest.length != 2) {
    print("ghcp (c) Artsiom iG");
    print("version $buildVersion ($buildDate)");
    print("https://github.com/rtmigo/ghcp#readme");
    print("");

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

  download(results.rest[0], results.rest[1]);
}
