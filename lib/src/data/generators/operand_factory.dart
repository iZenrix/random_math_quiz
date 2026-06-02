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
    List<int>? friendlyDenominators,
  }) {
    final allowNeg = config.allowNegative && !config.requireNonNegativeOperands;

    final r = _rng.nextDouble();
    final kinds = config.numberKinds;

    final wantFraction =
        r < fractionProb && kinds.contains(NumberKind.fraction);
    final wantDecimal =
        !wantFraction &&
        r < (fractionProb + decimalProb) &&
        kinds.contains(NumberKind.decimal);

    if (wantFraction) {
      return _randomFraction(
        minInt: minInt,
        maxInt: maxInt,
        maxDenominator: config.maxDenominator,
        allowNegative: allowNeg,
        friendlyDenominators: friendlyDenominators,
      );
    }
    if (wantDecimal) {
      return _randomDecimal(
        minInt: minInt,
        maxInt: maxInt,
        scaleMin: config.decimalScaleMin,
        scaleMax: config.decimalScaleMax,
        allowNegative: allowNeg,
      );
    }

    final v = _randomInt(minInt, maxInt, allowNegative: allowNeg);
    return Rational.int(v);
  }

  int _randomInt(int min, int max, {required bool allowNegative}) {
    if (min > max) {
      final t = min;
      min = max;
      max = t;
    }

    if (!allowNegative && min < 0) min = 0;

    final range = max - min;
    if (range <= 0) return min;

    return min + _rng.nextInt(range + 1);
  }

  Rational _randomFraction({
    required int minInt,
    required int maxInt,
    required int maxDenominator,
    required bool allowNegative,
    List<int>? friendlyDenominators,
  }) {
    final denom =
        (friendlyDenominators != null && friendlyDenominators.isNotEmpty)
        ? friendlyDenominators[_rng.nextInt(friendlyDenominators.length)]
        : 2 + _rng.nextInt(max(1, maxDenominator - 1));

    final nAbsMax = max(1, maxInt.abs());
    var numer = 1 + _rng.nextInt(nAbsMax);

    if (_rng.nextDouble() < 0.6) {
      numer = 1 + _rng.nextInt(max(1, denom - 1));
    }

    var sign = 1;
    if (allowNegative && _rng.nextBool()) sign = -1;

    return Rational(BigInt.from(numer * sign), BigInt.from(denom));
  }

  Rational _randomDecimal({
    required int minInt,
    required int maxInt,
    required int scaleMin,
    required int scaleMax,
    required bool allowNegative,
  }) {
    final minScale = min(scaleMin, scaleMax);
    final maxScale = max(scaleMin, scaleMax);

    final scale = (minScale == maxScale)
        ? minScale
        : minScale + _rng.nextInt(maxScale - minScale + 1);

    final denom = BigInt.from(10).pow(scale);

    final i = _randomInt(minInt, maxInt, allowNegative: allowNegative);

    final frac = _rng.nextInt(pow(10, scale).toInt());
    final sign = (i < 0) ? -BigInt.one : BigInt.one;
    final absI = BigInt.from(i).abs();

    final total = (absI * denom + BigInt.from(frac)) * sign;
    return Rational(total, denom);
  }
}
