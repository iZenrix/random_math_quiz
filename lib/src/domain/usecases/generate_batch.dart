import '../config/generator_config.dart';
import '../entities/math_question.dart';
import '../repositories/math_question_repository.dart';

class GenerateBatch {
  final MathQuestionRepository _repo;
  const GenerateBatch(this._repo);

  List<MathQuestion> call(GeneratorConfig config, int count) =>
      _repo.generateBatch(config, count);
}
