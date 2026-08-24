# Changelog

## 0.1.0

Stable release. Moved to Dart 3.13

## 0.1.0-dev.2

### Stemming

- `Stemmer` now supports 28 languages, up from just English: Arabic, Armenian,
  Basque, Catalan, Danish, Dutch, English, Finnish, French, German, Greek,
  Hindi, Hungarian, Indonesian, Irish, Italian, Lithuanian, Nepali, Norwegian,
  Portuguese, Romanian, Russian, Serbian, Spanish, Swedish, Tamil, Turkish, and
  Yiddish — every language `package:snowball_stemmer` implements (excluding its
  generic `porter` variant, an alternate English algorithm rather than a
  distinct language). Unsupported language codes still throw `ArgumentError`, as
  before.

### Tokenization

- Re-exports `OffsetTokenizer` and `TokenSpan` from `betto_icu` (now pinned to
  `^0.1.0-dev.2`) — a `Tokenizer` that also reports each token's character
  offsets in the source text. Implemented by `IcuTokenizer` and
  `RegExpTokenizer`.

## 0.1.0-dev.1

Initial development release.

### Tokenization

- `createDefaultTokenizer()` returns the best tokenizer for the current platform
  at compile time — no runtime `Platform` checks.
- `IcuTokenizer` — UAX #29 word segmentation via the system ICU library (native:
  macOS, Linux, Windows, Android, iOS).
- `BrowserTokenizer` — word segmentation via `Intl.Segmenter` (web).
- `RegExpTokenizer` — lightweight Latin-script tokenizer in pure Dart, available
  on all platforms.

### Stemming

- `Stemmer` — Snowball-based stemmer. Construct with a `Locale` and call
  `stem(word)` to reduce tokens to their base form. English (`en`) supported.

### Stop words

- `getStopWords(Locale)` — returns a `Stopwords` enum value containing the
  stop-word set for the given locale. Throws `ArgumentError` for unsupported
  language codes.
- 58 languages sourced from
  [stopwords-iso](https://github.com/stopwords-iso/stopwords-iso).
