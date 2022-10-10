import 'package:kt_dart/collection.dart';
import 'package:test/test.dart';

import '../bin/source/gh_api.dart';

void main() {
  test("call with gh", () async {
    (await listRemoteEntries(argToEndpoint(
            "https://github.com/rtmigo/ghfile_test_data/blob/dev/"))).dart;
  });

  test("call without gh", () {
    expect(
        () async => (await listRemoteEntries(
                argToEndpoint(
                    "https://github.com/rtmigo/ghfile_test_data/blob/dev/"),
                executable: "gh_non_existent"))
            .dart,
        throwsA(isA<GhNotInstalledException>()));
  });
}
