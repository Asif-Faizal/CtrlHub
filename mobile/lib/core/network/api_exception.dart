class ApiException implements Exception {
  ApiException(this.message, {this.code, this.details = const {}, this.statusCode});

  final String message;
  final String? code;
  final Map<String, String> details;
  final int? statusCode;

  @override
  String toString() {
    if (details.isEmpty) return message;
    final d = details.entries.map((e) => '${e.key} ${e.value}').join(', ');
    return '$message: $d';
  }
}
