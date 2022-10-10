// SPDX-FileCopyrightText: (c) 2022 Artsiom iG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:kt_dart/kt.dart';

import 'exceptions.dart';
import 'github_urls.dart';
import 'sha.dart';

enum GithubFsEntryType { file, dir }

class GithubFsEntry {
  GithubFsEntry(this.data);

  final KtMap<String, dynamic> data;

  String get name => this.data["name"] as String;

  /// Определено и для файлов, и для каталогов
  String get sha => this.data["sha"] as String;
  String get _typeStr => this.data["type"] as String;

  /// Размер файла. Для каталогов ноль.
  int get size => this.data["size"] as int;

  /// Определено только для файлов. И не всегда, а только когда их запрашивают
  /// по одному.
  String? get contentBase64 {
    if (this.encoding == null) {
      return null;
    }
    if (this.encoding != "base64") {
      throw ArgumentError("Unexpected encoding: .");
    }
    return this.data["content"] as String?;
  }

  String? get encoding => this.data["encoding"] as String?;

  /// Что-то вроде
  /// "https://api.github.com/repos/dart-lang/sdk/contents/sdk?ref=main".
  /// То есть, хост + эндпоинт.
  String get url => this.data["url"] as String;

  Endpoint get endpoint {
    final u = this.url;
    final prefix = "https://api.github.com";
    if (!u.startsWith(prefix)) {
      throw ArgumentError.value(u);
    }
    return Endpoint(u.substring(prefix.length));
  }

  GithubFsEntryType get type {
    switch (this._typeStr) {
      case "dir":
        return GithubFsEntryType.dir;
      case "file":
        return GithubFsEntryType.file;
      default:
        throw ArgumentError.value(this._typeStr);
    }
  }

  /// Определено для файлов, но не каталогов.
  Uri? get downloadUrl => (this.data["type"] as String?)?.let(Uri.parse);
}

class ApiResponse {}

class FileResponse extends ApiResponse {
  final String sha;
  final String contentBase64;

  Uint8List content() {
    final result = base64.decode(contentBase64.replaceAll('\n', ''));
    assert(bytesToGhSha(result) == sha);
    return result;
  }

  String text() => utf8.decode(content());

  FileResponse({required this.sha, required this.contentBase64});
}

class Endpoint {
  final String string;

  Endpoint(this.string);

  String filename() => Uri.parse(this.string).pathSegments.last;
}

/// На входе у нас аргумент программы. Скорее всего, заданный как http-адрес
/// файла. На выходе будет "endpoint", к которому умеет обращаться api.
Endpoint argToEndpoint(String url) {
  // IN: https://github.com/rtmigo/cicd/blob/dev/stub.py
  // OUT: /repos/rtmigo/cicd/contents/stub.py

  if (url.startsWith("/repos/")) {
    return Endpoint(url);
  }

  final segmentsList = Uri.parse(url).pathSegments;
  if (segmentsList.length <= 1) {
    throw ExpectedException('Invalid address: "$url"');
  }
  final segments = GithubPathSegments(segmentsList.kt);

  final userRepoPath = segments.withoutBlobAndBranch();
  final parts = ["repos"].kt +
      userRepoPath.subList(0, 2) +
      ["contents"].kt +
      userRepoPath.subList(2, userRepoPath.size);
  final allExceptBranch = "/${parts.joinToString(separator: "/")}";

  if (segments.branch != null) {
    return Endpoint("$allExceptBranch?ref=${segments.branch}");
  } else {
    return Endpoint(allExceptBranch);
  }
}

class GhNotInstalledException extends ExpectedException {
  GhNotInstalledException()
      : super("`gh` not installed. Get it at https://cli.github.com/");
}

Iterable<GithubFsEntry> iterRemoteEntries(Endpoint ep,
    {String executable = "gh"}) sync* {
  final ProcessResult r;
  try {
    r = Process.runSync(executable, ["api", ep.string]);
  } on ProcessException catch (e) {
    if (e.message.contains("No such file or directory") // linux
    || e.message.contains("The system cannot find the file specified") // windows
    ) {
      throw GhNotInstalledException();
    } else {
      rethrow;
    }
  }

  if (r.exitCode != 0) {
    throw ExpectedException("GH exited with error message "
        '"${r.stderr.toString().trim()}"');
  }

  final parsed = json.decode(r.stdout.toString());
  if (parsed is Map) {
    yield GithubFsEntry((parsed as Map<String, dynamic>).kt);
  } else {
    for (final item in (parsed as List)) {
      yield GithubFsEntry((item as Map<String, dynamic>).kt);
    }
  }
}
