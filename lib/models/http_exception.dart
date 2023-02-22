class HttpException implements Exception {
  String messege;
  HttpException(this.messege);

  @override
  String toString() {
    return messege;
  }
}
