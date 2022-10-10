import 'package:test/test.dart';

import '../bin/source/gh_api.dart';

void main() {
  test("call with gh", () {
    getEntries(argToEndpoint("https://github.com/rtmigo/ghfile_test_data/blob/dev/")).toList();
  });

  test("call without gh", () {
    expect(()=>
    getEntries(
        argToEndpoint("https://github.com/rtmigo/ghfile_test_data/blob/dev/"),
      executable: "gh_non_existent"
    ).toList(),
      throwsA(isA<GhNotInstalledException>())
    );
  });

}