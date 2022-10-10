import 'package:kt_dart/collection.dart';
import 'package:test/test.dart';

import '../bin/source/gh_api.dart';
import '../bin/source/github_urls.dart';

void main() {
  group('URL segments to user/repo/dir/file', () {
    test('from blob', () {
      expect(
          GithubPathSegments("user/repo/blob/branch/dir/file.ext".split("/").kt)
              .withoutBlobAndBranch(),
          ["user", "repo", "dir", "file.ext"].kt);
    });

    test('from tree', () {
      expect(
          GithubPathSegments("user/repo/tree/branch/dir".split("/").kt)
              .withoutBlobAndBranch(),
          ["user", "repo", "dir"].kt);
    });

    test('from tree ending with slash', () {
      expect(
          GithubPathSegments("user/repo/tree/branch/dir/".split("/").kt)
              .withoutBlobAndBranch(),
          ["user", "repo", "dir"].kt);
    });
  });

  test('argToEndpoint', () {
    expect(
        argToEndpoint("https://github.com/rtmigo/cicd/blob/dev/stub.py")
            .string,
        "/repos/rtmigo/cicd/contents/stub.py?ref=dev");

    expect(argToEndpoint("https://github.com/rtmigo/cicd/stub.py").string,
        "/repos/rtmigo/cicd/contents/stub.py");

    expect(argToEndpoint("/repos/rtmigo/cicd/contents/stub.py").string,
        "/repos/rtmigo/cicd/contents/stub.py");

    expect(
        argToEndpoint("https://github.com/rtmigo/ghfile_test_data")
            .string,
        "/repos/rtmigo/ghfile_test_data/contents");
  });
}
