import 'dart:convert';

import 'package:csv_ya/src/csv/definition.dart';
import 'package:csv_ya/src/csv/types.dart';

final _csvParser = CsvDefinition().build<Csv>();

/// Decoder of CSV
class CsvDecoder extends Converter<String, Csv> {
  @override
  Csv convert(String input) {
    return _csvParser.parse(input).value;
  }
}
