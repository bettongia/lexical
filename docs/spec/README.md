---
title: Technical Specification
subtitle: betto_lexical
toc-title: "Contents"
...

- **Package:** `betto_lexical`
- **Version:** 0.1.0-dev.1
- **Dart SDK:** ^3.12.0

# Purpose and scope

`betto_lexical` provides lexical text processing primitives for Dart and
Flutter applications. It covers three concerns:

1. **Tokenization** — splitting raw text into word tokens, with Unicode-aware
   implementations for both native and web platforms.
2. **Stemming** — reducing inflected word forms to their morphological root
   (stem) so that *run*, *running*, and *runs* can be treated as the same term.
3. **Stop-word filtering** — identifying and removing high-frequency function
   words (*the*, *a*, *is*) that carry little semantic content.

The package is part of the Bettongia open-source family. It is a pure library
with no Flutter dependency — it can be used in CLI tools, server-side Dart, and
Flutter apps alike.

# Architecture

The package is organised into three independent subsystems that share only the
`intl` `Locale` type as a cross-cutting concern.

```
betto_lexical (public API)
│
├── Tokenization ─── betto_icu (external package)
│   ├── IcuTokenizer          (native: system ICU via FFI)
│   ├── BrowserTokenizer      (web: browser Intl.Segmenter via js_interop)
│   └── RegExpTokenizer       (all platforms: pure Dart, English-oriented)
│
├── Stemming ──────── snowball_stemmer (external package)
│   └── Stemmer               (wraps SnowballStemmer, locale-dispatched)
│
└── Stop words ────── generated data
    ├── getStopWords()        (lookup by Locale)
    └── Stopwords enum        (generated; one Set<String> per language)
```

Platform branching for the default tokeniser is resolved at compile time via a
conditional export in `lib/betto_lexical.dart`:

```dart
export 'src/default_tokeniser_native.dart'
    if (dart.library.js_interop) 'src/default_tokeniser_web.dart'
    show createDefaultTokenizer;
```

This means there is no runtime `Platform.isWeb` check and the unused code path
is dead-eliminated by the compiler.

# Platform support

| Feature | Native (macOS · Linux · Windows · Android · iOS) | Web |
|---|:---:|:---:|
| `RegExpTokenizer` | ✅ | ✅ |
| `IcuTokenizer` | ✅ | — |
| `BrowserTokenizer` | — | ✅ |
| `createDefaultTokenizer()` | `IcuTokenizer` | `BrowserTokenizer` |
| `Stemmer` | ✅ | ✅ |
| `getStopWords` | ✅ | ✅ |

`IcuTokenizer` links to the system ICU library via Dart FFI. No bundling is
required because ICU ships with every supported native target:
`libicucore.dylib` on macOS/iOS, `libicuuc.so` on Android/Linux, and
`icu.dll` on Windows.

`BrowserTokenizer` delegates to the browser's native `Intl.Segmenter` API via
`dart:js_interop`. This gives the same UAX #29 word segmentation quality as
ICU at zero bundle cost.

# Tokenization

## Interface

The `Tokenizer` interface is defined in `betto_icu` and re-exported by this
package. All implementations share a single method:

```dart
abstract interface class Tokenizer {
  List<String> tokenise(String text);
}
```

`tokenise` returns a list of word tokens extracted from `text`. What counts as
a word boundary is implementation-specific (see below). An empty or
whitespace-only input returns an empty list.

## Implementations

### `RegExpTokenizer`

A pure-Dart tokeniser that splits on a Unicode-aware regular expression. It
works on all platforms with no native dependencies. Its word-boundary logic is
tuned for Latin-script languages and is not suitable for scripts that do not
use whitespace to delimit words (CJK, Thai, Lao, etc.).

Use this tokeniser when:

- FFI and `js_interop` are unavailable (e.g., pure-Dart server tools).
- The input is guaranteed to be Latin-script only.

### `IcuTokenizer` (native only)

Delegates to the platform ICU library via FFI, implementing UAX #29 Unicode
Text Segmentation. Handles CJK, Arabic, Thai, Devanagari, and all other
Unicode scripts correctly. This is the tokeniser returned by
`createDefaultTokenizer()` on native platforms.

### `BrowserTokenizer` (web only)

Delegates to the browser's `Intl.Segmenter` API via `dart:js_interop`,
providing the same UAX #29 quality as ICU without any Wasm or native bundling.
This is the tokeniser returned by `createDefaultTokenizer()` on web.

## Factory function

```dart
Tokenizer createDefaultTokenizer()
```

Returns the best available tokeniser for the current platform. On native this
is `IcuTokenizer`; on web, `BrowserTokenizer`. Each call returns a new
independent instance.

# Stemming

## Class: `Stemmer`

```dart
class Stemmer {
  factory Stemmer(Locale locale);
  String stem(String word);
  String get languageCode;
}
```

`Stemmer` wraps the Snowball stemming algorithm (via the `snowball_stemmer`
package). A factory constructor dispatches on `locale.languageCode` and
returns a correctly configured stemmer.

### Constructor

```dart
factory Stemmer(Locale locale)
```

Creates a `Stemmer` for the specified locale. Throws `ArgumentError` if the
language code is not supported.

**Currently supported languages:**

| Language code | Language |
|---|---|
| `en` | English |

### Methods

```dart
String stem(String word)
```

Returns the stemmed form of `word`. The stemmer operates on individual tokens;
tokenization is the caller's responsibility.

Behaviour notes:

- Case is preserved — the stemmer is case-sensitive. Pass lowercased tokens if
  case-insensitive stemming is required.
- Punctuation attached to a word is passed through unchanged. Strip punctuation
  before calling `stem`.
- Words that are already at their root form are returned unchanged.
- The Snowball algorithm is lossy — the stem is not always a valid dictionary
  word (e.g., `libraries` → `librari`).

```dart
String get languageCode
```

Returns the ISO 639-1 language code for which this stemmer was created.

### Error handling

`Stemmer(locale)` throws `ArgumentError` for any locale whose `languageCode`
is not in the supported set. The error message includes the unsupported code.

# Stop words

## Function: `getStopWords`

```dart
Stopwords getStopWords(Locale locale)
```

Returns the `Stopwords` enum case whose `languageCode` matches
`locale.languageCode`. Throws `StateError` if no match is found (i.e., the
language is not in the bundled data).

## Enum: `Stopwords`

```dart
enum Stopwords {
  af('af', _afStopwords),
  ar('ar', _arStopwords),
  // …55 more cases…
  zu('zu', _zuStopwords);

  const Stopwords(this.languageCode, this.listing);

  final String languageCode;
  final Set<String> listing;
}
```

`Stopwords` is a generated enum. Each case carries:

| Field | Type | Description |
|---|---|---|
| `languageCode` | `String` | ISO 639-1 (or extended IANA) language tag |
| `listing` | `Set<String>` | All stop words for that language |

The `listing` field is a compile-time constant `Set<String>`. Membership tests
(`listing.contains(word)`) run in O(1).

### Supported languages

| Code | Language | Code | Language | Code | Language |
|---|---|---|---|---|---|
| `af` | Afrikaans | `ga` | Irish | `pt` | Portuguese |
| `ar` | Arabic | `gl` | Galician | `ro` | Romanian |
| `bg` | Bulgarian | `gu` | Gujarati | `ru` | Russian |
| `bn` | Bengali | `ha` | Hausa | `sk` | Slovak |
| `br` | Breton | `he` | Hebrew | `sl` | Slovenian |
| `ca` | Catalan | `hi` | Hindi | `so` | Somali |
| `cs` | Czech | `hr` | Croatian | `st` | Sotho |
| `da` | Danish | `hu` | Hungarian | `sv` | Swedish |
| `de` | German | `hy` | Armenian | `sw` | Swahili |
| `el` | Greek | `id` | Indonesian | `th` | Thai |
| `en` | English | `it` | Italian | `tl` | Tagalog |
| `eo` | Esperanto | `ja` | Japanese | `tr` | Turkish |
| `es` | Spanish | `ko` | Korean | `uk` | Ukrainian |
| `et` | Estonian | `ku` | Kurdish | `ur` | Urdu |
| `eu` | Basque | `la` | Latin | `vi` | Vietnamese |
| `fa` | Persian | `lt` | Lithuanian | `yo` | Yoruba |
| `fi` | Finnish | `lv` | Latvian | `zh` | Chinese |
| `fr` | French | `mr` | Marathi | `zu` | Zulu |
| | | `ms` | Malay | | |
| | | `nl` | Dutch | | |
| | | `no` | Norwegian | | |
| | | `pl` | Polish | | |

## Data source and code generation

Stop-word data is sourced from
[stopwords-iso](https://github.com/stopwords-iso/stopwords-iso), published
under the MIT licence.

The files `lib/src/stopwords.g.dart` and `lib/src/stopwords/*.g.dart` are
**generated** — do not edit them by hand. The generator is `tool/loader.dart`.
It downloads `stopwords-iso.json` from the upstream repository, then emits:

- One `part of` file per language at `lib/src/stopwords/<code>.g.dart`,
  each containing a single `const Set<String> _<code>Stopwords = {...}`.
- A thin main file `lib/src/stopwords.g.dart` that declares the `Stopwords`
  enum (referencing the per-language constants) and includes all part files.

Splitting the data across per-language files keeps each file to a manageable
size for IDEs and diff tools; the main file is only ~140 lines.

To regenerate after an upstream update:

```bash
make generate_stopwords
```

# Public API surface

The single library entry point is `package:betto_lexical/betto_lexical.dart`.
It exports:

| Symbol | Origin | Description |
|---|---|---|
| `Tokenizer` | `betto_icu` | Abstract tokeniser interface |
| `RegExpTokenizer` | `betto_icu` | Pure-Dart, all-platform tokeniser |
| `IcuTokenizer` | `betto_icu` | UAX #29 tokeniser via system ICU (native) |
| `BrowserTokenizer` | `betto_icu` | UAX #29 tokeniser via `Intl.Segmenter` (web) |
| `createDefaultTokenizer` | this package | Platform-selecting factory |
| `Stemmer` | this package | Snowball-based morphological stemmer |
| `getStopWords` | this package | Stop-word lookup by `Locale` |
| `Stopwords` | this package | Generated enum of per-language stop-word sets |

Nothing under `lib/src/` is part of the public API.

# Dependencies

## Runtime

| Package | Version | Role |
|---|---|---|
| `betto_icu` | `^0.1.0-dev.1` | Tokenizer interface and implementations |
| `intl` | `^0.20.2` | `Locale` type for language-code dispatch |
| `snowball_stemmer` | `^0.1.0` | Snowball stemming algorithm |

## Development

| Package | Version | Role |
|---|---|---|
| `betto_builder_tools` | `^0.1.0-dev.1` | Data-download helper used by `tool/loader.dart` |
| `code_builder` | `^4.11.1` | AST-based Dart code generation for stop-word files |
| `lints` | `^6.0.0` | Recommended Dart lint rules |
| `test` | `^1.25.6` | Unit test framework |

# Error handling

| Call site | Condition | Exception |
|---|---|---|
| `Stemmer(locale)` | `locale.languageCode` not supported | `ArgumentError` |
| `getStopWords(locale)` | `locale.languageCode` not in `Stopwords` enum | `StateError` (from `Enum.byName`) |

There is no fallback behaviour: callers must guard unsupported locales
explicitly before calling either function.

# Testing

Tests live in `test/` and are run with `make test` (delegates to `dart test`).
The suite covers three areas:

**`default_tokeniser_test.dart`** — `createDefaultTokenizer()`
: Returns a working tokeniser; produces correct token lists for English,
  technical identifiers (hex values, camelCase), and non-Latin scripts
  (Japanese, Arabic, Thai). Handles empty and whitespace-only input. Each call
  to the factory returns an independent instance.

**`stemmer_test.dart`** — `Stemmer`
: English stemming of verbs, nouns, gerunds, and comparative adjectives.
  Already-stemmed words are returned unchanged. Case-sensitivity and
  punctuation pass-through are verified. `ArgumentError` is asserted for all
  unsupported locales (French, German, unknown codes).

**`stopwords_test.dart`** — `getStopWords`
: English stop-word set contains common function words (*the*, *is*, *and*,
  *a*, *an*, *in*, *of*, *to*) and does not contain content words (*dog*,
  *fast*, *database*, *search*).

Minimum required coverage is 90%. Run `make coverage` to generate an LCOV
report under `site/coverage/`.
