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

/// Demonstrates morphological stemming with betto_lexical.
///
/// Run with:
///   dart run example/stem.dart
library;

import 'package:betto_lexical/betto_lexical.dart';
import 'package:intl/locale.dart';

void main() {
  final stemmer = Stemmer(Locale.parse('en'));
  print('Stemmer language: ${stemmer.languageCode}');
  print('');

  // Inflected forms of the same root are reduced to a common stem, making
  // them equivalent for indexing and search purposes.
  final groups = {
    'run (verb forms)': ['run', 'runs', 'running', 'ran'],
    'library (noun forms)': ['library', 'libraries'],
    'fast (adjective forms)': ['fast', 'faster', 'fastest'],
  };

  for (final MapEntry(:key, :value) in groups.entries) {
    print(key);
    for (final word in value) {
      print('  ${word.padRight(12)} → ${stemmer.stem(word)}');
    }
    print('');
  }

  // The Snowball algorithm is lossy — the stem is a canonical key, not
  // necessarily a valid dictionary word.
  print('Note: stems are canonical keys, not dictionary words.');
  print('  "libraries" → "${stemmer.stem('libraries')}"');

  // The stemmer is case-sensitive; normalise to lowercase before stemming
  // if case-insensitive matching is required.
  print('  "Running"   → "${stemmer.stem('Running')}"  (uppercase preserved)');
  print('  "running"   → "${stemmer.stem('running')}"');
}
