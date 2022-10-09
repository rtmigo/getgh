import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../bin/ghfd.dart';

void main() {
  Directory? td = null;
  setUp(() {
    assert(td==null);
    td = Directory.systemTemp.createTempSync();
  });

  tearDown(() {
    try {
      td!.deleteSync(recursive: true);
      td=null;
    } on OSError catch(_) {
      // windows
    }
  });

  // TODO prepare specific files in repos for testing

  test('download to file', () {
    final fn = path.join(td!.path, "file.ext");
    expect(File(fn).existsSync(), false);
    download(
      "https://github.com/rtmigo/jsontree_dart/blob/staging/README.md",
      fn);
    expect(File(fn).existsSync(), true);
  });

  test('download to dir', () {
    final fn = path.join(td!.path, "README.md");
    expect(File(fn).existsSync(), false);
    download(
        "https://github.com/rtmigo/jsontree_dart/blob/staging/README.md",
        td!.path);
    expect(File(fn).existsSync(), true);
  });

}