class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    // Spring Boot validation errors may return message as List<String>.
    final rawMessage = json['message'];
    final message = rawMessage is List
        ? rawMessage.join('; ')
        : rawMessage as String?;

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: message,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
