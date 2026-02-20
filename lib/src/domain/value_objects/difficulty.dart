enum DifficultyLevel { l1, l2, l3, l4, l5 }

class DifficultyProfile {
  final int minOperands;
  final int maxOperands;
  final int minInt;
  final int maxInt;
  final int maxDenominator;
  final int decimalScaleMin;
  final int decimalScaleMax;
  final double fractionProbability;
  final double decimalProbability;
  final double parenthesesProbability;

  const DifficultyProfile({
    required this.minOperands,
    required this.maxOperands,
    required this.minInt,
    required this.maxInt,
    required this.maxDenominator,
    required this.decimalScaleMin,
    required this.decimalScaleMax,
    required this.fractionProbability,
    required this.decimalProbability,
    required this.parenthesesProbability,
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
          maxInt: 20,
          maxDenominator: 10,
          decimalScaleMin: 1,
          decimalScaleMax: 1,
          fractionProbability: 0.15,
          decimalProbability: 0.15,
          parenthesesProbability: 0.0,
        );
      case DifficultyLevel.l2:
        return const DifficultyProfile(
          minOperands: 2,
          maxOperands: 3,
          minInt: 0,
          maxInt: 100,
          maxDenominator: 12,
          decimalScaleMin: 1,
          decimalScaleMax: 2,
          fractionProbability: 0.25,
          decimalProbability: 0.20,
          parenthesesProbability: 0.10,
        );
      case DifficultyLevel.l3:
        return const DifficultyProfile(
          minOperands: 2,
          maxOperands: 3,
          minInt: 0,
          maxInt: 200,
          maxDenominator: 20,
          decimalScaleMin: 1,
          decimalScaleMax: 2,
          fractionProbability: 0.30,
          decimalProbability: 0.25,
          parenthesesProbability: 0.20,
        );
      case DifficultyLevel.l4:
        return const DifficultyProfile(
          minOperands: 3,
          maxOperands: 4,
          minInt: -200,
          maxInt: 500,
          maxDenominator: 50,
          decimalScaleMin: 1,
          decimalScaleMax: 3,
          fractionProbability: 0.35,
          decimalProbability: 0.30,
          parenthesesProbability: 0.35,
        );
      case DifficultyLevel.l5:
        return const DifficultyProfile(
          minOperands: 3,
          maxOperands: 5,
          minInt: -1000,
          maxInt: 2000,
          maxDenominator: 100,
          decimalScaleMin: 1,
          decimalScaleMax: 4,
          fractionProbability: 0.40,
          decimalProbability: 0.35,
          parenthesesProbability: 0.55,
        );
    }
  }
}
