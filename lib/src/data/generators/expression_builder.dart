import 'dart:math';

import '../../domain/config/generator_config.dart';
import '../../domain/entities/expression.dart';
import '../../domain/value_objects/difficulty.dart';
import '../../domain/value_objects/math_op.dart';
import '../../domain/value_objects/rational.dart';
import 'operand_factory.dart';

class ExpressionBuilder {
  final Random _rng;
  final OperandFactory _operandFactory;

  ExpressionBuilder(this._rng) : _operandFactory = OperandFactory(_rng);

  Expr build(GeneratorConfig config) {
    final profile = DifficultyDefaults.profile(config.difficulty);

    final integerOnly =
        config.numberKinds.length == 1 &&
        config.numberKinds.contains(NumberKind.integer);

    if (integerOnly &&
        (config.requireIntegerAnswer ||
            config.requireNonNegativeIntermediate)) {
      return _buildSafeInteger(config, profile);
    }

    final maxAllowed = min(config.maxOperands, profile.maxOperands);
    final minAllowed = min(profile.minOperands, maxAllowed);
    final count = (minAllowed == maxAllowed)
        ? minAllowed
        : minAllowed + _rng.nextInt(maxAllowed - minAllowed + 1);

    Expr expr = NumExpr(_randomOperand(profile, config));
    for (var i = 1; i < count; i++) {
      final op = _randomOp(config.allowedOps);
      final right = NumExpr(
        _randomOperand(profile, config, avoidZeroForDiv: op == MathOp.div),
      );
      expr = _combine(expr, op, right, config, profile);
    }

    return expr;
  }

  Expr _buildSafeInteger(GeneratorConfig config, DifficultyProfile profile) {
    final maxAllowed = min(config.maxOperands, profile.maxOperands);
    final minAllowed = min(profile.minOperands, maxAllowed);
    final count = (minAllowed == maxAllowed)
        ? minAllowed
        : minAllowed + _rng.nextInt(maxAllowed - minAllowed + 1);

    var first = _randomOperand(profile, config);
    if (!first.isInteger) first = Rational.int(first.toDouble().round());
    Expr expr = NumExpr(first);
    var current = first;

    for (var i = 1; i < count; i++) {
      var op = _randomOp(config.allowedOps);

      if (config.requireNonNegativeIntermediate && current.isInteger) {
        final cur = current.toIntExact();
        if (op == MathOp.sub && cur == 0) op = MathOp.add;
      }

      if (op == MathOp.div) {
        final cur = current.isInteger ? current.toIntExact().abs() : 0;
        final divisor = _pickDivisor(
          cur,
          maxFactor: max(1, profile.maxInt.abs()),
        );
        final rhs = Rational.int(divisor == 0 ? 1 : divisor);
        expr = BinExpr(expr, MathOp.div, NumExpr(rhs));
        current = current / rhs;
        continue;
      }

      var rhs = _randomOperand(profile, config);
      if (!rhs.isInteger) rhs = Rational.int(rhs.toDouble().round());

      if (op == MathOp.sub &&
          config.requireNonNegativeIntermediate &&
          current.isInteger) {
        final cur = current.toIntExact();
        final b = rhs.toIntExact().abs();
        final safe = b <= cur ? b : (cur == 0 ? 0 : _rng.nextInt(cur + 1));
        rhs = Rational.int(safe);
      }

      expr = BinExpr(expr, op, NumExpr(rhs));
      current = switch (op) {
        MathOp.add => current + rhs,
        MathOp.sub => current - rhs,
        MathOp.mul => current * rhs,
        MathOp.div => current / rhs,
      };
    }

    return expr;
  }

  int _pickDivisor(int absValue, {required int maxFactor}) {
    if (absValue == 0) return 1;

    final limit = min(absValue, maxFactor);
    for (var i = 0; i < 50; i++) {
      final cand = 1 + _rng.nextInt(max(1, limit));
      if (cand != 0 && absValue % cand == 0) return cand;
    }

    return absValue > 1 ? absValue : 1;
  }

  Rational _randomOperand(
    DifficultyProfile profile,
    GeneratorConfig config, {
    bool avoidZeroForDiv = false,
  }) {
    Rational v;
    var tries = 0;
    do {
      v = _operandFactory.randomOperand(
        minInt: profile.minInt,
        maxInt: profile.maxInt,
        config: config,
        fractionProb: profile.fractionProbability,
        decimalProb: profile.decimalProbability,
        friendlyDenominators: profile.friendlyDenominators,
      );
      tries++;

      if (avoidZeroForDiv && v.n == BigInt.zero) continue;
      if (v.abs().toDouble() < 1e-12 && avoidZeroForDiv) continue;
      break;
    } while (tries < 50);

    if (avoidZeroForDiv && v.n == BigInt.zero) return Rational.int(1);

    return v;
  }

  MathOp _randomOp(Set<MathOp> ops) {
    final list = ops.toList(growable: false);
    return list[_rng.nextInt(list.length)];
  }

  Expr _combine(
    Expr current,
    MathOp op,
    Expr right,
    GeneratorConfig config,
    DifficultyProfile profile,
  ) {
    if (_rng.nextDouble() < config.parenthesesProbability &&
        current is BinExpr) {
      final op2 = _randomOp(config.allowedOps);
      final a = NumExpr(
        _randomOperand(profile, config, avoidZeroForDiv: op2 == MathOp.div),
      );
      final b = NumExpr(
        _randomOperand(profile, config, avoidZeroForDiv: op2 == MathOp.div),
      );
      final sub = BinExpr(a, op2, b);
      return BinExpr(current, op, sub);
    }
    return BinExpr(current, op, right);
  }
}
