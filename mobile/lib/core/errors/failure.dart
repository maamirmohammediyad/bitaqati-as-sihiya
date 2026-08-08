class Failure {
  final String message;
  final dynamic error;

  const Failure({
    required this.message,
    this.error,
  });

  @override
  String toString() => 'Failure: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}