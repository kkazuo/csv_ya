import 'dart:async';

import 'package:csv_ya/csv_ya.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    late CsvDecoder decoder;

    setUp(() {
      // Additional setup goes here.
      decoder = CsvDecoder();
    });

    test('Map Converter Test', () async {
      expect(
        await Stream<String>.value('a,b,c\n')
            .transform(CsvDecoder())
            .transform(CsvIntoMap())
            .expand((element) => element)
            .toList(),
        <Map<String, String>>[],
      );
      expect(
          await Stream<String>.value('a,b,c\n1,2,3')
              .transform(CsvDecoder())
              .transform(CsvIntoMap())
              .expand((element) => element)
              .toList(),
          [
            {'a': '1', 'b': '2', 'c': '3'}
          ]);
      expect(
          await Stream<String>.value('a,b,c\n1,2')
              .transform(CsvDecoder())
              .transform(CsvIntoMap())
              .expand((element) => element)
              .toList(),
          [
            {'a': '1', 'b': '2'}
          ]);
      expect(
          await Stream<String>.value('a,b\n1,2,3')
              .transform(CsvDecoder())
              .transform(CsvIntoMap())
              .expand((element) => element)
              .toList(),
          [
            {'a': '1', 'b': '2'}
          ]);
      expect(
          await Stream<String>.value('a,b,c\n1,2,3\n')
              .transform(CsvDecoder())
              .transform(CsvIntoMap())
              .expand((element) => element)
              .toList(),
          [
            {'a': '1', 'b': '2', 'c': '3'}
          ]);
      expect(
          await Stream<String>.value('a,b,c\n1,2,3\n4,5,6')
              .transform(CsvDecoder())
              .transform(CsvIntoMap())
              .expand((element) => element)
              .toList(),
          [
            {'a': '1', 'b': '2', 'c': '3'},
            {'a': '4', 'b': '5', 'c': '6'},
          ]);
      expect(
          await Stream<String>.fromIterable(['a,b,c\n1,2,3\n4,5,6'])
              .transform(CsvDecoder())
              .transform(CsvIntoMap())
              .expand((element) => element)
              .toList(),
          [
            {'a': '1', 'b': '2', 'c': '3'},
            {'a': '4', 'b': '5', 'c': '6'},
          ]);
      expect(
          await Stream<String>.fromIterable(
            ['a', ',b,', 'c\n1,2', ',3\n4,5,', '6'],
          )
              .transform(CsvDecoder())
              .transform(CsvIntoMap())
              .expand((element) => element)
              .toList(),
          [
            {'a': '1', 'b': '2', 'c': '3'},
            {'a': '4', 'b': '5', 'c': '6'},
          ]);
      expect(parseCsvAsMap('a,b,c\n1,2,3'), [
        {'a': '1', 'b': '2', 'c': '3'},
      ]);
    });

    test('Decoder Test', () {
      expect(decoder.convert('a,b,c'), [
        ['a', 'b', 'c']
      ]);
      expect(decoder.convert('a,b,c\r\n'), [
        ['a', 'b', 'c']
      ]);
    });

    test('Chunked Decoder Test', () async {
      expect(
        await Stream<String>.value('a,b,c')
            .transform(decoder)
            .expand((element) => element)
            .toList(),
        [
          ['a', 'b', 'c']
        ],
      );
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

    test('Async Test', () async {
      const input = 'a,b,c\n1,2,3\n';

      expect(parseCsv(input), [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ]);
      expect(await parseCsvAsync(Stream.value(input)), [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ]);
      expect(parseCsvAsMap(input), [
        {'a': '1', 'b': '2', 'c': '3'}
      ]);
      expect(await parseCsvAsMapAsync(Stream.value(input)), [
        {'a': '1', 'b': '2', 'c': '3'}
      ]);
    });

    test('Field Test', () {
      expect(parseCsv('a,b'), [
        ['a', 'b'],
      ]);
      expect(parseCsv('a,'), [
        ['a', ''],
      ]);
      expect(parseCsv(',a'), [
        ['', 'a'],
      ]);
      expect(parseCsv('a'), [
        ['a'],
      ]);
      expect(parseCsv(','), [
        ['', ''],
      ]);
      expect(parseCsv(',\r\n'), [
        ['', ''],
      ]);
      expect(parseCsv(',,'), [
        ['', '', ''],
      ]);
      expect(parseCsv(',,\r\n'), [
        ['', '', ''],
      ]);
      expect(parseCsv(''), <List<String>>[]);
      expect(parseCsv('\r\n'), <List<String>>[
        ['']
      ]);
    });

    test('Multi Line Test', () {
      expect(parseCsv('a,b,c\r\n'), [
        ['a', 'b', 'c'],
      ]);
      expect(parseCsv('a,b,c\r\nd,e,f'), [
        ['a', 'b', 'c'],
        ['d', 'e', 'f'],
      ]);
      expect(parseCsv('a,b,c\r\nd,e,f\r\n'), [
        ['a', 'b', 'c'],
        ['d', 'e', 'f'],
      ]);
      expect(parseCsv('a,b,c\nd,e,f\n'), [
        ['a', 'b', 'c'],
        ['d', 'e', 'f'],
      ]);
      expect(parseCsv('a,b,c\r\nd,e,f\n'), [
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
      expect(parseCsv('"a,b" ,x'), [
        ['a,b', 'x']
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
