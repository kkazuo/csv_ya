import 'package:csv_ya/src/csv/definition.dart';
import 'package:csv_ya/src/csv/types.dart';

export 'csv/definition.dart';
export 'csv/types.dart';

final _csvParser = CsvDefinition().build<Csv>();

/// Converts the given string [input] to its corresponding csv.
Csv parseCsv(String input) => _csvParser.parse(input).value;
