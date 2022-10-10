import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:kt_dart/collection.dart';
import 'package:path/path.dart' as pathlib;

import 'exceptions.dart';
import 'gh_api.dart';
import 'sha.dart';

void require(final bool condition, final String Function() message) {
  if (!condition) {
    throw Exception(message());
  }
}

bool _pathsEqualExceptRepoName<T>(final KtList<T> a, final KtList<T> b) {
  require(a[0] == "repos", () => "Unexpected first element: $a");
  require(b[0] == "repos", () => "Unexpected first element: $b");

  // Может случиться и такое. Мы просим:
  //    /repos/user/old-repo/contents/dir/file
  // Гитхаб возвращает:
  //    /repos/user/renamed-repo/contents/dir/file
  // Поэтому третьему элементу разрешаем отличаться.

  // Юнит-тесты имеют дело именно с таким случаем: репозиторий был переименован.
  // было:  https://github.com/rtmigo/ghfile_test_data
  // стало: https://github.com/rtmigo/hubget_test_data
  // Но TODO неплохо бы проверить и это (вместе с файлом редиректа)

  if (a.size != b.size) {
    return false;
  }

  const indexOrRepoName = 2;

  for (var i = 0; i < a.size; ++i) {
    if (i == indexOrRepoName) {
      // репозиторий может быть переименован, но пути будут эквивалентны
      continue;
    }
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// Если пути [parent] и [child] одинаковы, возвращает `null`. Иначе полагаем,
/// что [child] расположен непосредственно внутри [parent] и возвращаем
/// локальное имя [child].
String? _childName(final Endpoint parent, final Endpoint child) {
  final parentSegments = Uri.parse(parent.string).pathSegments;
  final childSegments = Uri.parse(child.string).pathSegments;

  if (_pathsEqualExceptRepoName(parentSegments.kt, childSegments.kt)) {
    return null;
  }

  require(childSegments.length == parentSegments.length + 1,
      () => "Unexpected length: $parentSegments $childSegments");
  require(
      _pathsEqualExceptRepoName(
          childSegments.kt.take(childSegments.length - 1), parentSegments.kt),
      () => "Unexpected lhs: $parentSegments $childSegments");

  return childSegments.last;
}

Future<Uint8List> _getFileContent(final GithubFsEntry entry) async {
  // контент может быт уже внутри entry (в виде base64), а может и не быть.

  //print(entry.data);
  //print(entry.downloadUrl);
  //print(entry.contentBase64);

  if (entry.type != GithubFsEntryType.file) {
    throw ArgumentError(entry.type);
  }

  if (entry.contentBase64 == null && entry.downloadUrl == null) {
    // submodule возвращается с type="file", download_url=null
    throw FileContentNotAvailableException(entry.endpoint);
  }

  final String? theBase64 = entry.contentBase64 ??
      (await listRemoteEntries(entry.endpoint)).single().contentBase64;
  if (theBase64 != null) {
    return base64.decode(theBase64.replaceAll('\n', ''));
  }

  // в случае двоичных больших файлов контент никогда не возвращается
  // как base64. Но может быть доступна прямая ссылка на скачивание.
  // TODO использовать потоки, а не буферы
  return _downloadHttp(entry.downloadUrl!);
}

Future<Uint8List> _downloadHttp(final Uri uri) async {
  try {
    return (await http.get(uri)).bodyBytes;
  } catch (e) {
    throw HttpErrorException(e.runtimeType.toString());
  }
}

class HttpErrorException extends ExpectedException {
  HttpErrorException(final String s) : super(s);
}

class FileContentNotAvailableException extends ExpectedException {
  FileContentNotAvailableException(final Endpoint ep)
      : super("File content not available");
}

Future<Uint8List> getFileContent(final Endpoint ep) async =>
    _getFileContent(await _getFileEntry(ep));

Future<KtList<UpdateResult>> updateLocal(
    final Endpoint ep, final String targetPath) async {
  if (targetPath.endsWith(pathlib.separator)) {
    Directory(targetPath).createSync(recursive: true);
  }

  final targetDir = Directory(targetPath);
  if (targetDir.existsSync() &&
      targetDir.statSync().type == FileSystemEntityType.directory) {
    return _updateDir(ep, targetDir);
  } else {
    // TODO
    // У нас нет целевого пути, и не было слэша. Мы полагаем, что там имя
    // файла. Но если GitHub сообщит, что там каталог, мы могли бы изменить
    // мнение
    return inFutureWrapToList(ep, ()=>_updateFile(ep, File(targetPath)));
  }
}

Future<GithubFsEntry> _getFileEntry(final Endpoint ep) async {
  final entries = (await listRemoteEntries(ep));
  if (entries.size != 1 || entries.first().type != GithubFsEntryType.file) {
    throw ExpectedException(
        "The address ${ep.string} not correspond to a file");
  }
  return entries.single();
}

Future<bool> _updateFile(final Endpoint ep, final File target) async =>
    _updateFileByEntry(await _getFileEntry(ep), target);

Future<bool> _updateFileByEntry(
    final GithubFsEntry entry, final File target) async {
  final lines = List<String>.empty(growable: true);
  void printLater(final String s) => lines.add(s);

  try {
    printLater("* Remote: ${entry.endpoint.string}");
    printLater("  Local: ${target.path}");
    if (target.existsSync() &&
        target.statSync().size == entry.size &&
        fileToGhSha(target) == entry.sha) {
      printLater("  The file is up to date (not modified)");
    } else {
      try {
        final parentDir = Directory(pathlib.dirname(target.path));
        parentDir.createSync(recursive: true);
        target.writeAsBytesSync(await _getFileContent(entry));
        printLater("  File updated");
      } on FileContentNotAvailableException catch (_) {
        // такое, например, в случае подмодулей
        printLater("  ERROR: no content");
        return false;
      }
    }
  } finally {
    lines.forEach(print);
  }
  return true;
}

Future<KtList<UpdateResult>> _updateDir(
        final Endpoint ep, final Directory target) =>
    _updateDirRecursive(ep, target, KtSet<String>.empty());

/// Аргумент [processed] нужен только для того, чтобы предотвратить
/// бесконечную рекурсию по ошибке.
Future<KtList<UpdateResult>> _updateDirRecursive(final Endpoint sourcePath,
    final Directory target, final KtSet<String> processed) async {
  // TODO Проверять sha каталогов (не только файлов)

  if (processed.contains(sourcePath.string)) {
    throw ArgumentError("This endpoint already processed.");
  }

  final futures = List<Future<KtList<UpdateResult>>>.empty(growable: true);

  for (final entry in (await listRemoteEntries(sourcePath)).iter) {
    final childName = _childName(sourcePath, entry.endpoint);

    final targetBasename = childName ?? entry.name;
    final targetPath = pathlib.join(target.path, targetBasename);

    // запускаем все дочерние запросы параллельно, запоминая из в списке
    // futures. Нам не нужны их результаты (они сами пишут результат на диск),
    // нам важно лишь дождаться завершения

    switch (entry.type) {
      case GithubFsEntryType.dir:
        futures.add(_updateDirRecursive(entry.endpoint, Directory(targetPath),
            processed.plusElement(sourcePath.string)));
        break;
      case GithubFsEntryType.file:
        futures.add(inFutureWrapToList(
            entry.endpoint, () => _updateFileByEntry(entry, File(targetPath))));
        break;
      default:
        throw ArgumentError.value(entry.type);
    }
  }

  final KtList<KtList<UpdateResult>> childResults =
      (await Future.wait(futures, eagerError: true)).kt;
  return childResults.flatten();
}

/// Преобразует результат отдельного запроса отдельного файла (возвращающий
/// bool) - в список
Future<KtList<UpdateResult>> inFutureWrapToList(
  final Endpoint endpoint,
  final Future<bool> Function() block,
) async {
  return [UpdateResult(endpoint, await block())].kt;
}

/// Результат обновления отдельного файл
class UpdateResult {
  final Endpoint endpoint;
  final bool success;

  UpdateResult(this.endpoint, this.success);
}
