import '../data/repositories/random_math_question_repository.dart';
import '../domain/config/generator_config.dart';
import '../domain/entities/answer_check_result.dart';
import '../domain/entities/math_question.dart';
import '../domain/repositories/math_question_repository.dart';
import '../domain/usecases/generate_batch.dart';
import '../domain/usecases/generate_question.dart';
import '../domain/usecases/validate_answer.dart';

class MathQuiz {
  final GeneratorConfig config;
  final MathQuestionRepository _repo;
  late final GenerateQuestion _generateQuestion;
  late final GenerateBatch _generateBatch;
  late final ValidateAnswer _validateAnswer;

  MathQuiz({
    required this.config,
    int? seed,
    MathQuestionRepository? repository,
  }) : _repo = repository ?? RandomMathQuestionRepository(seed: seed) {
    _generateQuestion = GenerateQuestion(_repo);
    _generateBatch = GenerateBatch(_repo);
    _validateAnswer = const ValidateAnswer();
  }

  MathQuestion next() => _generateQuestion(config);

  List<MathQuestion> batch(int count) => _generateBatch(config, count);

  AnswerCheckResult checkAnswer(MathQuestion question, String userInput) {
    return _validateAnswer(question: question, userInput: userInput, config: config);
  }
}
