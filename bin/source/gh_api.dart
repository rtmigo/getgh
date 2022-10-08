import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:either_dart/either.dart';

import 'sha.dart';

class GhApiResult {
  final String sha;
  final String contentBase64;

  Uint8List content() {
    final result = base64.decode(contentBase64.replaceAll('\n', ''));
    assert(bytesToGhSha(result) == sha);
    return result;
  }

  GhApiResult({required this.sha, required this.contentBase64});
}

String urlToPath(String url) {
  // IN: https://github.com/rtmigo/cicd/blob/dev/stub.py
  // OUT: /repos/rtmigo/cicd/contents/stub.py

  if (url.startsWith("/repos/")) {
    return url;
  }

  final parts = url.split("github.com/").last.split("/");
  final newParts =
      ["repos"] + parts.sublist(0, 2) + ["contents"] + parts.sublist(4);
  return "/${newParts.join("/")}";
}

Either<String, GhApiResult> ghApi(String url) {
  final r = Process.runSync("gh", ["api", urlToPath(url)]);
  if (r.exitCode != 0) {
    return Left("GH returned error code.\n${r.stdout + r.stderr}");
  }
  final d = json.decode(r.stdout);
  return Right(GhApiResult(sha: d["sha"], contentBase64: d["content"]));
}