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

// Smoke tests for the web (BrowserTokenizer) code path. These run exclusively
// on the browser platform so the conditional export resolves to
// default_tokenizer_web.dart rather than default_tokenizer_native.dart.
@TestOn('browser')
library;

import 'package:betto_lexical/betto_lexical.dart';
import 'package:test/test.dart';

void main() {
  group('createDefaultTokenizer (web / BrowserTokenizer)', () {
    test('returns a Tokenizer instance', () {
      expect(createDefaultTokenizer(), isA<Tokenizer>());
    });

    test('tokenises an English sentence', () {
      final tokens = createDefaultTokenizer().tokenise('The quick brown fox');
      expect(tokens, containsAll(['The', 'quick', 'brown', 'fox']));
    });

    test('returns empty list for empty input', () {
      expect(createDefaultTokenizer().tokenise(''), isEmpty);
    });

    test('returns empty list for whitespace-only input', () {
      expect(createDefaultTokenizer().tokenise('   '), isEmpty);
    });

    test('successive calls return independent instances', () {
      final t1 = createDefaultTokenizer();
      final t2 = createDefaultTokenizer();
      expect(t1, isNot(same(t2)));
      expect(t1.tokenise('hello world'), equals(t2.tokenise('hello world')));
    });
  });
}
