import 'package:csv_ya/csv_ya.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(parseCsv('a,b,c'), [
        ['a', 'b', 'c']
      ]);
      expect(parseCsv('"a",b'), [
        ['a', 'b']
      ]);
      expect(parseCsv('"a""b",b'), [
        ['a"b', 'b']
      ]);
      expect(parseCsv('"a" "b",b'), [
        ['a b', 'b']
      ]);
      expect(parseCsv('a "b",b'), [
        ['a b', 'b']
      ]);
      expect(parseCsv('a "b" c,b'), [
        ['a b c', 'b']
      ]);
      expect(parseCsv('"a" "b"c,b'), [
        ['a bc', 'b']
      ]);
      expect(parseCsv('"a" "b" ,b'), [
        ['a b', 'b']
      ]);
    });

    test('Multi Line Test', () {
      expect(parseCsv('a,b,c\r\nd,e,f'), [
        ['a', 'b', 'c'],
        ['d', 'e', 'f'],
      ]);
    });

    test('Escape Test', () {
      expect(parseCsv('a b,x'), [
        ['a b', 'x']
      ]);
      expect(parseCsv(' a b,x'), [
        ['a b', 'x']
      ]);
      expect(parseCsv('a b ,x'), [
        ['a b', 'x']
      ]);
      expect(parseCsv('"a b",x'), [
        ['a b', 'x']
      ]);
      expect(parseCsv(' "a b",x'), [
        ['a b', 'x']
      ]);
      expect(parseCsv('"a b" ,x'), [
        ['a b', 'x']
      ]);
      expect(parseCsv('"a b " ,x'), [
        ['a b ', 'x']
      ]);
      expect(parseCsv(' a "b " ,x'), [
        ['a b ', 'x']
      ]);
      expect(parseCsv(' "a b" ,x'), [
        ['a b', 'x']
      ]);
      expect(parseCsv('"a b\n",x'), [
        ['a b\n', 'x']
      ]);
      expect(parseCsv('"a b\n" ,x'), [
        ['a b\n', 'x']
      ]);
      expect(parseCsv('"a\nb",x'), [
        ['a\nb', 'x']
      ]);
      expect(parseCsv('"a\rb",x'), [
        ['a\rb', 'x']
      ]);
      expect(parseCsv('"a\r\nb",x'), [
        ['a\r\nb', 'x']
      ]);
    });
  });
}
