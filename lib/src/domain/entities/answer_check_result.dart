import '../value_objects/rational.dart';

class AnswerCheckResult {
  final bool isCorrect;
  final String message;

  /// Parsed user value, null if parsing failed.
  final Rational? userValue;

  /// Expected value (exact or rounded depending on mode).
  final Rational expected;

  /// If the question expects a decimal input, how many digits are required/used.
  final int decimalDigits;

  const AnswerCheckResult({
    required this.isCorrect,
    required this.message,
    required this.userValue,
    required this.expected,
    required this.decimalDigits,
  });
}
