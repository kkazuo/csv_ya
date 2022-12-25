<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Yet another CSV parser that you may want.

## Features

- Tolerant quate escaping.
- Streaming conversion for very large files.

## Usage

```dart
const input = 'a,b,c\n1,2,3';
print(parseCsv(input));
>>> [['a', 'b', 'c'], ['1', '2', '3']]
print(parseCsvAsMap(input));
>>> [{'a': '1', 'b': '2', 'c': '3'}]
```
