import 'package:random_math_quiz/random_math_quiz.dart';
import 'package:random_math_quiz/src/domain/entities/expression.dart';
import 'package:test/test.dart';

void main() {
  test('Integer-only config rejects non-integer answers', () {
    final quiz = MathQuiz(
      config: GeneratorConfig(
        difficulty: DifficultyLevel.l4,
        allowedOps: {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
        numberKinds: {NumberKind.integer},
        requireIntegerAnswer: true,
        requireNonNegativeResult: true,
        requireNonNegativeOperands: true,
        requireNonNegativeIntermediate: true,
      ),
      seed: 10,
    );

    for (var i = 0; i < 30; i++) {
      final q = quiz.next();
      expect(q.answer.isInteger, isTrue);
      expect(q.answer.n.isNegative, isFalse);
    }
  });

  test('Decimal validation rounds to required digits', () {
    final quiz = MathQuiz(
      config: GeneratorConfig(
        difficulty: DifficultyLevel.l6,
        allowedOps: {MathOp.add},
        numberKinds: {NumberKind.decimal},
        maxDecimalAnswerDigits: 2,
        roundDecimalAnswerToMaxDigits: true,
        strictDecimalInputDigits: false,
        allowDecimalInput: true,
        promptNumberDisplay: NumberDisplay.decimal,
        promptDecimalMaxScale: 2,
        requireNonNegativeResult: true,
      ),
      seed: 1,
    );

    // Force a known question
    final q = MathQuestion(
      id: 'x',
      prompt: 'dummy',
      answer: Rational.decimal(BigInt.from(4123), 5), // 0.04123
      difficulty: DifficultyLevel.l6,
      expression: NumExpr(Rational.int(0)),
      metadata: const {'answer_mode': 'decimal', 'decimal_digits': 2},
      explanationSteps: const [],
    );

    final res1 = quiz.checkAnswer(q, '0,04');
    expect(res1.isCorrect, isTrue);

    final res2 = quiz.checkAnswer(q, '0,0');
    expect(res2.isCorrect, isFalse);
  });
}
