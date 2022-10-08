import 'package:test/test.dart';

import '../bin/source/gh_api.dart';

void main() {
  test('remove blob and branch', () {
    expect(
        removeBlobAndBranch("user/repo/blob/branch/file.ext".split("/")),
        ["user", "repo", "file.ext"]);
  });

  test('argToEndpoint', () {
    expect(argToEndpoint("https://github.com/rtmigo/cicd/blob/dev/stub.py").right.string,
        "/repos/rtmigo/cicd/contents/stub.py?ref=dev");


    expect(argToEndpoint("https://github.com/rtmigo/cicd/stub.py").right.string,
        "/repos/rtmigo/cicd/contents/stub.py");

    expect(argToEndpoint("/repos/rtmigo/cicd/contents/stub.py").right.string,
        "/repos/rtmigo/cicd/contents/stub.py");
  });
}