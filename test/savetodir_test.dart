import 'dart:io';


import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../bin/hubget.dart';
import '../bin/source/gh_api.dart';
import '../bin/source/saving.dart';

void main() {
  Directory? td = null;
  setUp(() {
    assert(td == null);
    td = Directory.systemTemp.createTempSync();
  });

  tearDown(() {
    try {
      td!.deleteSync(recursive: true);
      td = null;
    } on OSError catch (_) {
      // windows
    }
  });

  if (true) {
    test('download file to file', () async {
      final target = File(path.join(td!.path, "a.md"));

      expect(td!.listSync().length, 0);
      expect(target.existsSync(), false);

      await cliUpdate(
          argToEndpoint(
              "https://github.com/rtmigo/ghfile_test_data/blob/dev/dir-abc/a.md"),
          target.path);

      expect(td!.listSync().length, 1);
      expect(target.existsSync(), true);
    });

    test('download file to non-existent dir (target ends with slash)', () async {
      final target = File(path.join(td!.path, "d1", "d2"));

      expect(td!.listSync().length, 0);

      await cliUpdate(
          argToEndpoint(
              "https://github.com/rtmigo/ghfile_test_data/blob/dev/dir-abc/a.md"),
          "${target.path}${path.separator}");

      expect(td!.listSync().length, 1);
      expect(File(path.join(td!.path, "d1", "d2", "a.md")).existsSync(), true);
    });

    test('download file to existent dir', () async {
      final fn = path.join(td!.path, "a.md");

      expect(td!.listSync().length, 0);
      expect(File(fn).existsSync(), false);

      await cliUpdate(
          argToEndpoint(
              "https://github.com/rtmigo/ghfile_test_data/blob/dev/dir-abc/a.md"),
          td!.path);

      expect(td!.listSync().length, 1);
      expect(File(fn).existsSync(), true);
    });

    test('download file to existent dir (dir name ends with slash)', () async {
      final fn = path.join(td!.path, "a.md");

      expect(td!.listSync().length, 0);
      expect(File(fn).existsSync(), false);

      await cliUpdate(
          argToEndpoint(
              "https://github.com/rtmigo/ghfile_test_data/blob/dev/dir-abc/a.md"),
          td!.path + path.separator);

      expect(td!.listSync().length, 1);
      expect(File(fn).existsSync(), true);
    });


    test('download flat dir', () async {
      final exitCode = await cliUpdate(
          argToEndpoint(
              "https://github.com/rtmigo/ghfile_test_data/blob/dev/dir-abc/"),
          td!.path);

      expect(td!.listSync(recursive: true).length, 3);
      expect(File(path.join(td!.path, "a.md")).existsSync(), true);
      expect(File(path.join(td!.path, "b.md")).existsSync(), true);
      expect(File(path.join(td!.path, "c.md")).existsSync(), true);
      expect(exitCode, 0);
    });

    test('download flat dir with extra slash', () async {
      await cliUpdate(
          argToEndpoint(
              "https://github.com/rtmigo/ghfile_test_data/blob/dev/dir-abc/"),
          "${td!.path}/");

      expect(td!.listSync(recursive: true).length, 3);
      expect(File(path.join(td!.path, "a.md")).existsSync(), true);
      expect(File(path.join(td!.path, "b.md")).existsSync(), true);
      expect(File(path.join(td!.path, "c.md")).existsSync(), true);
    });

    test('download subdirs dir', () async {
      await cliUpdate(
          argToEndpoint(
              "https://github.com/rtmigo/ghfile_test_data/blob/dev/"),
          td!.path);

      expect(td!.listSync(recursive: true).length, greaterThan(5));
      expect(File(path.join(td!.path, "file_one.txt")).existsSync(), true);
      expect(File(path.join(td!.path, "file_two.txt")).existsSync(), true);
      expect(File(path.join(td!.path, "dir-abc", "a.md")).existsSync(), true);
      expect(File(path.join(td!.path, "dir-abc", "b.md")).existsSync(), true);
      expect(File(path.join(td!.path, "dir-abc", "c.md")).existsSync(), true);
    });

    test('download whole repo by offical url', () async {
      final exitCode = await cliUpdate(
          argToEndpoint(
            // no BLOB or TREE
              "https://github.com/rtmigo/ghfile_test_data"),
          td!.path);

      expect(td!.listSync(recursive: true).length, greaterThan(5));
      expect(File(path.join(td!.path, "dir-abc", "a.md")).existsSync(), true);
      expect(File(path.join(td!.path, "dir-abc", "b.md")).existsSync(), true);
      expect(File(path.join(td!.path, "dir-abc", "c.md")).existsSync(), true);
      expect(exitCode, isNot(0)); // потому что submodule не скачан
    });
  }

  test('download binary 5mb file', () async {
    await cliUpdate(
        argToEndpoint(
            "https://github.com/rtmigo/exe2dist/blob/master/test/executables/ghcp_osx_amd64"),
        td!.path);

    final files = td!.listSync(recursive: true);
    expect(files.length, 1);
    expect(files.single.statSync().size, greaterThan(1024*1024*4));
  });
}
