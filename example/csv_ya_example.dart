import 'dart:convert';
import 'dart:io';

import 'package:csv_ya/csv_ya.dart';

Future<void> main() async {
  const input = '''
a,b,c
a , b , c
"a","b","c"
"a""",b,c
"a" "b"c,b,c
''';
  final parsed = parseCsv(input);
  print('awesome: $parsed');

  // You can use streaming conversion for very large file.
  const path = 'your/file/path/of/data.csv';
  await for (final s in File(path)
      .openRead()
      .transform(const Utf8Decoder())
      .transform(CsvDecoder())) {
    for (final r in s) {
      print('|${r.join('|')}|');
    }
  }
}
