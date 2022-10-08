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

List<String> removeBlobAndBranch(List<String> pathSegments) {
  // user/repo/blob/branch/dir/file -> user/repo/dir/file
  if (pathSegments.length >= 4 && pathSegments[2] == "blob") {
    return pathSegments.sublist(0, 2) + pathSegments.sublist(4);
  } else {
    return pathSegments;
  }
}

String? branchName(List<String> pathSegments) {
  if (pathSegments.length >= 4 && pathSegments[2] == "blob") {
    return pathSegments[3];
  } else {
    return null;
  }
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

  final segments = Uri.parse(url).pathSegments;
  final branch = branchName(segments);
  final userRepoPath = removeBlobAndBranch(segments);
  final parts = ["repos"] +
      userRepoPath.sublist(0, 2) +
      ["contents"] +
      userRepoPath.sublist(2);
  final allExceptBranch = "/${parts.join("/")}";

  if (branch != null) {
    return Endpoint("$allExceptBranch?ref=$branch");
  } else {
    return Endpoint(allExceptBranch);
  }
}

Either<String, GhApiResult> ghApi(Endpoint ep) {
  final r = Process.runSync("gh", ["api", ep.string]);
  if (r.exitCode != 0) {
    return Left("GH returned error code.\n${r.stdout + r.stderr}");
  }
  final d = json.decode(r.stdout);
  return Right(GhApiResult(sha: d["sha"], contentBase64: d["content"]));
}
