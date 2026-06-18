# Changelog

## 0.1.0-dev.2

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
