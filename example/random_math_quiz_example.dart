import 'package:random_math_quiz/random_math_quiz.dart';

void main() {
  final quiz = MathQuiz(
    config: GeneratorConfig.difficulty(DifficultyLevel.l5),
    seed: 42,
  );

  final question = quiz.next();
  print(question.prompt);
  print('Fraction answer: ${question.answer.asFractionString()}');
  print('Smart answer: ${question.answer.asSmartString(maxScale: 2)}');

  final result = quiz.checkAnswer(question, question.answer.asFractionString());
  print('Correct: ${result.isCorrect}');

  final batch = quiz.batch(3);
  for (final item in batch) {
    print('${item.prompt} ${item.answer.asSmartString(maxScale: 2)}');
  }
}
