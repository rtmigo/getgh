class ExpectedException extends Error {
  ExpectedException(this.message);
  final String message;
}

class GhErrorMessage extends ExpectedException {
  GhErrorMessage(final String stderr): super(_trim(stderr));

  static String _trim(final String stderr) {
    return stderr.trim().replaceAll(RegExp("gh:\\s+"), "");
  }
}

class UnsupportedContentTypeException extends ExpectedException {
  UnsupportedContentTypeException(final String s): super(s);
}