import 'dart:io';

void main() async {
  final lines = await File('coverage/lcov.info').readAsLines();
  int totalLines = 0;
  int coveredLines = 0;

  for (final line in lines) {
    if (line.startsWith('DA:')) {
      totalLines++;
      if (int.parse(line.split(',')[1]) > 0) {
        coveredLines++;
      }
    }
  }

  final percent = (coveredLines / totalLines) * 100;
  print('Total lines: $totalLines');
  print('Covered lines: $coveredLines');
  print('Coverage: ${percent.toStringAsFixed(2)}%');
}
