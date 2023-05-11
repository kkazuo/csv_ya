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
import 'dart:math';

import 'package:csv_ya/src/csv/types.dart';

/// Convert from list of list of string into list of map.
class CsvIntoMap extends Converter<Csv, CsvAsMap> {
  /// CsvIntoMap
  CsvIntoMap({this.headerConverter, this.headers});

  /// Header line words converter.
  final Iterable<String> Function(List<String>)? headerConverter;

  /// Pass the headers.
  ///
  /// If you specify the [headers], [headerConverter] will be ignored.
  final List<String>? headers;

  @override
  CsvAsMap convert(Csv input) {
    final res = <Map<String, String>>[];
    _Sink(
      ChunkedConversionSink<CsvAsMap>.withCallback((xs) {
        for (final x in xs) {
          res.addAll(x);
        }
      }),
      headerConverter,
      headers,
    )
      ..add(input)
      ..close();
    return res;
  }

  @override
  Sink<Csv> startChunkedConversion(Sink<CsvAsMap> sink) {
    return _Sink(sink, headerConverter, headers);
  }
}

class _Sink implements ChunkedConversionSink<Csv> {
  _Sink(this._sink, this._headerConverter, this._headers);

  final Sink<CsvAsMap> _sink;
  final Iterable<String> Function(List<String>)? _headerConverter;

  List<String>? _headers;

  @override
  void add(Csv chunk) {
    if (_headers == null) {
      if (chunk.isEmpty) return;
      final hc = _headerConverter;
      _headers = hc == null ? [...chunk[0]] : [...hc(chunk[0])];
      _intoMap(_headers!, chunk.skip(1));
    } else {
      _intoMap(_headers!, chunk);
    }
  }

  void _intoMap(List<String> header, Iterable<List<String>> iter) {
    final xs = iter.map((e) {
      final m = <String, String>{};
      final x = min(header.length, e.length);
      for (var i = 0; i < x; i += 1) {
        m[header[i]] = e[i];
      }
      return m;
    }).toList();
    if (xs.isNotEmpty) _sink.add(xs);
  }

  @override
  void close() {
    _sink.close();
  }
}
