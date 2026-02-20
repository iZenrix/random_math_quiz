enum MathOp { add, sub, mul, div }

extension MathOpSymbol on MathOp {
  String symbol({bool unicode = true}) {
    switch (this) {
      case MathOp.add:
        return '+';
      case MathOp.sub:
        return '-';
      case MathOp.mul:
        return unicode ? '×' : '*';
      case MathOp.div:
        return unicode ? '÷' : '/';
    }
  }

  int precedence() {
    switch (this) {
      case MathOp.mul:
      case MathOp.div:
        return 2;
      case MathOp.add:
      case MathOp.sub:
        return 1;
    }
  }
}
