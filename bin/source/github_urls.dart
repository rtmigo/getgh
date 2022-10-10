import 'package:kt_dart/collection.dart';

enum GithubPathType { blob, tree }

class GithubPathSegments {
  GithubPathSegments(KtList<String> segmentsArg)
      : segments = segmentsArg.filter((p0) => p0.isNotEmpty);
  final KtList<String> segments;

  String? get user => (this.segments.size >= 1) ? this.segments[0] : null;

  String? get repo => (this.segments.size >= 2) ? this.segments[1] : null;

  String? get typeString => (this.segments.size >= 3) ? this.segments[2] : null;

  String? get branch => (this.segments.size >= 4) ? this.segments[3] : null;

  GithubPathType? get type {
    switch (this.typeString) {
      case "blob":
        return GithubPathType.blob;
      case "tree":
        return GithubPathType.tree;
      default:
        return null;
    }
  }

  KtList<String> withoutBlobAndBranch() {
    if (this.branch != null && this.type != null) {
      return this.segments.take(2) +
          this.segments.subList(4,
              this.segments.size); //.sublist(0, 2) + this.segments.sublist(4);
    } else {
      return this.segments;
    }
  }
}
