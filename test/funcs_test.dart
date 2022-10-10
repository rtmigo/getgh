import 'dart:convert';

import 'package:test/test.dart';

import '../bin/source/gh_api.dart';
import '../bin/source/sha.dart';

void main() {
  // test('sha', () {
  //   expect(bytesToGhSha(ascii.encode("Life is getting better")),
  //       "4b7956c09662cb7dbf63a212379efb596700ce0e");
  // });
  //
  // test('gh api either left', () {
  //   final r = getFile(
  //       argToEndpoint("https://github.com/rtmigo/hflakdhf/blob/91273/README.md"));
  //   expect(r.isLeft, true);
  //   expect(() => r.right, throwsException);
  // });
  //
  // group("getFile", () {
  //   test('existing', () {
  //     final e = getFile(argToEndpoint(
  //             "https://github.com/rtmigo/ghfile_test_data/blob/dev/file_one.txt"));
  //     expect(e.right.text(), "1=1");
  //   });
  //
  //   test('non existing', () {
  //     final e = getFile(argToEndpoint(
  //             "https://github.com/rtmigo/ghfile_test_data/blob/dev/file_labuda.txt"));
  //     expect(e.left, 'GH exited with error message "gh: Not Found (HTTP 404)"');
  //   });
  //
  //   test('requesting tree', () {
  //     final e = getFile(argToEndpoint(
  //         "https://github.com/rtmigo/ghfile_test_data/tree/dev/dir-abc"));
  //     expect(e.left, 'The endpoint corresponds to an unsupported content type');
  //   });
  // });
}
