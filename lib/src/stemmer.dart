// Copyright 2026 The Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:intl/locale.dart';
import 'package:snowball_stemmer/snowball_stemmer.dart';

/// Reduces words to their base form (stem) using the Snowball algorithm.
///
/// Currently supports English (`en`). Construct with a [Locale] and call
/// [stem] on individual tokens.
///
/// ```dart
/// final stemmer = Stemmer(Locale.parse('en'));
/// print(stemmer.stem('libraries')); // → 'librari'
/// print(stemmer.stem('running'));   // → 'run'
/// ```
class Stemmer {
  final Locale _locale;
  final SnowballStemmer _stemmer;

  Stemmer._internal(Locale locale, SnowballStemmer stemmer)
    : _locale = locale,
      _stemmer = stemmer;

  /// Creates a [Stemmer] for the given [locale].
  ///
  /// Throws [ArgumentError] if the locale's language code is not supported.
  /// Currently supported: `en` (English).
  factory Stemmer(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.english));
    }
    throw ArgumentError.value(
      'The requested locale with language code ${locale.languageCode}'
      ' is not currently supported.',
    );
  }

  /// Returns the stem of [word].
  ///
  /// The result is a normalised base form suitable for index lookups; it is
  /// not guaranteed to be a valid dictionary word.
  String stem(String word) {
    return _stemmer.stem(word);
  }

  /// The IETF language code this stemmer was created for (e.g. `'en'`).
  String get languageCode => _locale.languageCode;
}
