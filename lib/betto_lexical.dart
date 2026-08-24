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
library;

export 'package:betto_icu/betto_icu.dart'
    show
        Tokenizer,
        OffsetTokenizer,
        TokenSpan,
        RegExpTokenizer,
        IcuTokenizer,
        BrowserTokenizer;

export 'src/default_tokenizer_native.dart'
    if (dart.library.js_interop) 'src/default_tokenizer_web.dart'
    show createDefaultTokenizer;
export 'src/stemmer.dart' show Stemmer;
export 'src/stopwords.dart' show getStopWords, Stopwords;
