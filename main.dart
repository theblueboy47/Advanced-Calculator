import 'dart:io';
import 'dart:math';

void main() {
  while (true) {
    stdout.write("Enter you formula:");
    String? formula = stdin.readLineSync();
    if (formula == null) throw Exception("Formula is Null");
    if (formula.toLowerCase() == "exit") exit(0);
    if (check(formula)) {
      print(calculate(formula));
    } else {
      stderr.writeln("Your formula is not valid");
    }
  }
}

String calculate(String formula) {
  (int?, int?) subFormula;
  String? temp = null;
  formula = formula.replaceAll(" ", "");
  while ((subFormula = _getParans(formula)) != (null, null)) {
    formula = formula.replaceAll(
      formula.substring(subFormula.$1!, subFormula.$2! + 1),
      "${calculate(formula.substring(subFormula.$1! + 1, subFormula.$2))}",
    );
  }
  while ((temp = _getPow(formula)) != null) {
    formula = temp!;
  }
  while ((temp = _getMultiDiv(formula)) != null) {
    formula = temp!;
  }
  while ((temp = _getAddSub(formula)) != null) {
    formula = temp!;
  }

  return formula;
}

(int?, int?) _getParans(String formula) {
  int fIndex = formula.indexOf("(");
  int lIndex = -1;
  if (fIndex != -1) {
    int count = 0;
    for (int i = fIndex; i < formula.length; i++) {
      String c = formula[i];
      if (c == "(")
        count++;
      else if (c == ")")
        count--;
      if (count == 0) {
        lIndex = i;
        return (fIndex, lIndex);
      }
    }
  }

  return (null, null);
}

String? _getPow(String formula) {
  double? result = null;

  int firstOpIndex = formula.indexOf("^");
  if (firstOpIndex != -1) {
    double a, b;
    int firstNumIndex, lastNumIndex;
    
    (a, b, firstNumIndex, lastNumIndex) = _getOperands(firstOpIndex, formula);

    result = pow(a, b) as double?;

    formula = formula.replaceAll(
      formula.substring(firstNumIndex, lastNumIndex),
      "$result",
    );

    return formula;
  }

  return null;
}

String? _getMultiDiv(String formula) {
  double? result = null;

  formula = formula.replaceAll("x", "*");
  int indexOfMult = formula.indexOf("*");
  int indexOfDiv = formula.indexOf("/");
  int minIndex = min(indexOfMult, indexOfDiv);
  int maxIndex = max(indexOfMult, indexOfDiv);
  int firstOpIndex = (minIndex != -1) ? minIndex : maxIndex;
  if (firstOpIndex != -1) {
    double a, b;
    int firstNumIndex, lastNumIndex;

    (a, b, firstNumIndex, lastNumIndex) = _getOperands(firstOpIndex, formula);

    result = (firstOpIndex == indexOfMult) ? a * b : a / b;

    if (result == double.infinity) {
      stderr.writeln("You cannot divide by zero");
      exit(1);
    }

    formula = formula.replaceAll(
      formula.substring(firstNumIndex, lastNumIndex),
      "$result",
    );

    return formula;
  }

  return null;
}

String? _getAddSub(String formula) {
  double? result = null;

  formula = _simplifyOps(formula);
  int indexOfAdd = formula.indexOf("+");
  int indexOfSub = formula.indexOf("-");
  int minIndex = min(indexOfAdd, indexOfSub);
  int maxIndex = max(indexOfAdd, indexOfSub);
  int firstOpIndex = (minIndex != -1) ? minIndex : maxIndex;
  if (firstOpIndex != -1) {
    double a, b;
    int firstNumIndex, lastNumIndex;
    (a, b, firstNumIndex, lastNumIndex) = _getOperands(firstOpIndex, formula);

    result = (firstOpIndex == indexOfAdd) ? a + b : a - b;

    formula = formula.replaceAll(
      formula.substring(firstNumIndex, lastNumIndex),
      "$result",
    );

    return formula;
  }
  return null;
}

String _simplifyOps(String formula) {
  String? prev = null;
  String? now = null;
  String temp = "";
  for (int i = 0; i < formula.length; i++) {
    now = "+-".contains(formula[i]) ? formula[i] : null;
    if (prev != null && now != null) {
      now = (prev == now) ? "+" : "-";
      formula =
          formula.substring(0, i - 1) + "#" + now + formula.substring(i + 1);
    }
    prev = now;
  }
  for (int i = 0; i < formula.length; i++) {
    String c = formula[i];
    temp += (c != "#") ? c : "";
  }
  if (temp.startsWith("-"))
    temp = "0" + temp;
  else if (temp.startsWith("+"))
    temp = temp.substring(1);
  formula = temp;
  return formula;
}

(double, double, int, int) _getOperands(int firstOpIndex, String formula) {
  int firstNumIndex = firstOpIndex;
  int lastNumIndex = firstOpIndex + 1;

  //finding the first operand
  while (firstNumIndex - 1 >= 0 &&
      (int.tryParse(formula[firstNumIndex - 1]) != null ||
          formula[firstNumIndex - 1] == ".")) {
    firstNumIndex--;
  }
  double a = double.parse(formula.substring(firstNumIndex, firstOpIndex));

  //finding the second operand
  while (lastNumIndex + 1 <= formula.length &&
      (int.tryParse(formula[lastNumIndex]) != null ||
          formula[lastNumIndex] == ".")) {
    lastNumIndex++;
  }
  double b = double.parse(formula.substring(firstOpIndex + 1, lastNumIndex));

  return (a, b, firstNumIndex, lastNumIndex);
}

bool check(String s) {
  int parans = 0;
  String? lastChar = null;
  for (var codePoint in s.codeUnits) {
    var c = String.fromCharCode(codePoint);
    if (_isNum(c)) {
      if (lastChar == ")") return false;
    } else if (_isOp(c)) {
      if (!(_isNum(lastChar) || lastChar == ")" || "-+".contains(c)))
        return false;
    } else if (c == "(") {
      if (_isNum(lastChar) || lastChar == ")") return false;
      parans++;
    } else if (c == ")") {
      if (_isOp(lastChar) || lastChar == "(") return false;
      parans--;
    } else
      return false;
    if (parans < 0) return false;
    lastChar = c;
  }
  if (parans != 0) return false;
  return true;
}

bool _isNum(String? s) {
  return (s != null && int.tryParse(s) != null);
}

bool _isOp(String? s) {
  return (s != null && "+-*x/^".contains(s));
}
