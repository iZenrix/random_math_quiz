import '../config/generator_config.dart';
import '../entities/math_question.dart';
import '../repositories/math_question_repository.dart';

class GenerateQuestion {
  final MathQuestionRepository _repo;
  const GenerateQuestion(this._repo);

  MathQuestion call(GeneratorConfig config) => _repo.generate(config);
}
