# random_math_quiz

A tiny, dependency-light Dart package to generate **random math questions** with **difficulty levels**, supporting:

- Integers
- Fractions (exact rational arithmetic)
- Decimals (represented exactly as rationals, no floating point drift)

## Quick start

```dart
import 'package:random_math_quiz/random_math_quiz.dart';

void main() {
  final quiz = MathQuiz(
    config: GeneratorConfig.difficulty(DifficultyLevel.l3),
    seed: 42,
  );

  final q = quiz.next();
  print(q.prompt);
  print("Answer (fraction): ${q.answer.asFractionString()}");
  print("Answer (decimal):   ${q.answer.asDecimalString(maxScale: 6)}");
}
```

## Configuration

```dart
final quiz = MathQuiz(
  config: GeneratorConfig(
    difficulty: DifficultyLevel.l4,
    allowedOps: {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
    numberKinds: {NumberKind.integer, NumberKind.fraction, NumberKind.decimal},
    maxOperands: 4,
    allowNegative: true,
    maxAbsValue: 10_000,
    maxDenominator: 50,
    decimalScaleMin: 1,
    decimalScaleMax: 3,
    parenthesesProbability: 0.35,
  ),
);
```