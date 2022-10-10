import 'dart:cli';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:kt_dart/collection.dart';
import 'package:path/path.dart' as pathlib;

import 'exceptions.dart';
import 'gh_api.dart';
import 'sha.dart';

void require(bool condition, String Function() message) {
  if (!condition) {
    throw Exception(message());
  }
}

bool _pathsMoreOrLessEqual<T>(List<T> a, List<T> b) {
  require(a[0]=="repos", () => "Unexpected first element: $a");
  require(b[0]=="repos", () => "Unexpected first element: $b");

  // Может случиться и такое. Мы просим:
  //    /repos/user/old-repo/contents/dir/file
  // Гитхаб возвращает:
  //    /repos/user/renamed-repo/contents/dir/file
  // Поэтому третьему элементу разрешаем отличаться.

  // Юнит-тесты имеют дело именно с таким случаем: репозиторий был переименован.
  // было:  https://github.com/rtmigo/ghfile_test_data
  // стало: https://github.com/rtmigo/getgh_test_data
  // Но TODO неплохо бы проверить и это (вместе с файлом редиректа)
  
  if (a.length != b.length) {
    return false;
  }

  const indexOrRepoName = 2;

  for (var i = 0; i < a.length; ++i) {
    if (i==indexOrRepoName) {
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
String? _childName(Endpoint parent, Endpoint child) {
  final parentSegments = Uri.parse(parent.string).pathSegments;
  final childSegments = Uri.parse(child.string).pathSegments;

  if (_pathsMoreOrLessEqual(parentSegments, childSegments)) {
    return null;
  }
  

  require(childSegments.length == parentSegments.length + 1,
      () => "Unexpected length: $parentSegments $childSegments");
  require(
      _pathsMoreOrLessEqual(childSegments.take(childSegments.length - 1).toList(),
          parentSegments),
      () => "Unexpected lhs: $parentSegments $childSegments");

  return childSegments.last;
}


Future<Uint8List> _getFileContent(GithubFsEntry entry) async {
  // контент может быт уже внутри entry (в виде base64), а может и не быть.

  print(entry.data);
  //print(entry.downloadUrl);
  //print(entry.contentBase64);

  if (entry.type != GithubFsEntryType.file) {
    throw ArgumentError(entry.type);
  }

  if (entry.contentBase64==null && entry.downloadUrl==null) {
    // submodule возвращается с type="file", download_url=null
    throw FileContentNotAvailableException(entry.endpoint);
  }

  final String? theBase64 = entry.contentBase64 ?? iterRemoteEntries(entry.endpoint).single.contentBase64;
  if (theBase64!=null) {
    return base64.decode(theBase64.replaceAll('\n', ''));
  }

  // в случае двоичных больших файлов контент никогда не возвращается
  // как base64. Но может быть доступна прямая ссылка на скачивание.
  // TODO использовать потоки, а не буферы
  return _downloadHttp(entry.downloadUrl!);
}

Future<Uint8List> _downloadHttp(Uri uri) async {
  try {
    return (await http.get(uri)).bodyBytes;
  } catch (e) {
    throw HttpErrorException(e.runtimeType.toString());
  }
}

class HttpErrorException extends ExpectedException {
  HttpErrorException(String s): super(s);
}

class FileContentNotAvailableException extends ExpectedException {
  FileContentNotAvailableException(Endpoint ep): super("File content not available");
}

Future<Uint8List> getFileContent(Endpoint ep) => _getFileContent(_getFileEntry(ep));

Future<void> updateLocal(Endpoint ep, String targetPath)  async {
  if (targetPath.endsWith(pathlib.separator)) {
    Directory(targetPath).createSync(recursive: true);
  }

  final targetDir = Directory(targetPath);
  if (targetDir.existsSync() &&
      targetDir.statSync().type == FileSystemEntityType.directory) {
    await _updateDir(ep, targetDir);
  } else {
    // TODO
    // У нас нет целевого пути, и не было слэша. Мы полагаем, что там имя
    // файла. Но если GitHub сообщит, что там каталог, мы могли бы изменить
    // мнение
    await _updateFile(ep, File(targetPath));
  }
}

GithubFsEntry _getFileEntry(Endpoint ep) {
  final entries = iterRemoteEntries(ep).toList();
  if (entries.length != 1 || entries.first.type != GithubFsEntryType.file) {
    throw ExpectedException(
        "The address ${ep.string} not correspond to a file");
  }
  return entries.single;
}

Future<void> _updateFile(Endpoint ep, File target) =>
    _updateFileByEntry(_getFileEntry(ep), target);

Future<void> _updateFileByEntry(GithubFsEntry entry, File target) async {
  //print("Want save ${entry.endpoint.string} to $target");
  print("* Remote: ${entry.endpoint.string}");
  print("  Local: ${target.path}");
  if (target.existsSync() &&
      target.statSync().size == entry.size &&
      fileToGhSha(target) == entry.sha) {
    print("  The file is up to date (not modified)");
  } else {
    try {
      final parentDir = Directory(pathlib.dirname(target.path));
      parentDir.createSync(recursive: true);
      target.writeAsBytesSync(await _getFileContent(entry));
      print("  File updated");
    } on FileContentNotAvailableException catch (_) {
      print("  ERROR: no content");  // такое, например, в случае подмодулей
    }
  }
}

Future<void> _updateDir(Endpoint ep, Directory target) async {
  await _updateDirRecursive(ep, target, KtSet<String>.empty());
}

/// Аргумент [processed] нужен только для того, чтобы предотвратить
/// бесконечную рекурсию по ошибке.
Future<void> _updateDirRecursive(
    Endpoint sourcePath, Directory target, KtSet<String> processed) async {
  // TODO Проверять sha каталогов (не только файлов)

  if (processed.contains(sourcePath.string)) {
    throw ArgumentError("This endpoint already processed.");
  }
  for (final entry in iterRemoteEntries(sourcePath)) {
    final childName = _childName(sourcePath, entry.endpoint);

    final targetBasename = childName ?? entry.name;
    final targetPath = pathlib.join(target.path, targetBasename);

    switch (entry.type) {
      case GithubFsEntryType.dir:
        await _updateDirRecursive(entry.endpoint, Directory(targetPath),
            processed.plusElement(sourcePath.string));
        break;
      case GithubFsEntryType.file:
        await _updateFileByEntry(entry, File(targetPath));
        break;
      default:
        throw ArgumentError.value(entry.type);
    }
  }
}
