import 'package:csv_ya/csv_ya.dart';

void main() {
  const input = '''
a,b,c
a , b , c
"a","b","c"
"a""",b,c
"a" "b"c,b,c
''';
  final parsed = parseCsv(input);
  print('awesome: $parsed');
}
