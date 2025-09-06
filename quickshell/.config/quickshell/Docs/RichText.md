Rich Text Helpers

Purpose
- Centralize small utilities for building QML `Text.RichText` strings.

Module
- File: `Helpers/RichText.js`
- Import from QML: `import "../../Helpers/RichText.js" as Rich`
- Include from JS: `Qt.include("./RichText.js"); // exposes RichRT`

API
- esc(s): HTML-escapes a string.
- sepSpan(colorCss, ch, bold?): Colored separator span. `bold` optional.
- bracketPair(style): Returns `{ l, r }` for styles: round, square, lenticular, lenticular_black, angle, tortoise.
- bracketSpan(colorCss, ch): Colored span for bracket glyphs.
- timeSpan(colorCss, text): Inline time span with vertical alignment.
- colorSpan(colorCss, text): Generic colored span wrapper.

Notes
- Prefer these helpers over ad-hoc `<span>` construction.
- `Helpers/Format.js::sepSpan` forwards to `RichText.sepSpan` for compatibility.
