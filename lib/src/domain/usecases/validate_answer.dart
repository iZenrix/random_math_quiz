import '../config/generator_config.dart';
import '../entities/answer_check_result.dart';
import '../entities/math_question.dart';
import '../value_objects/rational.dart';

class ValidateAnswer {
  const ValidateAnswer();

  AnswerCheckResult call({
    required MathQuestion question,
    required String userInput,
    required GeneratorConfig config,
  }) {
    final mode =
        (question.metadata['answer_mode'] as String?) ??
        _inferMode(question.answer, config);
    final digits =
        (question.metadata['decimal_digits'] as int?) ??
        config.maxDecimalAnswerDigits;

    final parsed = _parseUserInput(userInput.trim(), config);
    if (parsed == null) {
      return AnswerCheckResult(
        isCorrect: false,
        message: 'Input tidak valid.',
        userValue: null,
        expected: question.answer,
        decimalDigits: digits,
      );
    }

    if (config.requireIntegerAnswer || mode == 'integer') {
      if (!parsed.isInteger) {
        return AnswerCheckResult(
          isCorrect: false,
          message: 'Jawaban harus berupa angka bulat.',
          userValue: parsed,
          expected: question.answer,
          decimalDigits: 0,
        );
      }
      final ok = parsed == question.answer;
      return AnswerCheckResult(
        isCorrect: ok,
        message: ok ? 'Benar' : 'Salah',
        userValue: parsed,
        expected: question.answer,
        decimalDigits: 0,
      );
    }

    if (mode == 'decimal') {
      if (!config.allowDecimalInput) {
        return AnswerCheckResult(
          isCorrect: false,
          message: 'Jawaban desimal tidak diizinkan.',
          userValue: parsed,
          expected: question.answer,
          decimalDigits: digits,
        );
      }

      final userDigits = _countDecimalDigits(userInput);
      if (config.strictDecimalInputDigits &&
          userDigits != null &&
          userDigits > digits) {
        return AnswerCheckResult(
          isCorrect: false,
          message:
              'Terlalu banyak angka di belakang koma. Maksimal $digits digit.',
          userValue: parsed,
          expected: question.answer,
          decimalDigits: digits,
        );
      }

      final expectedRounded = config.roundDecimalAnswerToMaxDigits
          ? _roundToDigits(question.answer, digits)
          : question.answer;
      final userRounded = config.roundDecimalAnswerToMaxDigits
          ? _roundToDigits(parsed, digits)
          : parsed;

      final ok = expectedRounded == userRounded;
      return AnswerCheckResult(
        isCorrect: ok,
        message: ok ? 'Benar' : 'Salah',
        userValue: parsed,
        expected: expectedRounded,
        decimalDigits: digits,
      );
    }

    if (mode == 'fraction') {
      if (!config.allowFractionInput) {
        return AnswerCheckResult(
          isCorrect: false,
          message: 'Jawaban pecahan tidak diizinkan.',
          userValue: parsed,
          expected: question.answer,
          decimalDigits: 0,
        );
      }

      final ok = parsed == question.answer;
      return AnswerCheckResult(
        isCorrect: ok,
        message: ok ? 'Benar' : 'Salah',
        userValue: parsed,
        expected: question.answer,
        decimalDigits: 0,
      );
    }

    final ok = parsed == question.answer;
    return AnswerCheckResult(
      isCorrect: ok,
      message: ok ? 'Benar' : 'Salah',
      userValue: parsed,
      expected: question.answer,
      decimalDigits: 0,
    );
  }

  String _inferMode(Rational ans, GeneratorConfig config) {
    if (config.requireIntegerAnswer || ans.isInteger) return 'integer';
    final s = ans.terminatingDecimalScale();
    if (s != null &&
        s <= config.maxDecimalAnswerDigits &&
        config.allowDecimalInput) {
      return 'decimal';
    }
    return 'fraction';
  }

  int? _countDecimalDigits(String input) {
    final s = input.replaceAll(' ', '');
    final idxDot = s.indexOf('.');
    final idxCom = s.indexOf(',');
    final idx = idxDot >= 0 ? idxDot : idxCom;
    if (idx < 0) return null;
    return s.length - idx - 1;
  }

  /// Parse user input:
  /// - integer: "12"
  /// - decimal: "12.3" or "12,3"
  /// - fraction: "3/5" (spaces allowed around /)
  Rational? _parseUserInput(String input, GeneratorConfig config) {
    if (input.isEmpty) return null;
    final s = input.replaceAll(' ', '');

    if (s.contains('/')) {
      if (!config.allowFractionInput) return null;
      final parts = s.split('/');
      if (parts.length != 2) return null;
      final a = BigInt.tryParse(parts[0]);
      final b = BigInt.tryParse(parts[1]);
      if (a == null || b == null) return null;
      if (b == BigInt.zero) return null;
      return Rational(a, b);
    }

    final normalized = s.replaceAll(',', '.');
    if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(normalized)) return null;

    if (normalized.contains('.')) {
      if (!config.allowDecimalInput) return null;
      final parts = normalized.split('.');
      final whole = BigInt.tryParse(parts[0]);
      final frac = parts.length > 1 ? parts[1] : '';
      if (whole == null) return null;
      final scale = frac.length;
      final fracInt = frac.isEmpty
          ? BigInt.zero
          : BigInt.tryParse(frac) ?? BigInt.zero;
      final denom = BigInt.from(10).pow(scale);
      final sign = whole.isNegative ? -BigInt.one : BigInt.one;
      final absWhole = whole.abs();
      final scaled = (absWhole * denom + fracInt) * sign;
      return Rational(scaled, denom);
    }

    final whole = BigInt.tryParse(normalized);
    if (whole == null) return null;
    return Rational(whole, BigInt.one);
  }

  /// Round rational to given decimal digits using HALF-UP rounding.
  Rational _roundToDigits(Rational value, int digits) {
    if (digits <= 0) {
      final denom = value.d;
      final n = value.n;
      final isNeg = n.isNegative;
      final absN = n.abs();
      final q = absN ~/ denom;
      final r = absN % denom;
      final up = (r * BigInt.from(2)) >= denom;
      final rounded = q + (up ? BigInt.one : BigInt.zero);
      return Rational(isNeg ? -rounded : rounded, BigInt.one);
    }

    final scale = BigInt.from(10).pow(digits);
    final scaledN = value.n * scale;
    final denom = value.d;

    final isNeg = scaledN.isNegative;
    final absN = scaledN.abs();
    final q = absN ~/ denom;
    final r = absN % denom;

    final up = (r * BigInt.from(2)) >= denom;
    final rounded = q + (up ? BigInt.one : BigInt.zero);
    final outN = isNeg ? -rounded : rounded;

    return Rational(outN, scale);
  }
}
