import 'dart:math';

import '../../domain/config/generator_config.dart';
import '../../domain/value_objects/rational.dart';

class OperandFactory {
  final Random _rng;

  OperandFactory(this._rng);

  Rational randomOperand({
    required int minInt,
    required int maxInt,
    required GeneratorConfig config,
    required double fractionProb,
    required double decimalProb,
  }) {
    final r = _rng.nextDouble();
    final kinds = config.numberKinds;

    final wantFraction = r < fractionProb && kinds.contains(NumberKind.fraction);
    final wantDecimal = !wantFraction &&
        r < (fractionProb + decimalProb) &&
        kinds.contains(NumberKind.decimal);

    if (wantFraction) {
      return _randomFraction(
        minInt: minInt,
        maxInt: maxInt,
        maxDenominator: config.maxDenominator,
        allowNegative: config.allowNegative,
      );
    }
    if (wantDecimal) {
      return _randomDecimal(
        minInt: minInt,
        maxInt: maxInt,
        scaleMin: config.decimalScaleMin,
        scaleMax: config.decimalScaleMax,
        allowNegative: config.allowNegative,
      );
    }

    final v = _randomInt(minInt, maxInt, allowNegative: config.allowNegative);
    return Rational.int(v);
  }

  int _randomInt(int min, int max, {required bool allowNegative}) {
    if (min > max) {
      final t = min;
      min = max;
      max = t;
    }
    var lo = min;
    var hi = max;

    if (!allowNegative) {
      lo = lo < 0 ? 0 : lo;
      hi = hi < 0 ? 0 : hi;
    }
    final span = (hi - lo + 1);
    if (span <= 0) return lo;
    return lo + _rng.nextInt(span);
  }

  Rational _randomFraction({
    required int minInt,
    required int maxInt,
    required int maxDenominator,
    required bool allowNegative,
  }) {
    final denom = 2 + _rng.nextInt(max(1, maxDenominator - 1));
    final nAbsMax = max(1, maxInt.abs());
    var numer = 1 + _rng.nextInt(nAbsMax);
    if (_rng.nextDouble() < 0.6) {
      numer = 1 + _rng.nextInt(max(1, denom - 1));
    }

    var sign = 1;
    if (allowNegative && _rng.nextBool()) sign = -1;

    if (_rng.nextDouble() < 0.35) {
      final whole = _randomInt(minInt, maxInt, allowNegative: allowNegative).abs();
      final total = BigInt.from(whole * denom + numer) * BigInt.from(sign);
      return Rational(total, BigInt.from(denom));
    }

    return Rational(BigInt.from(numer * sign), BigInt.from(denom));
  }

  Rational _randomDecimal({
    required int minInt,
    required int maxInt,
    required int scaleMin,
    required int scaleMax,
    required bool allowNegative,
  }) {
    final sMin = max(0, scaleMin);
    final sMax = max(sMin, scaleMax);
    final scale = sMin + _rng.nextInt(sMax - sMin + 1);
    final denom = BigInt.from(10).pow(scale);

    final intPart = _randomInt(minInt, maxInt, allowNegative: allowNegative);

    final fracMax = denom.toInt();
    final frac = _rng.nextInt(fracMax);

    var scaled = BigInt.from(intPart) * denom + BigInt.from(frac);

    if (allowNegative && _rng.nextDouble() < 0.25) {
      scaled = -scaled.abs();
    }

    return Rational(scaled, denom);
  }
}
