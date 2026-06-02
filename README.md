# random_math_quiz

Generate random math quiz questions with difficulty levels, exact rational
arithmetic, deterministic seeds, and answer validation.

The package is useful for education apps, practice tools, worksheets, and quiz
generators that need arithmetic questions without floating point drift.

## Features

- Difficulty presets from `DifficultyLevel.l1` to `DifficultyLevel.l7`
- Integer, fraction, and decimal operands
- Exact answers using `Rational`
- Addition, subtraction, multiplication, and division
- Deterministic generation with a seed
- Batch generation
- User answer validation for integers, decimals, and fractions

## Install

```yaml
dependencies:
  random_math_quiz: ^0.1.0
```

Then import it:

```dart
import 'package:random_math_quiz/random_math_quiz.dart';
```

## Quick Start

```dart
import 'package:random_math_quiz/random_math_quiz.dart';

void main() {
  final quiz = MathQuiz(
    config: GeneratorConfig.difficulty(DifficultyLevel.l3),
    seed: 42,
  );

  final question = quiz.next();

  print(question.prompt);
  print(question.answer.asFractionString());
  print(question.answer.asDecimalString(maxScale: 2));
}
```

## Generate a Batch

```dart
final quiz = MathQuiz(
  config: GeneratorConfig.difficulty(DifficultyLevel.l5),
  seed: 7,
);

final questions = quiz.batch(10);

for (final question in questions) {
  print('${question.prompt} ${question.answer.asSmartString()}');
}
```

## Validate User Input

```dart
final quiz = MathQuiz(
  config: GeneratorConfig.difficulty(DifficultyLevel.l5),
  seed: 12,
);

final question = quiz.next();
final result = quiz.checkAnswer(question, '3/4');

print(result.isCorrect);
print(result.message);
print(result.expected.asSmartString());
```

Supported input formats:

- Integers: `12`, `-5`
- Decimals: `1.25`, `1,25`
- Fractions: `3/4`, `-2/5`

## Configuration

```dart
final quiz = MathQuiz(
  config: GeneratorConfig(
    difficulty: DifficultyLevel.l6,
    allowedOps: {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
    numberKinds: {
      NumberKind.integer,
      NumberKind.fraction,
      NumberKind.decimal,
    },
    maxOperands: 4,
    allowNegative: true,
    maxAbsValue: 10000,
    maxDenominator: 50,
    decimalScaleMin: 1,
    decimalScaleMax: 2,
    parenthesesProbability: 0.35,
    promptNumberDisplay: NumberDisplay.smart,
    unicodeOperators: true,
  ),
);
```

## Difficulty Levels

`GeneratorConfig.difficulty(level)` provides staged defaults:

- `l1` to `l2`: simple integer addition/subtraction
- `l3` to `l4`: larger integers, multiplication, and division
- `l5`: fractions and decimals with friendly values
- `l6` to `l7`: more operands, negatives, fractions, decimals, and parentheses

You can override any field by creating `GeneratorConfig` manually.

## Exact Arithmetic

Answers are stored as `Rational`, so fractions and decimals are represented
exactly.

```dart
final value = Rational(BigInt.from(1), BigInt.from(3));

print(value.asFractionString()); // 1/3
print(value.asDecimalString(maxScale: 2)); // 0.33
print(value.asMixedString()); // 1/3
```

## Deterministic Questions

Pass the same seed and config to reproduce the same question sequence.

```dart
final a = MathQuiz(config: config, seed: 123);
final b = MathQuiz(config: config, seed: 123);

print(a.next().prompt == b.next().prompt); // true
```
