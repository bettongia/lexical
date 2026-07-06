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
/// Supports 28 languages (see [Stemmer.new] for the full list). Construct
/// with a [Locale] and call [stem] on individual tokens.
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
  ///
  /// Supported (ISO 639-1 → Snowball algorithm): `ar` (Arabic), `hy`
  /// (Armenian), `eu` (Basque), `ca` (Catalan), `da` (Danish), `nl` (Dutch),
  /// `en` (English), `fi` (Finnish), `fr` (French), `de` (German), `el`
  /// (Greek), `hi` (Hindi), `hu` (Hungarian), `id` (Indonesian), `ga`
  /// (Irish), `it` (Italian), `lt` (Lithuanian), `ne` (Nepali), `no`
  /// (Norwegian), `pt` (Portuguese), `ro` (Romanian), `ru` (Russian), `sr`
  /// (Serbian), `es` (Spanish), `sv` (Swedish), `ta` (Tamil), `tr` (Turkish),
  /// `yi` (Yiddish) — every language `package:snowball_stemmer` implements,
  /// except its generic `porter` variant (an alternate English algorithm,
  /// not a distinct language — `en` already maps to `Algorithm.english`).
  factory Stemmer(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.arabic));
      case 'hy':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.armenian));
      case 'eu':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.basque));
      case 'ca':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.catalan));
      case 'da':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.danish));
      case 'nl':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.dutch));
      case 'en':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.english));
      case 'fi':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.finnish));
      case 'fr':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.french));
      case 'de':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.german));
      case 'el':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.greek));
      case 'hi':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.hindi));
      case 'hu':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.hungarian));
      case 'id':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.indonesian));
      case 'ga':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.irish));
      case 'it':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.italian));
      case 'lt':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.lithuanian));
      case 'ne':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.nepali));
      case 'no':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.norwegian));
      case 'pt':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.portuguese));
      case 'ro':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.romanian));
      case 'ru':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.russian));
      case 'sr':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.serbian));
      case 'es':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.spanish));
      case 'sv':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.swedish));
      case 'ta':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.tamil));
      case 'tr':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.turkish));
      case 'yi':
        return Stemmer._internal(locale, SnowballStemmer(Algorithm.yiddish));
    }
    throw ArgumentError.value(
      locale.languageCode,
      'locale.languageCode',
      'No stemmer available for language',
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
