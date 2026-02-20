import '../entities/math_question.dart';
import '../config/generator_config.dart';

abstract interface class MathQuestionRepository {
  MathQuestion generate(GeneratorConfig config);
  List<MathQuestion> generateBatch(GeneratorConfig config, int count);
}
