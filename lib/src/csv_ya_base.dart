import 'package:csv_ya/csv_ya.dart';

export 'csv/converter.dart';
export 'csv/types.dart';

/// Converts the given string [input] to its corresponding csv.
Csv parseCsv(String input) => CsvDecoder().convert(input);
