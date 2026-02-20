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

  /// If false, negatives won't appear in operand generation; result may still be negative.
  final bool allowNegative;

  /// Limit absolute value of intermediate and final results (helps keep questions readable).
  final int maxAbsValue;

  /// If true, generator will reject questions whose final answer is negative.
  final bool requireNonNegativeResult;

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

  /// Use unicode operators × ÷ when true.
  final bool unicodeOperators;

  const GeneratorConfig({
    required this.difficulty,
    this.allowedOps = const {MathOp.add, MathOp.sub, MathOp.mul, MathOp.div},
    this.numberKinds = const {NumberKind.integer, NumberKind.fraction, NumberKind.decimal},
    this.maxOperands = 5,
    this.allowNegative = false,
    this.maxAbsValue = 10000,
    this.requireNonNegativeResult = true,
    this.promptNumberDisplay = NumberDisplay.smart,
    this.promptDecimalMaxScale = 6,
    this.maxDenominator = 50,
    this.decimalScaleMin = 1,
    this.decimalScaleMax = 3,
    this.parenthesesProbability = 0.25,
    this.unicodeOperators = true,
  });

  factory GeneratorConfig.difficulty(DifficultyLevel level) =>
      GeneratorConfig(difficulty: level);
}