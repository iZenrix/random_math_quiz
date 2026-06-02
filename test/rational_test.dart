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

  test('Decimal formatting rounds half-up', () {
    final oneThird = Rational(BigInt.one, BigInt.from(3));
    expect(oneThird.asDecimalString(maxScale: 2), '0.33');

    final twoThirds = Rational(BigInt.from(2), BigInt.from(3));
    expect(twoThirds.asDecimalString(maxScale: 2), '0.67');

    final carry = Rational(BigInt.from(1999), BigInt.from(2000));
    expect(carry.asDecimalString(maxScale: 2), '1');
  });

  test('Decimal formatting supports zero scale rounding', () {
    expect(
      Rational(BigInt.from(1), BigInt.from(2)).asDecimalString(maxScale: 0),
      '1',
    );
    expect(
      Rational(BigInt.from(-1), BigInt.from(2)).asDecimalString(maxScale: 0),
      '-1',
    );
  });

  test('Operations are exact', () {
    final a = Rational(BigInt.from(1), BigInt.from(3));
    final b = Rational(BigInt.from(1), BigInt.from(6));
    expect((a + b).asFractionString(), '1/2');
    expect((a * b).asFractionString(), '1/18');
  });
}
