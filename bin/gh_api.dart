import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:either_dart/either.dart';

import 'ghcp.dart';
import 'sha.dart';

class ApiFile {
  final String sha;
  final String contentBase64;

  Uint8List content() {
    final result = base64.decode(contentBase64.replaceAll('\n', ''));
    assert(bytesToGhSha(result) == sha);
    return result;
  }

  ApiFile({required this.sha, required this.contentBase64}) {
    print(contentBase64);
  }
}

Either<String, ApiFile> ghApi(String url) {
  final r = Process.runSync("gh", ["api", urlToPath(url)]);
  if (r.exitCode != 0) {
    return Left("GH returned error code.\n${r.stdout + r.stderr}");
  }
  final d = json.decode(r.stdout);
  return Right(ApiFile(sha: d["sha"], contentBase64: d["content"]));
}