import 'package:random_math_quiz/random_math_quiz.dart';
import 'package:test/test.dart';

void main() {
  test('Generator produces deterministic sequence with seed', () {
    final cfg = GeneratorConfig.difficulty(DifficultyLevel.l3);

    final quiz1 = MathQuiz(config: cfg, seed: 123);
    final quiz2 = MathQuiz(config: cfg, seed: 123);

    final a1 = List.generate(10, (_) => quiz1.next().prompt).join('|');
    final a2 = List.generate(10, (_) => quiz2.next().prompt).join('|');

    expect(a1, a2);
  });

  test('Generated answer matches expression eval', () {
    final quiz = MathQuiz(
      config: GeneratorConfig(
        difficulty: DifficultyLevel.l4,
        allowedOps: {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
        numberKinds: {NumberKind.integer, NumberKind.fraction, NumberKind.decimal},
        maxOperands: 4,
        allowNegative: true,
        maxAbsValue: 10000,
        maxDenominator: 50,
        decimalScaleMin: 1,
        decimalScaleMax: 3,
        parenthesesProbability: 0.4,
      ),
      seed: 77,
    );

    for (var i = 0; i < 200; i++) {
      final q = quiz.next();
      final eval = q.expression.eval();
      expect(eval, q.answer);
    }
  });

  test('No division by zero produced', () {
    final quiz = MathQuiz(
      config: GeneratorConfig(
        difficulty: DifficultyLevel.l5,
        allowedOps: {MathOp.div},
        numberKinds: {NumberKind.integer, NumberKind.fraction, NumberKind.decimal},
        maxOperands: 3,
        allowNegative: true,
      ),
      seed: 9,
    );

    for (var i = 0; i < 200; i++) {
      final q = quiz.next();
      // If division by zero happened, it would have been retried/fallback.
      expect(q.answer.d != BigInt.zero, isTrue);
    }
  });
}
