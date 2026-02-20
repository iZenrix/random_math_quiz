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

    final maxAllowed = min(config.maxOperands, profile.maxOperands);
    final minAllowed = min(profile.minOperands, maxAllowed);
    final count = (minAllowed == maxAllowed)
        ? minAllowed
        : minAllowed + _rng.nextInt(maxAllowed - minAllowed + 1);

    Expr expr = NumExpr(_randomOperand(profile, config));
    for (var i = 1; i < count; i++) {
      final op = _randomOp(config.allowedOps);
      final right = NumExpr(_randomOperand(profile, config, avoidZeroForDiv: op == MathOp.div));
      expr = _combine(expr, op, right, config, profile);
    }

    return expr;
  }

  Expr _combine(Expr current, MathOp op, Expr right, GeneratorConfig config, DifficultyProfile profile) {
    if (_rng.nextDouble() < config.parenthesesProbability && current is BinExpr) {
      final op2 = _randomOp(config.allowedOps);
      final a = NumExpr(_randomOperand(profile, config, avoidZeroForDiv: op2 == MathOp.div));
      final b = NumExpr(_randomOperand(profile, config, avoidZeroForDiv: op2 == MathOp.div));
      final sub = BinExpr(a, op2, b);
      return BinExpr(current, op, sub);
    }
    return BinExpr(current, op, right);
  }

  MathOp _randomOp(Set<MathOp> allowed) {
    final list = allowed.toList(growable: false);
    return list[_rng.nextInt(list.length)];
  }

  Rational _randomOperand(DifficultyProfile profile, GeneratorConfig config, {bool avoidZeroForDiv = false}) {
    Rational v;
    var tries = 0;
    do {
      v = _operandFactory.randomOperand(
        minInt: profile.minInt,
        maxInt: profile.maxInt,
        config: config,
        fractionProb: profile.fractionProbability,
        decimalProb: profile.decimalProbability,
      );
      tries++;
      if (avoidZeroForDiv && v.n == BigInt.zero) continue;
      if (v.abs().toDouble() < 1e-12 && avoidZeroForDiv) continue;
      break;
    } while (tries < 50);

    if (avoidZeroForDiv && v.n == BigInt.zero) {
      return Rational.int(1);
    }
    return v;
  }
}
