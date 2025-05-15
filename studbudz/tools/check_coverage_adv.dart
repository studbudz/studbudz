import 'dart:io';

void main() async {
  final file = File('coverage/lcov.info');

  if (!file.existsSync()) {
    print(
        ' coverage/lcov.info not found. Run `flutter test --coverage` first.');
    return;
  }

  final lines = await file.readAsLines();

  final Map<String, List<String>> fileBlocks = {};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      fileBlocks[currentFile] = [];
    } else if (currentFile != null) {
      fileBlocks[currentFile]!.add(line);
    }
  }

  int totalAll = 0;
  int coveredAll = 0;

  print('\n File-by-file Coverage Breakdown:\n');

  for (final entry in fileBlocks.entries) {
    final fileName = entry.key.replaceAll('\\', '/');
    final daLines =
        entry.value.where((line) => line.startsWith('DA:')).toList();

    int total = daLines.length;
    int covered = daLines.where((line) {
      final hit = int.tryParse(line.split(',')[1]) ?? 0;
      return hit > 0;
    }).length;

    totalAll += total;
    coveredAll += covered;

    final percent = total > 0 ? (covered / total * 100) : 0;
    print(
        '${fileName.split('/').last.padRight(30)} ${covered.toString().padLeft(3)} / ${total.toString().padRight(3)} '
        '(${percent.toStringAsFixed(2)}%)');
  }

  final totalPercent = totalAll > 0 ? (coveredAll / totalAll) * 100 : 0;
  print('\n Overall Coverage: $coveredAll / $totalAll lines '
      '(${totalPercent.toStringAsFixed(2)}%)\n');
}
