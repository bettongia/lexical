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

/// Demonstrates building a simple inverted index using all three betto_lexical
/// subsystems: tokenisation, stop-word filtering, and stemming.
///
/// An inverted index maps each term to the set of documents that contain it,
/// enabling fast full-text search. The pipeline applied to each document is:
///
///   raw text
///     → tokenise          (split into word tokens)
///     → lowercase         (normalise case)
///     → remove stop words (drop high-frequency function words)
///     → stem              (reduce inflected forms to a common root)
///     → index term
///
/// The same pipeline is applied to query strings so that a search for
/// "running" matches documents containing "runs", "ran", or "runner".
///
/// Run with:
///   dart run example/example.dart
library;

import 'package:betto_lexical/betto_lexical.dart';
import 'package:intl/locale.dart';

void main() {
  final corpus = {
    'fox': 'The quick brown fox jumps over the lazy dog.',
    'chase': 'The dog chased the fox through the open field.',
    'library': 'A quiet cat sleeps in the warm library.',
    'books': 'Libraries contain many books about running and jumping.',
    'search': 'Full-text search engines build inverted indexes from documents.',
    'index': 'An inverted index maps terms to the documents that contain them.',
  };

  final locale = Locale.parse('en');
  final engine = IndexEngine(locale);

  // Index the corpus.
  print('=== Indexing corpus ===');
  for (final MapEntry(:key, :value) in corpus.entries) {
    engine.add(key, value);
    print('  [$key] "$value"');
  }
  print('');

  // Show the full index so the effect of each pipeline step is visible.
  print('=== Inverted index (${engine.termCount} unique terms) ===');
  engine.printIndex();
  print('');

  // Query: the engine applies the same pipeline to the query string so
  // inflected forms match documents regardless of how the word appeared.
  print('=== Queries ===');
  for (final query in ['running', 'library', 'foxes', 'indexes', 'the']) {
    engine.query(query);
  }
}

/// Builds and queries an inverted index over a corpus of documents.
class IndexEngine {
  IndexEngine(Locale locale)
    : _tokeniser = createDefaultTokenizer(),
      _stopWords = getStopWords(locale),
      _stemmer = Stemmer(locale);

  final Tokenizer _tokeniser;
  final Stopwords _stopWords;
  final Stemmer _stemmer;

  // term → set of document IDs
  final Map<String, Set<String>> _index = {};

  int get termCount => _index.length;

  /// Processes [text] through the full pipeline and adds each resulting term
  /// to the index under [docId].
  void add(String docId, String text) {
    for (final term in _pipeline(text)) {
      _index.putIfAbsent(term, () => {}).add(docId);
    }
  }

  /// Searches the index for [queryText] and prints the matching document IDs.
  ///
  /// The query goes through the same pipeline as the indexed documents, so
  /// inflected variants ("running", "ran", "runs") all resolve to the same
  /// stem and match the same entries.
  void query(String queryText) {
    final terms = _pipeline(queryText);
    if (terms.isEmpty) {
      print('  "$queryText" → (removed by pipeline — no content terms)');
      return;
    }

    // For a multi-term query, intersect the result sets (AND semantics).
    final hits = terms
        .map((t) => _index[t] ?? <String>{})
        .reduce((a, b) => a.intersection(b));

    final stem = terms.join(', ');
    if (hits.isEmpty) {
      print('  "$queryText" (stem: $stem) → (no results)');
    } else {
      print('  "$queryText" (stem: $stem) → ${(hits.toList()..sort())}');
    }
  }

  /// Prints the index contents sorted alphabetically by term.
  void printIndex() {
    for (final term in (_index.keys.toList()..sort())) {
      final docs = (_index[term]!.toList()..sort()).join(', ');
      print('  $term → $docs');
    }
  }

  /// Applies the full text pipeline: tokenise → lowercase → stop-word filter
  /// → stem. Returns the list of index terms produced from [text].
  List<String> _pipeline(String text) {
    return _tokeniser
        .tokenise(text)
        .map((token) => token.toLowerCase())
        .where((token) => !_stopWords.listing.contains(token))
        .map((token) => _stemmer.stem(token))
        .toList();
  }
}
