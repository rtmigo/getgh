import 'dart:convert';

import 'package:test/test.dart';

import '../bin/source/gh_api.dart';
import '../bin/source/sha.dart';

void main() {
  test('sha', () {
    expect(bytesToGhSha(ascii.encode("Life is getting better")),
        "4b7956c09662cb7dbf63a212379efb596700ce0e");
  });

  test('gh api either left', () {
    final r = ghApi(argToEndpoint(
        "https://github.com/rtmigo/hflakdhf/blob/91273/README.md").right);
    expect(r.isLeft, true);
    expect(() => r.right, throwsException);
  });

  test('gh api success', () {
    final e = ghApi(argToEndpoint(
        "https://github.com/rtmigo/jsontree_dart/blob/staging/README.md").right);
    expect(e.isRight, true);
    expect(bytesToGhSha(e.right.content()), e.right.sha);
  });
}
