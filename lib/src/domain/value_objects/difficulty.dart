enum DifficultyLevel { l1, l2, l3, l4, l5, l6, l7 }

/// DifficultyProfile = "kurikulum default" per level.
/// GeneratorConfig.difficulty(level) akan memakai profile ini sebagai default yang ramah untuk target usia.
///
/// Notes:
/// - Level awal fokus integer (+/-) tanpa negatif
/// - Multiplication/division masuk bertahap
/// - Fractions/decimals masuk bertahap dan dibuat "friendly"
/// - Negatives + parentheses lebih sering di level tinggi
class DifficultyProfile {
  final int minOperands;
  final int maxOperands;

  /// Integer operand range suggestion.
  final int minInt;
  final int maxInt;

  /// Suggested maximum denominator if using random denominators.
  final int maxDenominator;

  /// Suggested "friendly denominators" for fractions/decimals.
  /// If provided, generator will prefer these over random 2..maxDenominator.
  final List<int> friendlyDenominators;

  /// Decimal operand scale range suggestion.
  final int decimalScaleMin;
  final int decimalScaleMax;

  /// Probability of choosing fraction/decimal operands.
  final double fractionProbability;
  final double decimalProbability;

  /// Parentheses probability in expression building.
  final double parenthesesProbability;

  /// Suggested: allow negative operands?
  final bool allowNegativeOperands;

  /// Suggested: require final answer non-negative?
  final bool requireNonNegativeResult;

  /// Suggested: require intermediate results non-negative?
  final bool requireNonNegativeIntermediate;

  /// Suggested: require integer answers (no decimals/fractions).
  final bool requireIntegerAnswer;

  /// Suggested: maximum digits after decimal point when answer is decimal.
  final int maxDecimalAnswerDigits;

  const DifficultyProfile({
    required this.minOperands,
    required this.maxOperands,
    required this.minInt,
    required this.maxInt,
    required this.maxDenominator,
    required this.friendlyDenominators,
    required this.decimalScaleMin,
    required this.decimalScaleMax,
    required this.fractionProbability,
    required this.decimalProbability,
    required this.parenthesesProbability,
    required this.allowNegativeOperands,
    required this.requireNonNegativeResult,
    required this.requireNonNegativeIntermediate,
    required this.requireIntegerAnswer,
    required this.maxDecimalAnswerDigits,
  });
}

class DifficultyDefaults {
  static DifficultyProfile profile(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.l1:
        return const DifficultyProfile(
          minOperands: 2,
          maxOperands: 2,
          minInt: 0,
          maxInt: 10,
          maxDenominator: 10,
          friendlyDenominators: [2, 4, 5, 10],
          decimalScaleMin: 1,
          decimalScaleMax: 1,
          fractionProbability: 0.0,
          decimalProbability: 0.0,
          parenthesesProbability: 0.0,
          allowNegativeOperands: false,
          requireNonNegativeResult: true,
          requireNonNegativeIntermediate: true,
          requireIntegerAnswer: true,
          maxDecimalAnswerDigits: 0,
        );

      case DifficultyLevel.l2:
        return const DifficultyProfile(
          minOperands: 2,
          maxOperands: 2,
          minInt: 0,
          maxInt: 20,
          maxDenominator: 10,
          friendlyDenominators: [2, 4, 5, 10],
          decimalScaleMin: 1,
          decimalScaleMax: 1,
          fractionProbability: 0.0,
          decimalProbability: 0.0,
          parenthesesProbability: 0.0,
          allowNegativeOperands: false,
          requireNonNegativeResult: true,
          requireNonNegativeIntermediate: true,
          requireIntegerAnswer: true,
          maxDecimalAnswerDigits: 0,
        );

      case DifficultyLevel.l3:
        return const DifficultyProfile(
          minOperands: 2,
          maxOperands: 3,
          minInt: 0,
          maxInt: 100,
          maxDenominator: 12,
          friendlyDenominators: [2, 3, 4, 5, 6, 10, 12],
          decimalScaleMin: 1,
          decimalScaleMax: 1,
          fractionProbability: 0.0,
          decimalProbability: 0.0,
          parenthesesProbability: 0.05,
          allowNegativeOperands: false,
          requireNonNegativeResult: true,
          requireNonNegativeIntermediate: true,
          requireIntegerAnswer: true,
          maxDecimalAnswerDigits: 0,
        );

      case DifficultyLevel.l4:
        return const DifficultyProfile(
          minOperands: 2,
          maxOperands: 3,
          minInt: 0,
          maxInt: 200,
          maxDenominator: 20,
          friendlyDenominators: [2, 3, 4, 5, 8, 10, 20],
          decimalScaleMin: 1,
          decimalScaleMax: 1,
          fractionProbability: 0.0,
          decimalProbability: 0.0,
          parenthesesProbability: 0.15,
          allowNegativeOperands: false,
          requireNonNegativeResult: true,
          requireNonNegativeIntermediate: true,
          requireIntegerAnswer: true,
          maxDecimalAnswerDigits: 0,
        );

      case DifficultyLevel.l5:
        return const DifficultyProfile(
          minOperands: 2,
          maxOperands: 4,
          minInt: 0,
          maxInt: 300,
          maxDenominator: 20,
          friendlyDenominators: [2, 4, 5, 8, 10, 20],
          decimalScaleMin: 1,
          decimalScaleMax: 1,
          fractionProbability: 0.20,
          decimalProbability: 0.25,
          parenthesesProbability: 0.25,
          allowNegativeOperands: false,
          requireNonNegativeResult: true,
          requireNonNegativeIntermediate: true,
          requireIntegerAnswer: false,
          maxDecimalAnswerDigits: 1,
        );

      case DifficultyLevel.l6:
        return const DifficultyProfile(
          minOperands: 3,
          maxOperands: 5,
          minInt: -200,
          maxInt: 800,
          maxDenominator: 50,
          friendlyDenominators: [2, 3, 4, 5, 6, 8, 10, 12, 20, 25, 50],
          decimalScaleMin: 1,
          decimalScaleMax: 2,
          fractionProbability: 0.25,
          decimalProbability: 0.30,
          parenthesesProbability: 0.40,
          allowNegativeOperands: true,
          requireNonNegativeResult: false,
          requireNonNegativeIntermediate: false,
          requireIntegerAnswer: false,
          maxDecimalAnswerDigits: 2,
        );

      case DifficultyLevel.l7:
        return const DifficultyProfile(
          minOperands: 3,
          maxOperands: 6,
          minInt: -1000,
          maxInt: 2000,
          maxDenominator: 100,
          friendlyDenominators: [2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 20, 25, 50, 100],
          decimalScaleMin: 1,
          decimalScaleMax: 2,
          fractionProbability: 0.35,
          decimalProbability: 0.35,
          parenthesesProbability: 0.60,
          allowNegativeOperands: true,
          requireNonNegativeResult: false,
          requireNonNegativeIntermediate: false,
          requireIntegerAnswer: false,
          maxDecimalAnswerDigits: 2,
        );
    }
  }
}
