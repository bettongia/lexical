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

/// Demonstrates stop-word filtering with betto_lexical.
///
/// Run with:
///   dart run example/stopwords.dart
library;

import 'package:betto_lexical/betto_lexical.dart';
import 'package:intl/locale.dart';

void main() {
  // getStopWords returns a Stopwords enum value whose .listing field is a
  // compile-time constant Set<String>. Membership tests are O(1).
  final en = getStopWords(Locale.parse('en'));
  print('Language: ${en.languageCode}');
  print('Stop-word count: ${en.listing.length}');
  print('');

  // Filtering function words from a token list improves the signal-to-noise
  // ratio for indexing, search, and text analysis tasks.
  final tokens = [
    'the',
    'quick',
    'brown',
    'fox',
    'jumps',
    'over',
    'the',
    'lazy',
    'dog',
  ];
  final contentWords = tokens.where((t) => !en.listing.contains(t)).toList();

  print('Input tokens:    $tokens');
  print('After filtering: $contentWords');
  print('');

  // Stop-word sets are available for 58 languages.
  // Switch locale to filter in another language.
  final fr = getStopWords(Locale.parse('fr'));
  final french = ['le', 'renard', 'brun', 'rapide', 'saute'];
  final frFiltered = french.where((t) => !fr.listing.contains(t)).toList();

  print('French tokens:   $french');
  print('After filtering: $frFiltered');
  print('');

  // You can also access the enum value directly by name when the language
  // code is known at compile time.
  print(
    '"is" is a stop word in English: ${Stopwords.en.listing.contains('is')}',
  );
  print(
    '"fox" is a stop word in English: ${Stopwords.en.listing.contains('fox')}',
  );
}
