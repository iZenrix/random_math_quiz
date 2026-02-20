import 'dart:math';

abstract interface class RandomProvider {
  Random get rng;
}

class SeededRandomProvider implements RandomProvider {
  @override
  final Random rng;
  SeededRandomProvider({int? seed}) : rng = Random(seed);
}
