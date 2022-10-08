import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'source/constants.g.dart';
import 'source/gh_api.dart';
import 'source/sha.dart';

void run(String url) {
  final r = Process.runSync("gh", ["--version"]);
  print(r.stdout);
}

String urlToBasename(String url) {
  // TODO адреса бывают разнообразнее
  return url.split('/').last;
}

/// Программе на вход подали [pathArg], но мы не знаем, это каталог или имя
/// целевого файла. Также мы знаем, что файл в репозитории называется
/// [remoteBasename].
///
/// Возвращаем целевое имя файла, куда и правда собираемся сохранить.
File basenameToPath(String pathArg, String remoteBasename) {
  bool endsWithSlash() => pathArg.endsWith('/') || pathArg.endsWith('\\');
  bool isExistingDir() =>
      File(pathArg).statSync().type == FileSystemEntityType.directory;
  if (endsWithSlash() || isExistingDir()) {
    return File(path.join(pathArg, remoteBasename));
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

void downloadToFile(String url, File target) {
  ghApi(url).fold((left) {
    print("ERROR: $left");
    exit(1);
  }, (right) {
    if (target.existsSync() && fileToGhSha(target) == right.sha) {
      print("${path.basename(target.path)} not changed");
    } else {
      target.writeAsBytesSync(right.content());
      print("${path.basename(target.path)} updated");
    }
  });
}

void download(String url, String target) {
  downloadToFile(url, basenameToPath(target, urlToBasename(url)));
}

void main(List<String> arguments) {
  var parser = ArgParser();
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
    print("ghcp $buildVersion ($buildOs, $buildDate)");
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
