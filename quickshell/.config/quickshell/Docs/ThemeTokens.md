Theme Color Tokens and Derivations

Overview
See also: Docs/RichText.md for helpers used to color separators, brackets, and time spans in rich text labels (Media, NetworkUsage, WsIndicator).
- Base palette (user-configurable in Theme.json):
  - background
  - surface/surfaceVariant
  - textPrimary/Secondary/Disabled
  - accentPrimary, onAccent
  - outline, shadow
  - error, warning, highlight

- Derived tokens (computed in Settings/Theme.qml):
  - accentHover: lighter accent for hover states
  - accentActive: darker accent for active/pressed states
  - accentDarkStrong: strong darkened accent (used for “dark accent” UIs)
  - surfaceHover: subtle overlay for hover on surfaces
  - surfaceActive: slightly stronger overlay for pressed states
  - borderSubtle: low-emphasis border color
  - borderStrong: higher-emphasis border color
  - overlayWeak/overlayStrong: backdrop overlays

Additional UI tokens (nested)
- Tooltip: tooltip.opacity, tooltip.smallScaleRatio
- UI shadow: ui.shadow.opacity, ui.shadow.blur, ui.shadow.offsetX, ui.shadow.offsetY
- UI border/separators: ui.border.width, ui.separator.thickness
  - Separator radius: ui.separator.radius
  - Separator opacity: ui.separator.opacity
  - UI animation: ui.anim.quickMs, ui.anim.rotateMs, ui.anim.rippleMs
  - UI easing: ui.anim.easing.quick|rotate|ripple|stdOut|stdIn|inOut (string names like "OutCubic")
  - UI spinner: ui.spinner.durationMs
  - UI opacities: ui.ripple.opacity, ui.icon.emphasisOpacity
 - Media: media.iconScaleEmphasis
  - MPD flags polling: media.mpd.flags.fallbackMs
  - Album art fallback opacity: media.albumArt.fallbackOpacity
 - System tray: panel.tray.inlinePadding (px)
  - Menu: panel.menu.itemFontScale (font size multiplier)
 - Bar layout: panel.netCluster.spacing (spacing between VPN and Network)
 - Side panel button visibility guard: sidePanel.button.activeVisibleMin; UI epsilon: ui.visibilityEpsilon
 - Network icon: network.icon.scale, network.icon.vAdjust
 - Volume:
  - panel.volume.lowColor, panel.volume.highColor
  - panel.volume.fullHideMs (hide at exactly 100%)
  - Uses generic pill timings: panel.pill.showDelayMs, panel.pill.autoHidePauseMs
  - Optional override: volume.pill.autoHidePauseMs (Volume-only)
  - Optional override: volume.pill.showDelayMs (Volume-only)
  - Icon thresholds: volume.icon.offThreshold (default 0), volume.icon.downThreshold (default 30)
  - Optional upper threshold for hysteresis: volume.icon.upThreshold (default 50)
 - Time/Clock:
   - time.font.scale (multiplier for Theme.fontSizeSmall)
   - time.font.weight (Qt Font weight enum/int)
   - time.text.color
 - Keyboard:
   - keyboard.height (defaults to panel.height)
   - keyboard.minWidth
   - keyboard.margin
   - keyboard.icon.scale, keyboard.icon.spacing, keyboard.icon.padding
   - keyboard.text.padding
   - keyboard.icon.baselineOffset, keyboard.text.baselineOffset
   - keyboard.font.scale (icon font factor vs. label)
   - keyboard.colors.bg, keyboard.colors.hoverBg, keyboard.colors.text, keyboard.colors.icon
   - keyboard.radius (defaults to shape.cornerRadiusSmall)
   - keyboard.opacity.normal, keyboard.opacity.hover
   - keyboard.text.bold (boolean)
 - Workspace indicator: ws.icon.baselineOffset, ws.icon.spacing
   - ws.label.padding, ws.label.leftPadding.normal, ws.label.leftPadding.terminal
   - ws.icon.innerPadding
  - Submap baseline: ws.submap.icon.baselineOffset
  - Submap icon color: ws.submap.icon.color
- Applauncher: applauncher.size.width/height, applauncher.cornerRadius, applauncher.margins.bottom, applauncher.anim.enterMs/scaleMs/offscreenShift, applauncher.clipboardPollMs
  - Applauncher list: applauncher.list.itemHeight, applauncher.list.itemHeightLarge
  - Applauncher preview: applauncher.preview.width
  - Applauncher layout: applauncher.content.margin, applauncher.preview.innerMargin, applauncher.preview.maxHeightRatio
  - Menu item radius: panel.menu.itemRadius
  - Spectrum: spectrum.peakThickness
  - Side panel: sidePanel.innerRadius (inner blocks)
  - Side panel button hover radius factor: sidePanel.buttonHoverRadiusFactor
  - Side panel selector: sidePanel.selector.minWidth
  - Side panel popup spacing: sidePanel.popup.spacing
  - Weather left column width ratio: sidePanel.weather.leftColumnRatio
  - Weather header scale: weather.headerScale
  - Weather card opacity: weather.card.opacity
  - Weather center offset: weather.centerOffset
- Calendar font sizes: calendar.font.titlePx, calendar.font.dowPx, calendar.font.dayPx
  - Calendar DOW style: calendar.dow.italic, calendar.dow.underline
  - Calendar shape: calendar.cell.radiusFactor, calendar.holidayDot.radiusFactor
  - Calendar layout: calendar.dow.spacing, calendar.dow.sideMargin, calendar.grid.spacing
 - Spectrum bars: spectrum.barGap, spectrum.minBarWidth
  - Spectrum opacities: spectrum.fillOpacity, spectrum.peakOpacity
  - Separator stripe (generic): ui.separator.stripe.opacity, ui.separator.stripe.brightness, ui.separator.stripe.ratio
  - Diagonal separator implicit size: ui.separator.diagonal.implicitWidth, ui.separator.diagonal.implicitHeight
  - VPN opacities: vpn.connectedOpacity, vpn.disconnectedOpacity
  - VPN icon/layout: vpn.icon.scale, vpn.icon.vAdjust, vpn.icon.spacing; vpn.text.padding
  - VPN accent tuning: vpn.accent.saturateBoost, vpn.accent.lightenTowardWhite; vpn.desaturateAmount
  - Calendar opacities: calendar.opacity.title, calendar.opacity.dow, calendar.opacity.otherMonthDay

Overrides (advanced)
- You can override any derived token by adding an "Override" key in Theme.json:
  - accentHoverOverride, accentActiveOverride, accentDarkStrongOverride
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
- Text on dynamic backgrounds: Theme.textOn(bg[, preferLight, preferDark, threshold])
- Avoid hardcoded Qt.rgba mixes for state colors; use derived tokens or Color helpers.
  - For CSS strings use Helpers/Format.colorCss(color, alpha?) instead of manual rgba() building.

Accessibility
- Settings.settings.contrastThreshold controls light/dark flip in contrastOn.
- Optional debug: Settings.settings.debugContrast + Settings.settings.contrastWarnRatio to log when contrast is low (components may opt-in).

Examples
- Menu item hover: Theme.surfaceHover
- Selected day (calendar): Theme.accentDarkStrong background + Theme.accentPrimary border
- Media separators: bracket = Theme.accentDarkStrong; separator = Theme.accentHover
Debugging
- Strict token warnings: set `Settings.settings.strictThemeTokens` to true to log a warning whenever a Theme token is missing and a fallback is used. Helps ensure themes define all tokens you rely on.

Tools
- Validation: `node Tools/validate-theme.mjs [--theme Theme.json] [--schema Docs/ThemeHierarchical.json] [--strict]`
  - Reports unknown (extra) and missing tokens (missing is informational; `--strict` fails on unknown only).
- Generate example schema: `node Tools/generate-theme-schema.mjs`
  - Rebuilds `Docs/ThemeHierarchical.json` from the repository `Theme.json` (single source for docs), preventing drift.

Deprecations and Migration
- Deprecated (removed): media.time.fontScale — removed in Sep 2025 as time spans follow main text size. Remove from Theme.json; no replacement needed.
- Flat (legacy) tokens: compatibility remains until 2025-11-01. After this date, flat keys stop working. Migrate to hierarchical tokens in Theme.json.

Migration (flat → nested)
Flat keys were historically supported alongside nested tokens. They are deprecated and removed after 2025-11-01. Enable `Settings.settings.strictThemeTokens = true` to get console warnings when any flat key is detected.

Core mappings (examples):

- Colors: background → colors.background; surface → colors.surface; surfaceVariant → colors.surfaceVariant; textPrimary → colors.text.primary; textSecondary → colors.text.secondary; textDisabled → colors.text.disabled; accentPrimary → colors.accent.primary; error → colors.status.error; warning → colors.status.warning; highlight → colors.highlight; onAccent → colors.onAccent; outline → colors.outline; shadow → colors.shadow
- Panel: panelHeight → panel.height; panelSideMargin → panel.sideMargin; panelWidgetSpacing → panel.widgetSpacing; panelSepOvershoot → panel.sepOvershoot; panelModuleHeight → panel.moduleHeight; panelMenuYOffset → panel.menuYOffset
- Panel icons: panelIconSize → panel.icons.iconSize; panelIconSizeSmall → panel.icons.iconSizeSmall
- Hotzone: panelHotzoneWidth → panel.hotzone.width; panelHotzoneHeight → panel.hotzone.height; panelHotzoneRightShift → panel.hotzone.rightShift
- Shape: cornerRadius → shape.cornerRadius; cornerRadiusSmall → shape.cornerRadiusSmall; cornerRadiusLarge → shape.cornerRadiusLarge
- Tooltip: tooltipDelayMs → tooltip.delayMs; tooltipMinSize → tooltip.minSize; tooltipMargin → tooltip.margin; tooltipPadding → tooltip.padding; tooltipBorderWidth → tooltip.borderWidth; tooltipRadius → tooltip.radius; tooltipFontPx → tooltip.fontPx
- Pill: panelPillHeight → panel.pill.height; panelPillIconSize → panel.pill.iconSize; panelPillPaddingH → panel.pill.paddingH; panelPillShowDelayMs → panel.pill.showDelayMs; panelPillAutoHidePauseMs → panel.pill.autoHidePauseMs; panelPillBackground → panel.pill.background
- Animations: panelAnimStdMs → panel.animations.stdMs; panelAnimFastMs → panel.animations.fastMs
- Tray: panelTrayLongHoldMs → panel.tray.longHoldMs; panelTrayShortHoldMs → panel.tray.shortHoldMs; panelTrayGuardMs → panel.tray.guardMs; panelTrayOverlayDismissDelayMs → panel.tray.overlayDismissDelayMs
- Spacing/rows: panelRowSpacing → panel.rowSpacing; panelRowSpacingSmall → panel.rowSpacingSmall
- Volume: panelVolumeFullHideMs → panel.volume.fullHideMs; panelVolumeLowColor → panel.volume.lowColor; panelVolumeHighColor → panel.volume.highColor
- Timers: timeTickMs → timers.timeTickMs; wsRefreshDebounceMs → timers.wsRefreshDebounceMs
- Network: vpnPollMs → network.vpnPollMs; networkRestartBackoffMs → network.restartBackoffMs; networkLinkPollMs → network.linkPollMs
- Media hover: mediaHoverOpenDelayMs → media.hover.openDelayMs; mediaHoverStillThresholdMs → media.hover.stillThresholdMs
- Spectrum: spectrumPeakDecayIntervalMs → spectrum.peakDecayIntervalMs; spectrumBarAnimMs → spectrum.barAnimMs

Notes
- The nested schema is authoritative going forward. New tokens are added only in nested form.
- If you maintain custom themes, migrate now to avoid breakage after 2025-11-01.
- For colors.* derived tokens (accentHover, borderSubtle, etc.), prefer nested override keys under `colors.overrides.*` if you must override formulas.
