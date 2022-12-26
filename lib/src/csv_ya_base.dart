import 'package:csv_ya/csv_ya.dart';

export 'csv/converter.dart';
export 'csv/into_map.dart';
export 'csv/types.dart';

/// Converts the given string [input] to its corresponding csv.
Csv parseCsv(String input) => CsvDecoder().convert(input);

/// Converts the given string [input] to its corresponding csv.
Future<Csv> parseCsvAsync(Stream<String> input) async =>
    input.transform(CsvDecoder()).expand((element) => element).toList();

/// Converts the given string [input] to its corresponding csv.
CsvAsMap parseCsvAsMap(
  String input, {
  List<String>? headers,
  Iterable<String> Function(List<String>)? headerConverter,
}) =>
    CsvIntoMap(headers: headers, headerConverter: headerConverter)
        .convert(CsvDecoder().convert(input));

/// Converts the given string [input] to its corresponding csv.
Future<CsvAsMap> parseCsvAsMapAsync(
  Stream<String> input, {
  List<String>? headers,
  Iterable<String> Function(List<String>)? headerConverter,
}) async =>
    input
        .transform(CsvDecoder())
        .transform(
          CsvIntoMap(headers: headers, headerConverter: headerConverter),
        )
        .expand((element) => element)
        .toList();
