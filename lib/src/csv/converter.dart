/*
Copyright 2022 Koga Kazuo (kkazuo@kkazuo.com)

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
import 'dart:convert';

import 'package:csv_ya/src/csv/types.dart';

/// Decoder of CSV
class CsvDecoder extends Converter<String, Csv> {
  @override
  Csv convert(String input) {
    final res = <List<String>>[];
    _Sink(
      ChunkedConversionSink<List<List<String>>>.withCallback((xs) {
        for (final x in xs) {
          res.addAll(x);
        }
      }),
    )
      ..add(input)
      ..close();
    return res;
  }

  @override
  Sink<String> startChunkedConversion(Sink<Csv> sink) {
    return _Sink(sink);
  }
}

class _Str {
  _Str(this.str, {required this.escaped});
  final bool escaped;
  final List<int> str;

  @override
  String toString() => '$str $escaped';
}

class _Sink implements ChunkedConversionSink<String> {
  _Sink(this._sink);

  final Sink<List<List<String>>> _sink;
  var _str = <int>[];
  var _fld = <_Str>[];
  var _rec = <String>[];
  var _csv = <List<String>>[];
  var _esc = false;
  var _quo = false;
  var _snd = false;

  static const nl = 10;
  static const cr = 13;
  static const sep = 44;
  static const quo = 34;

  @override
  void add(String chunk) {
    for (final a in chunk.runes) {
      switch (a) {
        case nl:
          _quo = false;
          if (_esc) {
            _str.add(a);
          } else {
            _onSep(sep);
            _csv.add(_rec);
            _rec = <String>[];
            _snd = false;
          }
          break;
        case cr:
          _quo = false;
          if (_esc) {
            _str.add(a);
          }
          break;
        case sep:
          _onSep(a);
          break;
        case quo:
          _onQuo(a);
          break;
        default:
          _quo = false;
          _str.add(a);
          break;
      }
    }
    if (_csv.isNotEmpty) {
      _sink.add(_csv);
      _csv = <List<String>>[];
    }
  }

  void _onSep(int a) {
    _quo = false;
    if (_esc) {
      _str.add(a);
      return;
    }
    if (_str.isNotEmpty || _snd) {
      _fld.add(_Str(_str, escaped: false));
    }
    _rec.add(_join());
    _str = [];
    _snd = true;
  }

  String _join() {
    final len = _fld.length;
    switch (len) {
      case 0:
        return '';
      case 1:
        {
          final f = _fld[0];
          final s = f.escaped
              ? String.fromCharCodes(f.str)
              : String.fromCharCodes(f.str).trim();
          _fld = [];
          return s;
        }
    }
    final last = len - 1;
    final fld = <int>[];
    for (var i = 1; i < last; i += 1) {
      fld.addAll(_fld[i].str);
    }
    final l = _fld[0].escaped
        ? String.fromCharCodes(_fld[0].str)
        : String.fromCharCodes(_fld[0].str).trimLeft();
    final r = _fld[last].escaped
        ? String.fromCharCodes(_fld[last].str)
        : String.fromCharCodes(_fld[last].str).trimRight();
    _fld = [];
    return fld.isEmpty ? l + r : l + String.fromCharCodes(fld) + r;
  }

  void _onQuo(int a) {
    if (_quo) {
      _quo = false;
      _esc = true;
      _str.add(a);
      return;
    }
    if (_str.isNotEmpty) {
      _fld.add(_Str(_str, escaped: _esc));
      _str = [];
    }
    if (_esc) {
      _esc = false;
      _quo = true;
      return;
    }
    _esc = true;
  }

  @override
  void close() {
    if (_str.isNotEmpty || _snd) {
      _onSep(sep);
    }
    if (_rec.isNotEmpty) {
      _csv.add(_rec);
      _rec = <String>[];
    }
    if (_csv.isNotEmpty) {
      _sink.add(_csv);
      _csv = <List<String>>[];
    }
    _sink.close();
  }
}
