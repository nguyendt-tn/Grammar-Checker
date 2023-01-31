class Grammar {
  int index;
  int offset;
  String? type;
  String? shortMessage;
  String? errorWord;
  String? message;
  List<String>? replace;
  Grammar(
      {required this.index,
      required this.offset,
      required this.type,
      required this.shortMessage,
      required this.errorWord,
      required this.message,
      required this.replace});
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
