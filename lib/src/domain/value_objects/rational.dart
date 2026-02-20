import 'dart:math';

/// Exact rational number (fraction) using BigInt.
/// Also used to represent decimals exactly (denominator = 10^scale).
///
/// Immutable, always reduced, denominator always positive.
class Rational implements Comparable<Rational> {
  final BigInt n; // numerator
  final BigInt d; // denominator

  const Rational._(this.n, this.d);

  factory Rational(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) {
      throw ArgumentError('Denominator cannot be zero.');
    }
    if (numerator == BigInt.zero) {
      return Rational._(BigInt.zero, BigInt.one);
    }

    if (denominator.isNegative) {
      numerator = -numerator;
      denominator = -denominator;
    }
    final g = _gcd(numerator.abs(), denominator);
    return Rational._(numerator ~/ g, denominator ~/ g);
  }

  factory Rational.int(int v) => Rational(BigInt.from(v), BigInt.one);

  factory Rational.fromNum(num v, {int maxScale = 6}) {
    final scale = pow(10, maxScale).toInt();
    final scaled = (v * scale).round();
    return Rational(BigInt.from(scaled), BigInt.from(scale));
  }

  /// Exact decimal with given scale: value = integer / 10^scale
  factory Rational.decimal(BigInt integer, int scale) {
    if (scale < 0) throw ArgumentError('scale must be >= 0');
    final denom = BigInt.from(10).pow(scale);
    return Rational(integer, denom);
  }

  Rational operator +(Rational other) =>
      Rational(n * other.d + other.n * d, d * other.d);

  Rational operator -(Rational other) =>
      Rational(n * other.d - other.n * d, d * other.d);

  Rational operator *(Rational other) => Rational(n * other.n, d * other.d);

  Rational operator /(Rational other) {
    if (other.n == BigInt.zero) {
      throw ArgumentError('Division by zero.');
    }
    return Rational(n * other.d, d * other.n);
  }

  Rational operator -() => Rational(-n, d);

  Rational abs() => n.isNegative ? -this : this;

  bool get isInteger => d == BigInt.one;

  int toIntExact() {
    if (!isInteger) throw StateError('Not an integer.');
    return n.toInt();
  }

  double toDouble() => n.toDouble() / d.toDouble();

  /// Proper fraction formatting like "-7/3" or "5".
  String asFractionString() {
    if (d == BigInt.one) return n.toString();
    return '${n.toString()}/${d.toString()}';
  }

  /// Decimal formatting without floating point.
  /// - If value terminates, it will show exact decimal.
  /// - Otherwise it will be rounded to [maxScale].
  String asDecimalString({int maxScale = 6, bool trimTrailingZeros = true}) {
    if (maxScale < 0) throw ArgumentError('maxScale must be >= 0');

    final sign = n.isNegative ? '-' : '';
    final a = n.abs();
    final integerPart = a ~/ d;
    var rem = a % d;

    if (rem == BigInt.zero) return '$sign$integerPart';

    final buf = StringBuffer()..write('$sign$integerPart.');
    for (var i = 0; i < maxScale; i++) {
      rem *= BigInt.from(10);
      final digit = rem ~/ d;
      rem = rem % d;
      buf.write(digit.toString());
      if (rem == BigInt.zero) break;
    }

    var out = buf.toString();
    if (trimTrailingZeros) {
      out = out.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return out;
  }

  /// "mixed number" formatting: 7/3 => "2 1/3"
  String asMixedString() {
    if (d == BigInt.one) return n.toString();
    final sign = n.isNegative ? '-' : '';
    final a = n.abs();
    final whole = a ~/ d;
    final rem = a % d;
    if (whole == BigInt.zero) return asFractionString();
    if (rem == BigInt.zero) return '$sign$whole';
    return '$sign$whole ${Rational(rem, d).asFractionString()}';
  }

  @override
  int compareTo(Rational other) => (n * other.d).compareTo(other.n * d);

  @override
  bool operator ==(Object other) =>
      other is Rational && n == other.n && d == other.d;

  @override
  int get hashCode => Object.hash(n, d);

  @override
  String toString() => asFractionString();

  static BigInt _gcd(BigInt a, BigInt b) {
    while (b != BigInt.zero) {
      final t = a % b;
      a = b;
      b = t;
    }
    return a;
  }
}

// extension _BigIntX on BigInt {
//   BigInt abs() => isNegative ? -this : this;
// }
