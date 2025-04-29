import 'dart:io';

void main() async {
  // Path to your text file and output SQL file
  String inputFilePath = 'subjects.txt';
  String outputFilePath = 'modified_sql_file.sql';

  // Read the subjects file (subjects.txt)
  List<String> subjects = await File(inputFilePath).readAsLines();

  // Prepare the SQL insert for subjects
  List<String> subjectSQL =
      subjects
          .map(
            (subject) =>
                "INSERT INTO subject (subject_name) VALUES ('$subject');",
          )
          .toList();

  // Path to the SQL file that you are modifying
  String sqlInputPath = 'studbudz.sql';

  // Read the original SQL file
  List<String> sqlLines = await File(sqlInputPath).readAsLines();

  // Set the line index for insertion (line 258 in your case)
  int insertLineIndex = 258;

  // Create a new list for the modified SQL
  List<String> modifiedSQL = [];

  // Add the first part of the SQL (before insertion)
  modifiedSQL.addAll(sqlLines.sublist(0, insertLineIndex));

  // Insert subjects SQL
  modifiedSQL.addAll(subjectSQL);

  // Add the second part of the original SQL (after insertion)
  modifiedSQL.addAll(sqlLines.sublist(insertLineIndex));

  // Write the modified SQL to a new file
  await File(outputFilePath).writeAsString(modifiedSQL.join('\n'));

  print('SQL file has been modified and saved to $outputFilePath');
}
