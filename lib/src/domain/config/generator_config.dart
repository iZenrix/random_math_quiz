import '../value_objects/difficulty.dart';
import '../value_objects/math_op.dart';
import '../entities/expression.dart';

enum NumberKind { integer, fraction, decimal }

class GeneratorConfig {
  final DifficultyLevel difficulty;

  /// Allowed math operations.
  final Set<MathOp> allowedOps;

  /// Which kind of numbers may appear in operands.
  final Set<NumberKind> numberKinds;

  /// Maximum operands to generate (actual count will depend on difficulty profile).
  final int maxOperands;

  /// If true, negatives may appear in operand generation (unless requireNonNegativeOperands=true).
  final bool allowNegative;

  /// Limit absolute value of intermediate and final results (helps keep questions readable).
  final int maxAbsValue;

  /// If true, generator will reject questions whose final answer is negative.
  final bool requireNonNegativeResult;

  /// If true, generator will reject questions with negative operands.
  /// (Even if allowNegative=true)
  final bool requireNonNegativeOperands;

  /// If true, generator will reject questions whose intermediate results become negative.
  /// Useful for kids levels.
  final bool requireNonNegativeIntermediate;

  /// If true, generator will only accept questions whose final answer is an integer.
  /// This is the "jawaban pure angka" mode (no decimals/fractions).
  final bool requireIntegerAnswer;

  /// If answer is treated as decimal for input/validation, the maximum digits allowed after the decimal point.
  /// Recommended: 1 or 2.
  final int maxDecimalAnswerDigits;

  /// If true, when the exact answer has more decimals than maxDecimalAnswerDigits,
  /// validation will compare using rounded values to maxDecimalAnswerDigits.
  final bool roundDecimalAnswerToMaxDigits;

  /// If true, reject decimal user input that has more than maxDecimalAnswerDigits.
  final bool strictDecimalInputDigits;

  /// Whether user input is allowed to be a fraction (a/b) when answer mode is fraction.
  final bool allowFractionInput;

  /// Whether user input is allowed to be a decimal when answer mode is decimal.
  final bool allowDecimalInput;

  /// How numbers are displayed in the prompt.
  /// - smart: integer as-is, terminating decimal as decimal, otherwise fraction.
  /// - fraction: always a/b (improper fraction, no mixed numbers)
  /// - decimal: always decimal string (may truncate repeating decimals)
  final NumberDisplay promptNumberDisplay;

  /// Max decimal digits when promptNumberDisplay is decimal/smart.
  final int promptDecimalMaxScale;

  /// If generating fractions, denominator will be in [2..maxDenominator].
  final int maxDenominator;

  /// If generating decimals, scale will be in [decimalScaleMin..decimalScaleMax].
  final int decimalScaleMin;
  final int decimalScaleMax;

  /// Probability to generate parentheses during expression building (0..1).
  final double parenthesesProbability;

  /// Use unicode operators (×, ÷) in prompt.
  final bool unicodeOperators;

  const GeneratorConfig({
    required this.difficulty,
    this.allowedOps = const {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
    this.numberKinds = const {
      NumberKind.integer,
      NumberKind.fraction,
      NumberKind.decimal,
    },
    this.maxOperands = 5,
    this.allowNegative = false,
    this.maxAbsValue = 10000,
    this.requireNonNegativeResult = true,
    this.requireNonNegativeOperands = true,
    this.requireNonNegativeIntermediate = true,
    this.requireIntegerAnswer = false,
    this.maxDecimalAnswerDigits = 2,
    this.roundDecimalAnswerToMaxDigits = true,
    this.strictDecimalInputDigits = false,
    this.allowFractionInput = true,
    this.allowDecimalInput = true,
    this.promptNumberDisplay = NumberDisplay.smart,
    this.promptDecimalMaxScale = 6,
    this.maxDenominator = 50,
    this.decimalScaleMin = 1,
    this.decimalScaleMax = 3,
    this.parenthesesProbability = 0.25,
    this.unicodeOperators = true,
  }) : assert(allowedOps.length > 0, 'allowedOps must not be empty'),
       assert(numberKinds.length > 0, 'numberKinds must not be empty'),
       assert(maxOperands > 0, 'maxOperands must be > 0'),
       assert(maxAbsValue >= 0, 'maxAbsValue must be >= 0'),
       assert(
         maxDecimalAnswerDigits >= 0,
         'maxDecimalAnswerDigits must be >= 0',
       ),
       assert(promptDecimalMaxScale >= 0, 'promptDecimalMaxScale must be >= 0'),
       assert(maxDenominator >= 2, 'maxDenominator must be >= 2'),
       assert(decimalScaleMin >= 0, 'decimalScaleMin must be >= 0'),
       assert(
         decimalScaleMax >= decimalScaleMin,
         'decimalScaleMax must be >= decimalScaleMin',
       ),
       assert(
         parenthesesProbability >= 0 && parenthesesProbability <= 1,
         'parenthesesProbability must be between 0 and 1',
       );

  /// Staged defaults that match target usia (kids → teen → adult → expert).
  /// Kamu tetap bisa override manual field-field lain setelahnya.
  factory GeneratorConfig.difficulty(DifficultyLevel level) {
    final p = DifficultyDefaults.profile(level);

    final Set<MathOp> ops = switch (level) {
      DifficultyLevel.l1 => {MathOp.add},
      DifficultyLevel.l2 => {MathOp.add, MathOp.sub},
      DifficultyLevel.l3 => {MathOp.add, MathOp.sub, MathOp.mul},
      DifficultyLevel.l4 => {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
      DifficultyLevel.l5 => {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
      DifficultyLevel.l6 => {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
      DifficultyLevel.l7 => {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
    };

    final Set<NumberKind> kinds = switch (level) {
      DifficultyLevel.l1 => {NumberKind.integer},
      DifficultyLevel.l2 => {NumberKind.integer},
      DifficultyLevel.l3 => {NumberKind.integer},
      DifficultyLevel.l4 => {NumberKind.integer},
      DifficultyLevel.l5 => {
        NumberKind.integer,
        NumberKind.fraction,
        NumberKind.decimal,
      },
      DifficultyLevel.l6 => {
        NumberKind.integer,
        NumberKind.fraction,
        NumberKind.decimal,
      },
      DifficultyLevel.l7 => {
        NumberKind.integer,
        NumberKind.fraction,
        NumberKind.decimal,
      },
    };

    final maxDec = p.maxDecimalAnswerDigits;

    return GeneratorConfig(
      difficulty: level,
      allowedOps: ops,
      numberKinds: kinds,
      maxOperands: p.maxOperands,
      allowNegative: p.allowNegativeOperands,
      maxDenominator: p.maxDenominator,
      decimalScaleMin: p.decimalScaleMin,
      decimalScaleMax: p.decimalScaleMax,
      parenthesesProbability: p.parenthesesProbability,
      requireNonNegativeResult: p.requireNonNegativeResult,
      requireNonNegativeOperands: !p.allowNegativeOperands,
      requireNonNegativeIntermediate: p.requireNonNegativeIntermediate,
      requireIntegerAnswer: p.requireIntegerAnswer,
      maxDecimalAnswerDigits: maxDec,
      promptDecimalMaxScale: maxDec == 0 ? 0 : maxDec,
      promptNumberDisplay: NumberDisplay.smart,
    );
  }
}
