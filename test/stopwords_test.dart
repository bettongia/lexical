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
// ── kEnglishStopWords constant ─────────────────────────────────────────────
import 'package:intl/locale.dart';
import 'package:betto_lexical/betto_lexical.dart' show getStopWords;
import 'package:test/test.dart';

void main() {
  group('English stop words', () {
    late final defaultStopwords = getStopWords(
      Locale.fromSubtags(languageCode: 'en'),
    );

    test('contains common function words', () {
      for (final word in ['the', 'is', 'and', 'a', 'an', 'in', 'of', 'to']) {
        expect(defaultStopwords.listing, contains(word));
      }
    });

    test('does not contain content words', () {
      for (final word in ['dog', 'fast', 'database', 'search']) {
        expect(defaultStopwords.listing, isNot(contains(word)));
      }
    });

    test('languageCode is en', () {
      expect(defaultStopwords.languageCode, equals('en'));
    });

    test('listing is non-empty', () {
      expect(defaultStopwords.listing, isNotEmpty);
    });
  });

  group('French stop words', () {
    late final fr = getStopWords(Locale.fromSubtags(languageCode: 'fr'));

    test('contains common French function words', () {
      for (final word in ['le', 'la', 'les', 'de', 'un', 'une']) {
        expect(fr.listing, contains(word));
      }
    });

    test('languageCode is fr', () {
      expect(fr.languageCode, equals('fr'));
    });
  });

  group('unsupported locale', () {
    test('throws ArgumentError for unknown language code', () {
      expect(
        () => getStopWords(Locale.fromSubtags(languageCode: 'xx')),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.invalidValue,
            'invalidValue',
            equals('xx'),
          ),
        ),
      );
    });

    test('ArgumentError message names the bad language code', () {
      expect(
        () => getStopWords(Locale.fromSubtags(languageCode: 'zz')),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('No stop-word set'),
          ),
        ),
      );
    });
  });
}
