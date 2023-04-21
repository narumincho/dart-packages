String? textFromString(
  String input, {
  required int maxLength,
}) {
  final normalized = _trimAndNormalizeSpace(input);
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.length > maxLength) {
    return null;
  }
  return normalized;
}

String _trimAndNormalizeSpace(String input) {
  final normalized = input.trim();
  var result = '';
  var beforeSpace = false;
  for (final codePoint in normalized.codeUnits) {
    final char = String.fromCharCode(codePoint);
    // 制御文字
    if ((codePoint > 0x1f && codePoint < 0x7f) || codePoint > 0xa0) {
      if (char == ' ' || char == '\u3000' || char == '\n') {
        if (!beforeSpace) {
          result += ' ';
          beforeSpace = true;
        }
      } else {
        result += char;
        beforeSpace = false;
      }
    }
  }
  return result;
}
