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

/// Demonstrates tokenization with betto_lexical.
///
/// Run with:
///   dart run example/tokenize.dart
library;

import 'package:betto_lexical/betto_lexical.dart';

void main() {
  // createDefaultTokenizer() selects the best available tokeniser for the
  // current platform: IcuTokenizer on native (system ICU via FFI) and
  // BrowserTokenizer on web (browser Intl.Segmenter). Both conform to UAX #29
  // Unicode Text Segmentation, giving correct results for all scripts.
  final tokeniser = createDefaultTokenizer();

  // English sentence
  final english = 'The quick brown fox jumps over the lazy dog.';
  print('Input:  $english');
  print('Tokens: ${tokeniser.tokenise(english)}');
  print('');

  // Non-Latin scripts are handled correctly because both IcuTokenizer and
  // BrowserTokenizer use Unicode word-break rules rather than whitespace splits.
  final japanese = '日本語のテキストを分割する';
  print('Input:  $japanese');
  print('Tokens: ${tokeniser.tokenise(japanese)}');
  print('');

  // RegExpTokenizer is a pure-Dart alternative that works on every platform
  // without FFI or js_interop. It is well-suited to Latin-script input but
  // does not handle scripts that omit spaces between words.
  final regexpTokenizer = RegExpTokenizer();
  final technical = 'Connect via mTLS using certificate 0xDEADBEEF.';
  print('Input (RegExpTokenizer):  $technical');
  print('Tokens: ${regexpTokenizer.tokenise(technical)}');
}
