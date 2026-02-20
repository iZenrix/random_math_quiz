import 'package:random_math_quiz/random_math_quiz.dart';
import 'package:test/test.dart';

void main() {
  test('Rational reduces and normalizes sign', () {
    final r = Rational(BigInt.from(2), BigInt.from(4));
    expect(r.asFractionString(), '1/2');

    final r2 = Rational(BigInt.from(1), BigInt.from(-2));
    expect(r2.asFractionString(), '-1/2');
  });

  test('Exact decimal formatting', () {
    final r = Rational.decimal(BigInt.from(1234), 2); // 12.34
    expect(r.asDecimalString(maxScale: 6), '12.34');
    expect(r.asFractionString(), '617/50');
  });

  test('Operations are exact', () {
    final a = Rational(BigInt.from(1), BigInt.from(3));
    final b = Rational(BigInt.from(1), BigInt.from(6));
    expect((a + b).asFractionString(), '1/2');
    expect((a * b).asFractionString(), '1/18');
  });
}
