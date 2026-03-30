import '../value_objects/math_op.dart';
import '../value_objects/rational.dart';

sealed class Expr {
  const Expr();
  Rational eval();
  String format(ExprFormatter formatter);

  int get precedence;
}

/// A number literal expression.
class NumExpr extends Expr {
  final Rational value;
  const NumExpr(this.value);

  @override
  Rational eval() => value;

  @override
  String format(ExprFormatter formatter) => formatter.formatNumber(value);

  @override
  int get precedence => 3;
}

/// A binary expression.
class BinExpr extends Expr {
  final Expr left;
  final MathOp op;
  final Expr right;

  const BinExpr(this.left, this.op, this.right);

  @override
  Rational eval() {
    final a = left.eval();
    final b = right.eval();
    return switch (op) {
      MathOp.add => a + b,
      MathOp.sub => a - b,
      MathOp.mul => a * b,
      MathOp.div => a / b,
    };
  }

  @override
  String format(ExprFormatter formatter) {
    final leftStr = _maybeParen(left, forRight: false, formatter: formatter);
    final rightStr = _maybeParen(right, forRight: true, formatter: formatter);
    return '$leftStr ${op.symbol(unicode: formatter.unicodeOps)} $rightStr';
  }

  String _maybeParen(Expr child,
      {required bool forRight, required ExprFormatter formatter}) {
    final childStr = child.format(formatter);

    // Parentheses rules:
    // - if child precedence is lower -> need parentheses
    // - for right child in subtraction/division, equal precedence also needs parentheses
    if (child.precedence < precedence) return '($childStr)';

    if (forRight) {
      final needs = (op == MathOp.sub || op == MathOp.div) &&
          child.precedence == precedence;
      if (needs) return '($childStr)';
    }
    return childStr;
  }

  @override
  int get precedence => op.precedence();
}

class ExprFormatter {
  final bool unicodeOps;
  final NumberDisplay numberDisplay;
  final int decimalMaxScale;

  const ExprFormatter({
    this.unicodeOps = true,
    this.numberDisplay = NumberDisplay.smart,
    this.decimalMaxScale = 6,
  });

  String formatNumber(Rational r) {
    return switch (numberDisplay) {
      NumberDisplay.smart => r.asSmartString(maxScale: decimalMaxScale),
      NumberDisplay.fraction => r.asFractionString(),
      NumberDisplay.decimal => r.asDecimalString(maxScale: decimalMaxScale),
      NumberDisplay.mixed => r.asMixedString(),
    };
  }
}

enum NumberDisplay { smart, fraction, decimal, mixed }