import 'package:kt_dart/collection.dart';
import 'package:test/test.dart';

import '../bin/source/exceptions.dart';
import '../bin/source/gh_api.dart';

void main() {
  test("call with gh", () async {
    (await listRemoteEntries(argToEndpoint(
            "https://github.com/rtmigo/ghfile_test_data/blob/dev/")))
        .dart;
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

  group("gh error trimming", () {
    test("single line", () {
      expect(GhErrorMessage("gh: Not Found (HTTP 404)").message,
          "Not Found (HTTP 404)");
    });
    test("multi line", () {
      expect(GhErrorMessage("gh: Not Found (HTTP 404)\ngh:  Oops!").message,
          "Not Found (HTTP 404)\nOops!");
    });
  });
}
