import 'dart:math';

import '../../domain/config/generator_config.dart';
import '../../domain/entities/expression.dart';
import '../../domain/entities/math_question.dart';
import '../../domain/repositories/math_question_repository.dart';
import '../../domain/value_objects/rational.dart';
import '../generators/expression_builder.dart';
import '../random/random_provider.dart';

class RandomMathQuestionRepository implements MathQuestionRepository {
  final RandomProvider _randomProvider;
  final ExpressionBuilder _builder;

  RandomMathQuestionRepository._(this._randomProvider, this._builder);

  factory RandomMathQuestionRepository({int? seed}) {
    final rp = SeededRandomProvider(seed: seed);
    final builder = ExpressionBuilder(rp.rng);
    return RandomMathQuestionRepository._(rp, builder);
  }

  @override
  MathQuestion generate(GeneratorConfig config) {
    final rng = _randomProvider.rng;

    const maxAttempts = 80;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final expr = _builder.build(config);
      Rational ans;

      try {
        ans = expr.eval();
      } catch (_) {
        continue;
      }

      if (ans.abs().toDouble() > config.maxAbsValue) continue;

      final formatter = ExprFormatter(
        unicodeOps: config.unicodeOperators,
        numberDisplay: NumberDisplay.mixed,
        decimalMaxScale: max(config.decimalScaleMax, 6),
      );

      final prompt = '${expr.format(formatter)} = ?';

      return MathQuestion(
        id: _id(rng),
        prompt: prompt,
        answer: ans,
        difficulty: config.difficulty,
        expression: expr,
        metadata: {
          'seeded': _randomProvider is SeededRandomProvider,
          'attempt': attempt,
        },
        explanationSteps: _basicSteps(expr),
      );
    }

    final fallbackExpr = NumExpr(Rational.int(1));
    return MathQuestion(
      id: _id(_randomProvider.rng),
      prompt: '1 = ?',
      answer: Rational.int(1),
      difficulty: config.difficulty,
      expression: fallbackExpr,
    );
  }

  @override
  List<MathQuestion> generateBatch(GeneratorConfig config, int count) {
    if (count < 0) throw ArgumentError('count must be >= 0');
    final out = <MathQuestion>[];
    for (var i = 0; i < count; i++) {
      out.add(generate(config));
    }
    return out;
  }

  String _id(Random rng) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final sb = StringBuffer();
    for (var i = 0; i < 10; i++) {
      sb.write(chars[rng.nextInt(chars.length)]);
    }
    return sb.toString();
  }

  List<String> _basicSteps(Expr expr) {
    final ans = expr.eval();
    return ['Evaluate the expression to get ${ans.asFractionString()}'];
  }
}
