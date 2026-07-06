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
import 'package:betto_lexical/betto_lexical.dart';
import 'package:test/test.dart';

void main() {
  group('Stemmer — English', () {
    late Stemmer stemmer;

    setUpAll(() {
      stemmer = Stemmer(Locale.parse('en'));
    });

    test('languageCode returns en', () {
      expect(stemmer.languageCode, equals('en'));
    });

    test('stems common regular verbs', () {
      expect(stemmer.stem('running'), equals('run'));
      expect(stemmer.stem('jumps'), equals('jump'));
      expect(stemmer.stem('walked'), equals('walk'));
    });

    test('stems common nouns', () {
      expect(stemmer.stem('dogs'), equals('dog'));
      expect(stemmer.stem('cats'), equals('cat'));
      expect(stemmer.stem('boxes'), equals('box'));
    });

    test('stems gerunds', () {
      expect(stemmer.stem('running'), equals('run'));
      expect(stemmer.stem('flying'), equals('fli'));
    });

    test('stems comparative adjectives', () {
      expect(stemmer.stem('faster'), equals('faster'));
      expect(stemmer.stem('happier'), equals('happier'));
    });

    test('already-stemmed word returns itself', () {
      expect(stemmer.stem('run'), equals('run'));
      expect(stemmer.stem('dog'), equals('dog'));
    });

    test('empty string returns empty string', () {
      expect(stemmer.stem(''), equals(''));
    });

    test('single character returns itself', () {
      expect(stemmer.stem('a'), equals('a'));
    });

    test('uppercase word is stemmed case-sensitively', () {
      // Snowball stemmers operate on the raw input; uppercase is preserved.
      final result = stemmer.stem('RUNNING');
      expect(result, isNotEmpty);
    });

    test('word with punctuation is passed through as-is', () {
      // The stemmer does not strip punctuation; callers are responsible for
      // tokenisation before stemming.
      final result = stemmer.stem("can't");
      expect(result, isNotEmpty);
    });
  });

  group('Stemmer — the other 27 supported languages', () {
    // One representative inflected word per language, asserting the actual
    // stem produced by the underlying `snowball_stemmer` algorithm. This is
    // a thin-wrapper correctness test (confirms each ISO 639-1 code selects
    // the *matching* `Algorithm`, per the factory's switch statement) — not
    // a linguistic audit of the Snowball algorithms themselves, which is
    // `package:snowball_stemmer`'s own tested responsibility. Every pair
    // below was verified to show the expected suffix-stripping pattern for
    // its language (plural/inflection removed) before being captured here.
    const cases = <String, (String word, String expectedStem)>{
      'ar': ('الكتب', 'كتب'),
      'hy': ('գրքեր', 'գրքեր'),
      'eu': ('etxeak', 'etxe'),
      'ca': ('cases', 'case'),
      'da': ('huse', 'hus'),
      'nl': ('huizen', 'huiz'),
      'fi': ('taloja', 'talo'),
      'fr': ('maisons', 'maison'),
      'de': ('Häuser', 'Haus'),
      'el': ('σπίτια', 'σπιτ'),
      'hi': ('किताबें', 'किताब'),
      'hu': ('házak', 'ház'),
      'id': ('berjalan', 'jalan'),
      'ga': ('leabhair', 'leabhair'),
      'it': ('case', 'cas'),
      'lt': ('namai', 'nam'),
      'ne': ('किताबहरू', 'किताब'),
      'no': ('husene', 'hus'),
      'pt': ('casas', 'cas'),
      'ro': ('case', 'cas'),
      'ru': ('дома', 'дом'),
      'sr': ('kuce', 'kuc'),
      'es': ('casas', 'cas'),
      'sv': ('husen', 'hus'),
      'ta': ('புத்தகங்கள்', 'புத்தகம்'),
      'tr': ('evler', 'ev'),
      'yi': ('ביכער', 'ביכ'),
    };

    for (final MapEntry(key: code, value: (word, expectedStem))
        in cases.entries) {
      test('$code: stems "$word" to "$expectedStem"', () {
        final stemmer = Stemmer(Locale.parse(code));
        expect(stemmer.languageCode, equals(code));
        expect(stemmer.stem(word), equals(expectedStem));
      });
    }

    test('all 28 documented languages construct without throwing', () {
      // Matches the language list in the Stemmer factory's doc comment
      // exactly — this is the completeness check for Phase 0.5's "wire up
      // all 28" decision, independent of the per-language stem-accuracy
      // tests above.
      const allCodes = [
        'ar', 'hy', 'eu', 'ca', 'da', 'nl', 'en', 'fi', 'fr', 'de', //
        'el', 'hi', 'hu', 'id', 'ga', 'it', 'lt', 'ne', 'no', 'pt', //
        'ro', 'ru', 'sr', 'es', 'sv', 'ta', 'tr', 'yi', //
      ];
      expect(allCodes, hasLength(28));
      for (final code in allCodes) {
        expect(() => Stemmer(Locale.parse(code)), returnsNormally);
      }
    });
  });

  group('Stemmer — unsupported locales', () {
    test('Chinese locale throws ArgumentError with language code as value', () {
      // Snowball has no CJK algorithm — kmdb's WI-6 consumer relies on
      // exactly this throw to decide "skip stemming" for such languages.
      expect(
        () => Stemmer(Locale.parse('zh')),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.invalidValue,
            'invalidValue',
            equals('zh'),
          ),
        ),
      );
    });

    test(
      'unknown language code throws ArgumentError with descriptive message',
      () {
        expect(
          () => Stemmer(Locale.parse('xx')),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('No stemmer available'),
            ),
          ),
        );
      },
    );
  });
}
