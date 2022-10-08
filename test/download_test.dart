import 'dart:io';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../bin/ghcp.dart';

void main() {
  Directory? td = null;
  setUp(() {
    //print("Creating!");
    assert(td==null);
    td = Directory.systemTemp.createTempSync(); // Directory(path.join(Directory.systemTemp.path, Uuid().v4()));

  });

  tearDown(() {
    try {
      td!.deleteSync(recursive: true);
      td=null;
    } on OSError catch(_) {
      // windows
    }
  });

  test('download to file', () {
    final fn = path.join(td!.path, "file.ext");
    expect(File(fn).existsSync(), false);
    download(
      "https://github.com/rtmigo/cicd/blob/dev/stub.py",
      fn);
    expect(File(fn).existsSync(), true);
  });

  test('download to dir', () {
    final fn = path.join(td!.path, "stub.py");
    expect(File(fn).existsSync(), false);
    download(
        "https://github.com/rtmigo/cicd/blob/dev/stub.py",
        td!.path);
    expect(File(fn).existsSync(), true);
  });

}