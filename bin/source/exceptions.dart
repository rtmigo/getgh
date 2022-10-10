class ExpectedException extends Error {
  ExpectedException(this.message);
  final String message;
}

class UnsupportedContentTypeException extends ExpectedException {
  UnsupportedContentTypeException(String s): super(s);
}