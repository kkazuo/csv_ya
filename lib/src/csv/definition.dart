/*
Copyright 2022 Koga Kazuo (koga.kazuo@gmail.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */
import 'package:csv_ya/src/csv/types.dart';
import 'package:petitparser/definition.dart';
import 'package:petitparser/parser.dart';

class _Text {
  _Text({required this.escaped, required this.text});

  final bool escaped;
  final String text;
}

/// Csv grammar definition.
class CsvDefinition extends GrammarDefinition<Csv> {
  @override
  Parser<Csv> start() => ref0(_value).end();

  Parser<Csv> _value() => [
        ref0(_file),
      ].toChoiceParser(failureJoiner: selectFarthestJoined);

  Parser<Csv> _file() => _record()
          .starSeparated([string('\r\n'), char('\n')].toChoiceParser())
          .map((value) {
        final xs = value.elements;
        if (xs.isEmpty) return [];
        final last = xs.last;
        if (last.length == 1 && !last[0].escaped && last[0].text.isEmpty) {
          xs.removeLast();
        }
        return xs.map((ts) => ts.map((e) => e.text).toList()).toList();
      });

  Parser<List<_Text>> _record() =>
      _field().starSeparated(char(',')).map((value) => value.elements);

  Parser<_Text> _field() => [
        ref0(_escapedStar),
        ref0(_nonEscapedStar).map(
          (value) => _Text(escaped: value.escaped, text: value.text.trimLeft()),
        ),
      ].toChoiceParser();

  Parser<String> _textdata() => pattern('^",\r\n');

  Parser<String> _nonEscaped() =>
      _textdata().star().map((value) => value.join());

  Parser<_Text> _escaped() => seq3(
        char('"'),
        [
          ref0(_textdata),
          char(','),
          char('\r'),
          char('\n'),
          string('""').map((_) => '"'),
        ].toChoiceParser().star(),
        char('"'),
      ).map3((_, text, __) => _Text(escaped: true, text: text.join()));

  Parser<_Text> _nonEscapedStar() => seq2(
        ref0(_nonEscaped),
        seq2(ref0(_escaped), ref0(_nonEscaped).optional()).star(),
      ).map2((p0, p1) {
        if (p1.isEmpty) return _Text(escaped: false, text: p0.trimRight());
        final sb = StringBuffer(p0);
        final last = p1.last;
        for (final i in p1) {
          final i0 = i.first.text;
          final i1 = i.second;
          if (i != last) {
            sb.write(i0);
            if (i1 != null) sb.write(i1);
          } else {
            sb.write(i0);
            if (i1 != null) sb.write(i1.trimRight());
          }
        }
        return _Text(escaped: true, text: sb.toString());
      });

  Parser<_Text> _escapedStar() => seq2(
        ref0(_escaped),
        ref0(_nonEscapedStar).optional(),
      ).map2((p0, p1) {
        if (p1 == null) return p0;
        return _Text(escaped: true, text: p0.text + p1.text);
      });
}
