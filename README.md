# betto_lexical

Lexical text utilities for Dart and Flutter — tokenization, stemming, and
stop-word filtering. Part of the [Bettongia](https://github.com/bettongia)
open-source family.

## Features

- **Tokenizers** — `RegExpTokenizer` (pure Dart), `IcuTokenizer` (UAX #29 via
  system ICU, superior Unicode/CJK coverage), and `BrowserTokenizer` (web).
  `createDefaultTokenizer()` selects the best tokeniser for the current platform
  automatically.
- **Stemmer** — Snowball-based stemmer via `Stemmer(locale)`. Currently supports
  English (`en`).
- **Stop words** — `getStopWords(locale)` returns the `Stopwords` set for a
  locale. Covers 58 languages.

## Platform support

| Feature                    | Native (macOS / Linux / Windows / Android) | Web                |
| -------------------------- | ------------------------------------------ | ------------------ |
| `RegExpTokenizer`          | ✅                                         | ✅                 |
| `IcuTokenizer`             | ✅ (system ICU, no bundling)               | —                  |
| `BrowserTokenizer`         | —                                          | ✅                 |
| `createDefaultTokenizer()` | `IcuTokenizer`                             | `BrowserTokenizer` |
| `Stemmer`                  | ✅                                         | ✅                 |
| `getStopWords`             | ✅                                         | ✅                 |

## Installation

```yaml
dependencies:
  betto_lexical: ^0.1.0
```

## Usage

### Tokenization

```dart
import 'package:betto_lexical/betto_lexical.dart';

// Platform-aware default (IcuTokenizer on native, BrowserTokenizer on web).
final tokeniser = createDefaultTokenizer();
final tokens = tokeniser.tokenise('The quick brown fox');
// → ['The', 'quick', 'brown', 'fox']

// Pure-Dart alternative — works everywhere, English-oriented.
final regexpTokenizer = RegExpTokenizer();
```

### Stemming

```dart
import 'package:betto_lexical/betto_lexical.dart';
import 'package:intl/locale.dart';

final stemmer = Stemmer(Locale.parse('en'));
print(stemmer.stem('running')); // → 'run'
print(stemmer.stem('libraries')); // → 'librari'
```

### Stop words

```dart
import 'package:betto_lexical/betto_lexical.dart';
import 'package:intl/locale.dart';

final stopWords = getStopWords(Locale.parse('en'));
final tokens = ['the', 'quick', 'brown', 'fox'];
final filtered = tokens.where((t) => !stopWords.listing.contains(t)).toList();
// → ['quick', 'brown', 'fox']
```

Stop words are available for: Afrikaans, Arabic, Bulgarian, Bengali, Breton,
Catalan, Czech, Danish, German, Greek, English, Esperanto, Spanish, Estonian,
Basque, Persian, Finnish, French, Irish, Galician, Gujarati, Hausa, Hebrew,
Hindi, Croatian, Hungarian, Armenian, Indonesian, Italian, Japanese, Korean,
Kurdish, Latin, Lithuanian, Latvian, Marathi, Malay, Dutch, Norwegian, Polish,
Portuguese, Romanian, Russian, Slovak, Slovenian, Somali, Sotho, Swedish,
Swahili, Thai, Tagalog, Turkish, Ukrainian, Urdu, Vietnamese, Yoruba, Chinese,
and Zulu.

Stop-word data is sourced from
[stopwords-iso](https://github.com/stopwords-iso/stopwords-iso), a community
collection of stop-word lists for 50+ languages published under the MIT licence.

### Regenerating stop words

The files under `lib/src/stopwords/` and `lib/src/stopwords.g.dart` are
generated from the upstream dataset and must not be edited by hand. To update
them, run:

```bash
make generate_stopwords
```

This downloads the latest `stopwords-iso.json` from the stopwords-iso
repository, then emits one `part of` file per language plus a thin main file
that declares the `Stopwords` enum. Re-run whenever the upstream dataset is
updated.

## License

Apache 2.0 — see [LICENSE](LICENSE).

The [snowball_stemmer](https://pub.dev/packages/snowball_stemmer) package is
used for stemming and is subject to its own licence.
