Theme Color Tokens and Derivations

Overview
- Base palette (user-configurable in Theme.json):
  - backgroundPrimary/Secondary/Tertiary
  - surface/surfaceVariant
  - textPrimary/Secondary/Disabled
  - accentPrimary/Secondary/Tertiary, onAccent
  - outline, shadow, overlay
  - error, warning, highlight, rippleEffect

- Derived tokens (computed in Settings/Theme.qml):
  - accentHover: lighter accent for hover states
  - accentActive: darker accent for active/pressed states
  - accentDisabled: accent with alpha for disabled states
  - accentDarkStrong: strong darkened accent (used for “dark accent” UIs)
  - surfaceHover: subtle overlay for hover on surfaces
  - surfaceActive: slightly stronger overlay for pressed states
  - borderSubtle: low-emphasis border color
  - borderStrong: higher-emphasis border color
  - overlayWeak/overlayStrong: backdrop overlays

Overrides (advanced)
- You can override any derived token by adding an "Override" key in Theme.json:
  - accentHoverOverride, accentActiveOverride, accentDisabledOverride, accentDarkStrongOverride
  - surfaceHoverOverride, surfaceActiveOverride
  - borderSubtleOverride, borderStrongOverride
  - overlayWeakOverride, overlayStrongOverride
- If an override is present, it wins; otherwise the token is computed by formula.
- Keep Theme.json minimal; only add overrides if you truly need to diverge.

Helper APIs (Helpers/Color.js)
- contrastOn(bg, light, dark, threshold): choose a readable text color based on bg luminance.
- withAlpha(color, a): return color with alpha (0..1).
- mix(a, b, t): blend two colors.
- towardsBlack(color, t) / towardsWhite(color, t): perceptual darken/lighten.
- contrastRatio(a, b): WCAG relative contrast ratio.

Guidance
- Prefer Theme tokens over literals. Use base tokens for backgrounds; derived tokens for states:
  - Hover backgrounds: Theme.surfaceHover
  - Pressed/active: Theme.surfaceActive
  - Accent hover/active: Theme.accentHover / Theme.accentActive
  - Borders: Theme.borderSubtle / Theme.borderStrong
  - Dark accent tint blocks: Theme.accentDarkStrong
- Text on dynamic backgrounds: Color.contrastOn(bg, Theme.textPrimary, Theme.textSecondary, Settings.settings.contrastThreshold)
- Avoid hardcoded Qt.rgba mixes for state colors; use derived tokens or Color helpers.

Accessibility
- Settings.settings.contrastThreshold controls light/dark flip in contrastOn.
- Optional debug: Settings.settings.debugContrast + Settings.settings.contrastWarnRatio to log when contrast is low (components may opt-in).

Examples
- Menu item hover: Theme.surfaceHover
- Selected day (calendar): Theme.accentDarkStrong background + Theme.accentPrimary border
- Media separators: bracket = Theme.accentDarkStrong; separator = Theme.accentHover

