import 'dart:convert';
import 'dart:math';

import 'package:ghcp/ghcp.dart';
import 'package:test/test.dart';

import '../bin/source/gh_api.dart';
import '../bin/ghcp.dart';
import '../bin/source/sha.dart';

void main() {
  test('url to path', () {
    expect(urlToPath("https://github.com/rtmigo/cicd/blob/dev/stub.py"),
        "/repos/rtmigo/cicd/contents/stub.py");

    expect(urlToPath("/repos/rtmigo/cicd/contents/stub.py"),
        "/repos/rtmigo/cicd/contents/stub.py");
  });

  test('sha', () {
    expect(bytesToGhSha(ascii.encode("Life is getting better")),
        "4b7956c09662cb7dbf63a212379efb596700ce0e");
  });

  test('gh api either left', () {
    final r = ghApi("https://github.com/rtmigo/labuda/blob/dev/stub.py");
    expect(r.isLeft, true);
    expect(()=>r.right, throwsException);
  });

  test('gh api success', () {
    final e = ghApi("https://github.com/rtmigo/cicd/blob/dev/stub.py");
    expect(e.isRight, true);
    expect(bytesToGhSha(e.right.content()), e.right.sha);
  });
}

//
// def test_get_file_to_file(self):
// with TemporaryDirectory() as tds:
// target = Path(tds) / "custom_name.py"
// self.assertFalse(target.exists())
// self.assertTrue(
// _write_remote_file_to_local_file(
// "https://github.com/rtmigo/cicd/blob/dev/stub.py", target))
// self.assertTrue(target.exists())
// self.assertFalse(
// _write_remote_file_to_local_file(
// "https://github.com/rtmigo/cicd/blob/dev/stub.py", target))
//
// def test_get_file_to_dir(self):
// with TemporaryDirectory() as tds:
// target = Path(tds)
// self.assertTrue(
// _write_remote_file_to_local_file(
// "https://github.com/rtmigo/cicd/blob/dev/stub.py", target))
// self.assertTrue((target/"stub.py").exists())
