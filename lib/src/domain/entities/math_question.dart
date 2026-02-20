import '../value_objects/difficulty.dart';
import '../value_objects/rational.dart';
import 'expression.dart';

class MathQuestion {
  final String id;
  final String prompt;
  final Rational answer;
  final DifficultyLevel difficulty;
  final Expr expression;
  final Map<String, Object?> metadata;
  final List<String> explanationSteps;

  const MathQuestion({
    required this.id,
    required this.prompt,
    required this.answer,
    required this.difficulty,
    required this.expression,
    this.metadata = const {},
    this.explanationSteps = const [],
  });
}
