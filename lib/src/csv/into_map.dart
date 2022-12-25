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
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:csv_ya/src/csv/types.dart';

/// Convert CSV into Map
class CsvIntoMap extends Converter<Csv, CsvAsMap> {
  @override
  CsvAsMap convert(Csv input) {
    final res = <Map<String, String>>[];
    _Sink(
      ChunkedConversionSink<CsvAsMap>.withCallback((xs) {
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
  Sink<Csv> startChunkedConversion(Sink<CsvAsMap> sink) {
    return _Sink(sink);
  }
}

class _Sink extends ChunkedConversionSink<Csv> {
  _Sink(this._sink);

  final Sink<CsvAsMap> _sink;
  List<String>? _header;

  @override
  void add(Csv chunk) {
    if (_header == null) {
      if (chunk.isEmpty) return;
      _header = [...chunk[0]];
      _intoMap(_header!, chunk.skip(1));
    } else {
      _intoMap(_header!, chunk);
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