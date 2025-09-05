// Theme.qml
pragma Singleton
import QtQuick
import "../Helpers/Utils.js" as Utils
import "../Helpers/Color.js" as Color
import Quickshell
import Quickshell.Io
import qs.Settings

Singleton {
    id: root
    // Set true after Theme.json is loaded/applied at least once
    property bool _themeLoaded: false
    // Per-monitor UI scaling (defaults to 1.0)
    function scale(currentScreen) {
        try {
            const overrides = Settings.settings.monitorScaleOverrides || {};
            if (currentScreen && currentScreen.name && overrides[currentScreen.name] !== undefined) {
                return overrides[currentScreen.name];
            }
        } catch (e) { /* ignore */ }
        return 1.0;
    }

    function applyOpacity(color, opacity) {
        try {
            const c = String(color);
            const op = String(opacity);

            // Validate opacity as 2-digit hex
            if (!/^[0-9a-fA-F]{2}$/.test(op)) {
                return c; // fallback: leave as-is
            }

            // Accept only #RRGGBB or #AARRGGBB; otherwise fallback
            if (/^#[0-9a-fA-F]{6}$/.test(c)) {
                // Insert alpha prefix to make #AARRGGBB
                return "#" + op + c.slice(1);
            }
            if (/^#[0-9a-fA-F]{8}$/.test(c)) {
                // Replace existing leading alpha (assumes #AARRGGBB)
                return "#" + op + c.slice(3);
            }

            // Fallback: return original color unchanged
            return c;
        } catch (e) {
            return color; // conservative fallback
        }
    }
    
    // FileView to load theme data from JSON file
    FileView {
        id: themeFile
        path: Settings.themeFile
        watchChanges: true
        onFileChanged: reload()
        // After adapter updates (file written/loaded), write and check deprecated tokens
        onAdapterUpdated: {
            writeAdapter();
            try { root._checkDeprecatedTokens(); } catch (e) {}
            root._themeLoaded = true
        }
        onLoadFailed: function(error) {
            if (error.toString().includes("No such file") || error === 2) {
                writeAdapter() // File doesn't exist, create it with default values
            }
        }
        JsonAdapter {
            id: themeData
            // Defaults aligned with Theme.json; file values override these
            // Declare nested group roots so nested tokens in Theme.json are readable
            property var colors: ({})
            property var panel: ({})
            property var shape: ({})
            property var tooltip: ({})
            property var weather: ({})
            property var sidePanel: ({})
            property var ui: ({})
            property var ws: ({})
            property var timers: ({})
            property var network: ({})
            property var media: ({})
            property var spectrum: ({})
            property var time: ({})
            property var calendar: ({})
            property var vpn: ({})
            property var volume: ({})
            property var applauncher: ({})
            property var keyboard: ({})

            // Backgrounds
            property string background:  "#ef000000"
            // Surfaces & Elevation
            property string surface:        "#181C25"
            property string surfaceVariant: "#242A35"
            // Text Colors
            property string textPrimary:   "#CBD6E5"
            property string textSecondary: "#AEB9C8"
            property string textDisabled:  "#6B718A"
            // Accent Colors
            property string accentPrimary:   "#006FCC"
            // Error/Warning
            property string error:   "#FF6B81"
            property string warning: "#FFBB66"
            // Highlights & Focus
            property string highlight:    "#94E1F9"
            // Additional Theme Properties
            property string onAccent: "#FFFFFF"
            property string outline:  "#3B4C5C"
            // Shadows & Overlays
            property string shadow:  "#000000"
            

            // Panel metrics (logical px; scaled per-screen via Theme.scale(screen))
            property int panelHeight: 28
            property int panelSideMargin: 18
            property int panelWidgetSpacing: 12
            // Separator overshoot is typically unscaled to preserve look
            property int panelSepOvershoot: 60

            // Panel icon sizing (logical)
            property int panelIconSize: 24          // typical icon/button size in bar
            property int panelIconSizeSmall: 16     // small icon or inner icon

            // Panel hover hot-zone (logical)
            property int panelHotzoneWidth: 16
            property int panelHotzoneHeight: 9
            // Factor to compute right shift of hotzone relative to its width
            property real panelHotzoneRightShift: 1.15

            // Typical bar module preferred height (logical)
            property int panelModuleHeight: 36
            // Generic menu Y offset from anchor (logical)
            property int panelMenuYOffset: 20

            // Corners
            property int cornerRadius: 8
            property int cornerRadiusSmall: 4

            // Tooltip
            property int tooltipDelayMs: 1500
            property int tooltipMinSize: 20
            property int tooltipMargin: 12
            property int tooltipPadding: 8
            property int tooltipBorderWidth: 1
            property int tooltipRadius: 2
            property int tooltipFontPx: 14

            // Pill indicator defaults
            property int panelPillHeight: 22
            property int panelPillIconSize: 22
            property int panelPillPaddingH: 14
            property int panelPillShowDelayMs: 500
            property int panelPillAutoHidePauseMs: 2500
            // Pill background (used by modules like Volume)
            property string panelPillBackground: "#000000"

            // Animation timings
            property int panelAnimStdMs: 250
            property int panelAnimFastMs: 200

            // Tray behavior timings (ms)
            property int panelTrayLongHoldMs: 2500
            property int panelTrayShortHoldMs: 1500
            property int panelTrayGuardMs: 120
            property int panelTrayOverlayDismissDelayMs: 5000

            // Generic row spacing in bar context (logical)
            property int panelRowSpacing: 8
            property int panelRowSpacingSmall: 4

            // Volume module behavior (ms)
            property int panelVolumeFullHideMs: 800
            // Volume gradient endpoint colors
            property string panelVolumeLowColor:  "#D62E6E"  // raspberry
            property string panelVolumeHighColor: "#0E6B4D"  // spruce green

            // Core module timings (ms)
            property int timeTickMs: 1000
            property int wsRefreshDebounceMs: 120
            property int applauncherClipboardPollMs: 1000
            property int musicPositionPollMs: 1000
            property int musicPlayersPollMs: 5000
            property int musicMetaRecalcDebounceMs: 80
            property int vpnPollMs: 2500
            property int networkRestartBackoffMs: 1500
            property int networkLinkPollMs: 4000
            property int mediaHoverOpenDelayMs: 320
            property int mediaHoverStillThresholdMs: 180
            // Spectrum animations
            property int spectrumPeakDecayIntervalMs: 50
            property int spectrumBarAnimMs: 100

            // Calendar metrics
            property int calendarRowSpacing: 2
            property int calendarCellSpacing: 2
            property int calendarSideMargin: 2

            // Side-panel popup timings/margins (MusicPopup)
            property int  sidePanelPopupSlideMs: 220
            property int  sidePanelPopupAutoHideMs: 4000
            property int  sidePanelPopupOuterMargin: 4

            // Side-panel spacing medium (in addition to small/tight)
            property int  sidePanelSpacingMedium: 8

            // Hover behavior (timing only)
            property int  panelHoverFadeMs: 120

            // Tray/Panel menu metrics
            property int  panelMenuWidth: 180
            property int  panelSubmenuWidth: 180
            property int  panelMenuPadding: 4
            property int  panelMenuItemSpacing: 2
            property int  panelMenuItemHeight: 26
            property int  panelMenuSeparatorHeight: 6
            property int  panelMenuDividerMargin: 10
            property int  panelMenuRadius: 0
            property int  panelMenuHeightExtra: 12
            property int  panelMenuAnchorYOffset: 4
            property int  panelSubmenuGap: 12
            property int  panelMenuChevronSize: 15
            property int  panelMenuIconSize: 16

            // Side panel defaults (logical)
            property int  sidePanelCornerRadius: 9
            property int  sidePanelSpacing: 12
            property int  sidePanelSpacingTight: 6
            property int  sidePanelSpacingSmall: 4
            property int  sidePanelAlbumArtSize: 200
            property int  sidePanelWeatherWidth: 440
            property int  sidePanelWeatherHeight: 180
            property int  uiIconSizeLarge: 28

            // Overlay panels
            property int  panelOverlayRadius: 20
            property int  cornerRadiusLarge: 12

            // Generic UI spacings/margins (logical)
            property int  uiMarginLarge: 32
            property int  uiMarginMedium: 16
            property int  uiPaddingMedium: 14
            property int  uiSpacingLarge: 18
            property int  uiSpacingSmall: 10
            property int  uiSpacingXSmall: 2
            property int  uiGapTiny: 1
            property int  uiControlHeight: 48

            // Calendar popup sizing
            property int  calendarWidth: 280
            property int  calendarHeight: 320
            property int  calendarPopupMargin: 2
            property int  calendarBorderWidth: 1
            property int  calendarCellSize: 28
            property int  calendarHolidayDotSize: 3
            // Calendar highlight darken factor (0..1)
            property real calendarAccentDarken: 0.8
        }
        
    }

    // --- Nested reader helpers (support hierarchical Theme.json with backward-compat) ---
    // Internal cache of tokens we've already warned about (strict mode)
    property var _strictWarned: ({})

    function _getNested(path) {
        try {
            var obj = themeData; var parts = String(path).split('.');
            for (var i=0;i<parts.length;i++) {
                if (!obj) return undefined;
                var k = parts[i];
                obj = obj[k];
            }
            return obj;
        } catch (e) { return undefined }
    }
    function val(path, fallback) {
        var v = _getNested(path);
        if (v !== undefined && v !== null) return v;
        // Strict mode: warn once per missing token, but be quiet for known legacy-compatible paths
        try {
            if (Settings.settings && Settings.settings.strictThemeTokens) {
                var key = String(path);
                // During startup before Theme.json is loaded, do not warn yet
                if (!root._themeLoaded) return fallback;
                // Optional override keys: do not warn when absent
                if (!/^colors\.overrides\./.test(key)) {
                    // Legacy flat-compat mapping: if a corresponding flat key exists, suppress warning
                    var compat = ({
                        'colors.background': 'background',
                        'colors.surface': 'surface',
                        'colors.surfaceVariant': 'surfaceVariant',
                        'colors.text.primary': 'textPrimary',
                        'colors.text.secondary': 'textSecondary',
                        'colors.text.disabled': 'textDisabled',
                        'colors.accent.primary': 'accentPrimary',
                        'colors.status.error': 'error',
                        'colors.status.warning': 'warning',
                        'colors.highlight': 'highlight',
                        'colors.onAccent': 'onAccent',
                        'colors.outline': 'outline',
                        'colors.shadow': 'shadow',
                        'panel.height': 'panelHeight',
                        'panel.sideMargin': 'panelSideMargin',
                        'panel.widgetSpacing': 'panelWidgetSpacing',
                        'panel.sepOvershoot': 'panelSepOvershoot',
                        'panel.icons.iconSize': 'panelIconSize',
                        'panel.icons.iconSizeSmall': 'panelIconSizeSmall',
                        'panel.hotzone.width': 'panelHotzoneWidth',
                        'panel.hotzone.height': 'panelHotzoneHeight',
                        'panel.hotzone.rightShift': 'panelHotzoneRightShift',
                        'panel.moduleHeight': 'panelModuleHeight',
                        'panel.menuYOffset': 'panelMenuYOffset',
                        'shape.cornerRadius': 'cornerRadius',
                        'shape.cornerRadiusSmall': 'cornerRadiusSmall',
                        'shape.cornerRadiusLarge': 'cornerRadiusLarge',
                        'tooltip.delayMs': 'tooltipDelayMs',
                        'tooltip.minSize': 'tooltipMinSize',
                        'tooltip.margin': 'tooltipMargin',
                        'tooltip.padding': 'tooltipPadding',
                        'tooltip.borderWidth': 'tooltipBorderWidth',
                        'tooltip.radius': 'tooltipRadius',
                        'tooltip.fontPx': 'tooltipFontPx',
                        'panel.pill.height': 'panelPillHeight',
                        'panel.pill.iconSize': 'panelPillIconSize',
                        'panel.pill.paddingH': 'panelPillPaddingH',
                        'panel.pill.showDelayMs': 'panelPillShowDelayMs',
                        'panel.pill.autoHidePauseMs': 'panelPillAutoHidePauseMs',
                        'panel.pill.background': 'panelPillBackground',
                        'panel.animations.stdMs': 'panelAnimStdMs',
                        'panel.animations.fastMs': 'panelAnimFastMs',
                        'panel.tray.longHoldMs': 'panelTrayLongHoldMs',
                        'panel.tray.shortHoldMs': 'panelTrayShortHoldMs',
                        'panel.tray.guardMs': 'panelTrayGuardMs',
                        'panel.tray.overlayDismissDelayMs': 'panelTrayOverlayDismissDelayMs',
                        'panel.rowSpacing': 'panelRowSpacing',
                        'panel.rowSpacingSmall': 'panelRowSpacingSmall',
                        'panel.volume.fullHideMs': 'panelVolumeFullHideMs',
                        'panel.volume.lowColor': 'panelVolumeLowColor',
                        'panel.volume.highColor': 'panelVolumeHighColor',
                        'timers.timeTickMs': 'timeTickMs',
                        'timers.wsRefreshDebounceMs': 'wsRefreshDebounceMs',
                        'network.vpnPollMs': 'vpnPollMs',
                        'network.restartBackoffMs': 'networkRestartBackoffMs',
                        'network.linkPollMs': 'networkLinkPollMs',
                        'media.hover.openDelayMs': 'mediaHoverOpenDelayMs',
                        'media.hover.stillThresholdMs': 'mediaHoverStillThresholdMs',
                        'spectrum.peakDecayIntervalMs': 'spectrumPeakDecayIntervalMs',
                        'spectrum.barAnimMs': 'spectrumBarAnimMs',
                        'calendar.rowSpacing': 'calendarRowSpacing',
                        'calendar.cellSpacing': 'calendarCellSpacing',
                        'calendar.sideMargin': 'calendarSideMargin',
                        'panel.hover.fadeMs': 'panelHoverFadeMs',
                        'panel.menu.width': 'panelMenuWidth',
                        'panel.menu.submenuWidth': 'panelSubmenuWidth',
                        'panel.menu.padding': 'panelMenuPadding',
                        'panel.menu.itemSpacing': 'panelMenuItemSpacing',
                        'panel.menu.itemHeight': 'panelMenuItemHeight',
                        'panel.menu.separatorHeight': 'panelMenuSeparatorHeight',
                        'panel.menu.dividerMargin': 'panelMenuDividerMargin',
                        'panel.menu.radius': 'panelMenuRadius',
                        'panel.menu.heightExtra': 'panelMenuHeightExtra',
                        'panel.menu.anchorYOffset': 'panelMenuAnchorYOffset',
                        'panel.menu.submenuGap': 'panelSubmenuGap',
                        'panel.menu.chevronSize': 'panelMenuChevronSize',
                        'panel.menu.iconSize': 'panelMenuIconSize'
                    })[key];
                    var hasCompat = compat && (themeData[compat] !== undefined);
                    if (!hasCompat) {
                        if (!root._strictWarned[key]) {
                            console.warn('[ThemeStrict] Missing token', key, '→ using fallback', fallback);
                            root._strictWarned[key] = true;
                        }
                    }
                }
            }
        } catch (e) { /* ignore */ }
        return fallback;
    }

    // --- Deprecated/unused token warnings ---
    function _checkDeprecatedTokens() {
        try {
            if (!(Settings.settings && Settings.settings.strictThemeTokens)) return;
            var deprecated = [
                { path: 'rippleEffect', note: 'Use ui.ripple.opacity' },
                { path: 'accentDisabled', note: 'Use colors.text.disabled / Theme.textDisabled' },
                { path: 'panelHoverOpacity', note: 'Use surfaceHover/surfaceActive for states' },
                { path: 'overlay', note: 'Use colors.overrides.overlayWeak/overlayStrong or derived tokens' },
                { path: 'baseOverlay', note: 'Use colors.overrides.overlayWeak/overlayStrong' }
            ];
            for (var i=0;i<deprecated.length;i++) {
                var d = deprecated[i];
                var v = _getNested(d.path);
                if (v !== undefined && v !== null) {
                    var key = 'dep::' + d.path;
                    if (!root._strictWarned[key]) {
                        console.warn('[ThemeStrict] Deprecated token', d.path, 'present; ' + d.note);
                        root._strictWarned[key] = true;
                    }
                }
            }
        } catch (e) { /* ignore */ }
    }

    // Initial deprecated check
    Component.onCompleted: {
        try { root._checkDeprecatedTokens(); } catch (e) {}
    }

        // Map string or numeric to a QML Easing.Type
        function easingType(nameOrCode, fallbackName) {
            try {
                var map = {
                    Linear: Easing.Linear,
                    InQuad: Easing.InQuad,
                    OutQuad: Easing.OutQuad,
                    InOutQuad: Easing.InOutQuad,
                    InCubic: Easing.InCubic,
                    OutCubic: Easing.OutCubic,
                    InOutCubic: Easing.InOutCubic,
                    InSine: Easing.InSine,
                    OutSine: Easing.OutSine,
                    InOutSine: Easing.InOutSine,
                    InBack: Easing.InBack,
                    OutBack: Easing.OutBack,
                    InOutBack: Easing.InOutBack
                };
                if (typeof nameOrCode === 'number') return nameOrCode;
                var s = String(nameOrCode || '');
                if (map[s] !== undefined) return map[s];
                var fb = String(fallbackName || 'OutCubic');
                return map[fb] !== undefined ? map[fb] : Easing.OutCubic;
            } catch (e) {
                return Easing.OutCubic;
            }
        }
    
    // Backgrounds
    property color background: val('colors.background', themeData.background)
    // Surfaces & Elevation
    property color surface: val('colors.surface', themeData.surface)
    property color surfaceVariant: val('colors.surfaceVariant', themeData.surfaceVariant)
    // Text Colors
    property color textPrimary: val('colors.text.primary', themeData.textPrimary)
    property color textSecondary: val('colors.text.secondary', themeData.textSecondary)
    property color textDisabled: val('colors.text.disabled', themeData.textDisabled)
    // Accent Colors
    property color accentPrimary: val('colors.accent.primary', themeData.accentPrimary)
    // Error/Warning
    property color error: val('colors.status.error', themeData.error)
    property color warning: val('colors.status.warning', themeData.warning)
    // Highlights & Focus
    property color highlight: val('colors.highlight', themeData.highlight)
    
    // Additional Theme Properties
    property color onAccent: val('colors.onAccent', themeData.onAccent)
    property color outline: val('colors.outline', themeData.outline)
    // Shadows & Overlays
    property color shadow: applyOpacity(val('colors.shadow', themeData.shadow), "B3")
    
    property string fontFamily: "Iosevka" // Font Properties
    // Font size multiplier - adjust this in Settings.json to scale all fonts
    property real fontSizeMultiplier: Settings.settings.fontSizeMultiplier || 1.0
    // Global contrast threshold used by Color.contrastOn callers
    property real contrastThreshold: (Settings.settings && Settings.settings.contrastThreshold !== undefined)
        ? Settings.settings.contrastThreshold : 0.5
    // Base font sizes (multiplied by fontSizeMultiplier)
    property int fontSizeHeader: Math.round(32 * fontSizeMultiplier)     // Headers and titles
    property int fontSizeBody: Math.round(16 * fontSizeMultiplier)       // Body text and general content
    property int fontSizeSmall: Math.round(14 * fontSizeMultiplier)      // Small text like clock, labels
    property int fontSizeCaption: Math.round(12 * fontSizeMultiplier)    // Captions and fine print

    // Panel metrics (logical)
    property int panelHeight: Utils.clamp(val('panel.height', themeData.panelHeight), 16, 64)
    property int panelSideMargin: val('panel.sideMargin', themeData.panelSideMargin)
    property int panelWidgetSpacing: val('panel.widgetSpacing', themeData.panelWidgetSpacing)
    property int panelSepOvershoot: val('panel.sepOvershoot', themeData.panelSepOvershoot)
    // Panel icon sizing
    property int panelIconSize: val('panel.icons.iconSize', themeData.panelIconSize)
    property int panelIconSizeSmall: val('panel.icons.iconSizeSmall', themeData.panelIconSizeSmall)
    // Panel hot-zone
    property int panelHotzoneWidth: Utils.clamp(val('panel.hotzone.width', themeData.panelHotzoneWidth), 4, 64)
    property int panelHotzoneHeight: Utils.clamp(val('panel.hotzone.height', themeData.panelHotzoneHeight), 2, 64)
    property real panelHotzoneRightShift: Utils.clamp(val('panel.hotzone.rightShift', themeData.panelHotzoneRightShift), 0.5, 3.0)
    property int panelModuleHeight: val('panel.moduleHeight', themeData.panelModuleHeight)
    property int panelMenuYOffset: val('panel.menuYOffset', themeData.panelMenuYOffset)
    // Corners
    property int cornerRadius: val('shape.cornerRadius', themeData.cornerRadius)
    property int cornerRadiusSmall: val('shape.cornerRadiusSmall', themeData.cornerRadiusSmall)
    // Tooltip
    property int tooltipDelayMs: val('tooltip.delayMs', themeData.tooltipDelayMs)
    property int tooltipMinSize: val('tooltip.minSize', themeData.tooltipMinSize)
    property int tooltipMargin: val('tooltip.margin', themeData.tooltipMargin)
    property int tooltipPadding: val('tooltip.padding', themeData.tooltipPadding)
    property int tooltipBorderWidth: val('tooltip.borderWidth', themeData.tooltipBorderWidth)
    property int tooltipRadius: val('tooltip.radius', themeData.tooltipRadius)
    property int tooltipFontPx: val('tooltip.fontPx', themeData.tooltipFontPx)
    property real tooltipOpacity: val('tooltip.opacity', 0.98)
    property real tooltipSmallScaleRatio: val('tooltip.smallScaleRatio', 0.71)
    // Weather tokens
    // Header scale relative to Theme.fontSizeHeader
    property real weatherHeaderScale: Utils.clamp(val('weather.headerScale', 0.75), 0.25, 1.5)
    // Card background opacity atop accentDarkStrong
    property real weatherCardOpacity: Utils.clamp(val('weather.card.opacity', 0.85), 0, 1)
    // Optional horizontal center offset tweak
    property int  weatherCenterOffset: Utils.clamp(val('weather.centerOffset', -2), -100, 100)
    // Pill indicator defaults
    property int panelPillHeight: val('panel.pill.height', themeData.panelPillHeight)
    property int panelPillIconSize: val('panel.pill.iconSize', themeData.panelPillIconSize)
    property int panelPillPaddingH: val('panel.pill.paddingH', themeData.panelPillPaddingH)
    property int panelPillShowDelayMs: val('panel.pill.showDelayMs', themeData.panelPillShowDelayMs)
    property int panelPillAutoHidePauseMs: val('panel.pill.autoHidePauseMs', themeData.panelPillAutoHidePauseMs)
    property color panelPillBackground: val('panel.pill.background', themeData.panelPillBackground)
    // Animation timings
    property int panelAnimStdMs: Utils.clamp(val('panel.animations.stdMs', themeData.panelAnimStdMs), 0, 5000)
    property int panelAnimFastMs: Utils.clamp(val('panel.animations.fastMs', themeData.panelAnimFastMs), 0, 5000)
    // Tray behavior timings
    property int panelTrayLongHoldMs: Utils.clamp(val('panel.tray.longHoldMs', themeData.panelTrayLongHoldMs), 0, 10000)
    property int panelTrayShortHoldMs: Utils.clamp(val('panel.tray.shortHoldMs', themeData.panelTrayShortHoldMs), 0, 10000)
    property int panelTrayGuardMs: Utils.clamp(val('panel.tray.guardMs', themeData.panelTrayGuardMs), 0, 2000)
    property int panelTrayOverlayDismissDelayMs: Utils.clamp(val('panel.tray.overlayDismissDelayMs', themeData.panelTrayOverlayDismissDelayMs), 0, 600000)
    // Inline expanded tray background extra padding (unscaled px)
    property int panelTrayInlinePadding: val('panel.tray.inlinePadding', 6)
    // Generic row spacing
    property int panelRowSpacing: val('panel.rowSpacing', themeData.panelRowSpacing)
    property int panelRowSpacingSmall: val('panel.rowSpacingSmall', themeData.panelRowSpacingSmall)
    // Scale factor for computedFontPx used by small icon/text modules (e.g., network, vpn)
    property real panelComputedFontScale: Utils.clamp(val('panel.computedFontScale', 0.6), 0.1, 1.0)
    // Spacing between VPN + NetworkUsage in left cluster
    property int panelNetClusterSpacing: Utils.clamp(val('panel.netCluster.spacing', 6), 0, 64)
    // Volume behavior
    property int panelVolumeFullHideMs: val('panel.volume.fullHideMs', themeData.panelVolumeFullHideMs)
    property color panelVolumeLowColor: val('panel.volume.lowColor', themeData.panelVolumeLowColor)
    property color panelVolumeHighColor: val('panel.volume.highColor', themeData.panelVolumeHighColor)
    // Volume icon thresholds
    property int volumeIconOffThreshold: Utils.clamp(val('volume.icon.offThreshold', 0), 0, 100)
    property int volumeIconDownThreshold: Utils.clamp(val('volume.icon.downThreshold', 30), 0, 100)
    property int volumeIconUpThreshold: Utils.clamp(val('volume.icon.upThreshold', 50), 0, 100)
    // Volume-specific pill override (falls back to panel.pill.autoHidePauseMs)
    property int volumePillAutoHidePauseMs: Utils.clamp(val('volume.pill.autoHidePauseMs', panelPillAutoHidePauseMs), 0, 600000)
    // Volume-specific show delay override (falls back to panel.pill.showDelayMs)
    property int volumePillShowDelayMs: Utils.clamp(val('volume.pill.showDelayMs', panelPillShowDelayMs), 0, 600000)
    // Core module timings
    property int timeTickMs: Utils.clamp(val('timers.timeTickMs', themeData.timeTickMs), 100, 60000)
    property int wsRefreshDebounceMs: Utils.clamp(val('timers.wsRefreshDebounceMs', themeData.wsRefreshDebounceMs), 0, 10000)
    property int vpnPollMs: Utils.clamp(val('network.vpnPollMs', themeData.vpnPollMs), 500, 600000)
    property int networkRestartBackoffMs: Utils.clamp(val('network.restartBackoffMs', themeData.networkRestartBackoffMs), 0, 600000)
    property int networkLinkPollMs: Utils.clamp(val('network.linkPollMs', themeData.networkLinkPollMs), 500, 600000)
    property int mediaHoverOpenDelayMs: Utils.clamp(val('media.hover.openDelayMs', themeData.mediaHoverOpenDelayMs), 0, 5000)
    property int mediaHoverStillThresholdMs: Utils.clamp(val('media.hover.stillThresholdMs', themeData.mediaHoverStillThresholdMs), 0, 10000)
    // Media time text font scale (relative to track title font size)
    property real mediaTimeFontScale: Utils.clamp(val('media.time.fontScale', 0.8), 0.1, 2.0)
    property int spectrumPeakDecayIntervalMs: Utils.clamp(val('spectrum.peakDecayIntervalMs', themeData.spectrumPeakDecayIntervalMs), 10, 1000)
    property int spectrumBarAnimMs: Utils.clamp(val('spectrum.barAnimMs', themeData.spectrumBarAnimMs), 0, 5000)
    property int spectrumPeakThickness: Utils.clamp(val('spectrum.peakThickness', 2), 1, 12)
    property real spectrumBarGap: val('spectrum.barGap', 2)
    property real spectrumMinBarWidth: val('spectrum.minBarWidth', 2)
    property int musicPositionPollMs: Utils.clamp(val('timers.musicPositionPollMs', themeData.musicPositionPollMs), 100, 600000)
    property int musicPlayersPollMs: Utils.clamp(val('timers.musicPlayersPollMs', themeData.musicPlayersPollMs), 100, 600000)
    property int musicMetaRecalcDebounceMs: Utils.clamp(val('timers.musicMetaRecalcDebounceMs', themeData.musicMetaRecalcDebounceMs), 0, 10000)
    // Applauncher
    property int applauncherClipboardPollMs: Utils.clamp(val('applauncher.clipboardPollMs', themeData.applauncherClipboardPollMs), 100, 600000)
    // Applauncher UI/config (nested)
    property int applauncherWidth: val('applauncher.size.width', 460)
    property int applauncherHeight: val('applauncher.size.height', 640)
    property int applauncherCornerRadius: val('applauncher.cornerRadius', 28)
    property int applauncherBottomMargin: val('applauncher.margins.bottom', 16)
    property int applauncherOffscreenShift: val('applauncher.anim.offscreenShift', 12)
    property int applauncherEnterAnimMs: Utils.clamp(val('applauncher.anim.enterMs', 300), 0, 10000)
    property int applauncherScaleAnimMs: Utils.clamp(val('applauncher.anim.scaleMs', 200), 0, 10000)
    // Applauncher list item heights
    property int applauncherListItemHeight: Utils.clamp(val('applauncher.list.itemHeight', 48), 24, 256)
    property int applauncherListItemHeightLarge: Utils.clamp(val('applauncher.list.itemHeightLarge', 64), 24, 256)
    // Applauncher preview panel width
    property int applauncherPreviewWidth: Utils.clamp(val('applauncher.preview.width', 200), 100, 1000)
    // Applauncher content/preview margins and max height ratio
    property int applauncherContentMargin: Utils.clamp(val('applauncher.content.margin', themeData.uiMarginLarge), 0, 256)
    property int applauncherPreviewInnerMargin: Utils.clamp(val('applauncher.preview.innerMargin', themeData.uiMarginMedium), 0, 256)
    property real applauncherPreviewMaxHeightRatio: Utils.clamp(val('applauncher.preview.maxHeightRatio', 1.0), 0.1, 1.0)
    // Calendar metrics
    property int calendarRowSpacing: val('calendar.rowSpacing', themeData.calendarRowSpacing)
    property int calendarCellSpacing: val('calendar.cellSpacing', themeData.calendarCellSpacing)
    property int calendarSideMargin: val('calendar.sideMargin', themeData.calendarSideMargin)
    // Side-panel popup timings/margins
    property int  sidePanelPopupSlideMs: val('sidePanel.popup.slideMs', themeData.sidePanelPopupSlideMs)
    property int  sidePanelPopupAutoHideMs: val('sidePanel.popup.autoHideMs', themeData.sidePanelPopupAutoHideMs)
    property int  sidePanelPopupOuterMargin: val('sidePanel.popup.outerMargin', themeData.sidePanelPopupOuterMargin)
    // Side-panel popup spacing (between inner items)
    property int  sidePanelPopupSpacing: val('sidePanel.popup.spacing', 0)
    // Side-panel button hover rectangle visibility guard
    property real sidePanelButtonActiveVisibleMin: Utils.clamp(val('sidePanel.button.activeVisibleMin', 0.18), 0, 1)
    // Side-panel spacing medium
    property int  sidePanelSpacingMedium: val('sidePanel.spacingMedium', themeData.sidePanelSpacingMedium)
    // Hover behavior
    property int  panelHoverFadeMs: val('panel.hover.fadeMs', themeData.panelHoverFadeMs)
    // Panel menu metrics
    property int  panelMenuWidth: Utils.clamp(val('panel.menu.width', themeData.panelMenuWidth), 100, 600)
    property int  panelSubmenuWidth: val('panel.menu.submenuWidth', themeData.panelSubmenuWidth)
    property int  panelMenuPadding: Utils.clamp(val('panel.menu.padding', themeData.panelMenuPadding), 0, 32)
    property int  panelMenuItemSpacing: Utils.clamp(val('panel.menu.itemSpacing', themeData.panelMenuItemSpacing), 0, 16)
    property int  panelMenuItemHeight: Utils.clamp(val('panel.menu.itemHeight', themeData.panelMenuItemHeight), 16, 64)
    property int  panelMenuSeparatorHeight: Utils.clamp(val('panel.menu.separatorHeight', themeData.panelMenuSeparatorHeight), 1, 16)
    property int  panelMenuDividerMargin: Utils.clamp(val('panel.menu.dividerMargin', themeData.panelMenuDividerMargin), 0, 32)
    property int  panelMenuRadius: Utils.clamp(val('panel.menu.radius', themeData.panelMenuRadius), 0, 32)
    property int  panelMenuItemRadius: Utils.clamp(val('panel.menu.itemRadius', 0), 0, 32)
    property int  panelMenuHeightExtra: Utils.clamp(val('panel.menu.heightExtra', themeData.panelMenuHeightExtra), 0, 64)
    property int  panelMenuAnchorYOffset: Utils.clamp(val('panel.menu.anchorYOffset', themeData.panelMenuAnchorYOffset), -20, 100)
    property int  panelSubmenuGap: val('panel.menu.submenuGap', themeData.panelSubmenuGap)
    property int  panelMenuChevronSize: val('panel.menu.chevronSize', themeData.panelMenuChevronSize)
    property int  panelMenuIconSize: val('panel.menu.iconSize', themeData.panelMenuIconSize)
    // Panel menu item font scale (relative to Theme.fontSizeSmall)
    property real panelMenuItemFontScale: Utils.clamp(val('panel.menu.itemFontScale', 0.90), 0.5, 1.5)
    // Side panel exports
    property int sidePanelCornerRadius: val('sidePanel.cornerRadius', themeData.sidePanelCornerRadius)
    property int sidePanelSpacing: val('sidePanel.spacing', themeData.sidePanelSpacing)
    property int sidePanelSpacingTight: val('sidePanel.spacingTight', themeData.sidePanelSpacingTight)
    property int sidePanelSpacingSmall: val('sidePanel.spacingSmall', themeData.sidePanelSpacingSmall)
    property int sidePanelAlbumArtSize: val('sidePanel.albumArtSize', themeData.sidePanelAlbumArtSize)
    // Inner blocks radius for side panel cards/sections
    property int sidePanelInnerRadius: Utils.clamp(val('sidePanel.innerRadius', 0), 0, 32)
    // Hover background radius factor for side panel buttons (0..1 of height)
    property real sidePanelButtonHoverRadiusFactor: Utils.clamp(val('sidePanel.buttonHoverRadiusFactor', 0.5), 0, 1)
    // Side panel selector minimal width
    property int sidePanelSelectorMinWidth: Utils.clamp(val('sidePanel.selector.minWidth', 120), 40, 600)
    property int sidePanelWeatherWidth: val('sidePanel.weather.width', themeData.sidePanelWeatherWidth)
    property int sidePanelWeatherHeight: val('sidePanel.weather.height', themeData.sidePanelWeatherHeight)
    property real sidePanelWeatherLeftColumnRatio: Utils.clamp(val('sidePanel.weather.leftColumnRatio', 0.32), 0.1, 0.8)
    property int uiIconSizeLarge: val('ui.iconSizeLarge', themeData.uiIconSizeLarge)
    // Overlay radius and larger corner
    property int panelOverlayRadius: val('panel.overlayRadius', themeData.panelOverlayRadius)
    property int cornerRadiusLarge: val('shape.cornerRadiusLarge', themeData.cornerRadiusLarge)
    // Generic UI spacings/margins
    property int uiMarginLarge: Utils.clamp(val('ui.margin.large', themeData.uiMarginLarge), 0, 128)
    property int uiMarginMedium: Utils.clamp(val('ui.margin.medium', themeData.uiMarginMedium), 0, 64)
    property int uiPaddingMedium: Utils.clamp(val('ui.padding.medium', themeData.uiPaddingMedium), 0, 64)
    property int uiSpacingLarge: Utils.clamp(val('ui.spacing.large', themeData.uiSpacingLarge), 0, 64)
    property int uiSpacingSmall: Utils.clamp(val('ui.spacing.small', themeData.uiSpacingSmall), 0, 32)
    property int uiSpacingXSmall: Utils.clamp(val('ui.spacing.xsmall', themeData.uiSpacingXSmall), 0, 16)
    property int uiGapTiny: val('ui.gap.tiny', themeData.uiGapTiny)
    property int uiControlHeight: val('ui.control.height', themeData.uiControlHeight)
    // UI shadows (used by text overlays, etc.)
    property real uiShadowOpacity: val('ui.shadow.opacity', 0.6)
    property real uiShadowBlur: val('ui.shadow.blur', 0.8)
    property int uiShadowOffsetX: val('ui.shadow.offsetX', 0)
    property int uiShadowOffsetY: val('ui.shadow.offsetY', 1)
    // UI border/separator thickness
    property int uiBorderWidth: Utils.clamp(val('ui.border.width', 1), 0, 8)
    property int uiSeparatorThickness: Utils.clamp(val('ui.separator.thickness', 1), 1, 8)
    property int uiSeparatorRadius: Utils.clamp(val('ui.separator.radius', 0), 0, 8)
    // UI small-visibility epsilon for hover fades, etc.
    property real uiVisibilityEpsilon: Utils.clamp(val('ui.visibilityEpsilon', 0.01), 0, 0.5)
    // UI "none" tokens for consistency
    property int uiMarginNone: val('ui.margin.none', 0)
    property int uiSpacingNone: val('ui.spacing.none', 0)
    property int uiBorderNone: val('ui.border.noneWidth', 0)
    property int uiRadiusNone: val('ui.radius.none', 0)
    // Diagonal separator implicit size
    property int uiDiagonalSeparatorImplicitWidth: Utils.clamp(val('ui.separator.diagonal.implicitWidth', 10), 1, 512)
    property int uiDiagonalSeparatorImplicitHeight: Utils.clamp(val('ui.separator.diagonal.implicitHeight', 28), 1, 1024)
    // Diagonal separator tuning
    property real uiSeparatorDiagonalAlpha: Utils.clamp(val('ui.separator.diagonal.alpha', 0.05), 0, 1)
    property real uiSeparatorDiagonalThickness: Utils.clamp(val('ui.separator.diagonal.thickness', 7.0), 0.5, 64)
    property int  uiSeparatorDiagonalAngleDeg: Utils.clamp(val('ui.separator.diagonal.angleDeg', 30), 0, 90)
    property int  uiSeparatorDiagonalInset: Utils.clamp(val('ui.separator.diagonal.inset', 4), 0, 64)
    property real uiSeparatorDiagonalStripeBrightness: Utils.clamp(val('ui.separator.diagonal.stripeBrightness', 0.4), 0, 1)
    property real uiSeparatorDiagonalStripeRatio: Utils.clamp(val('ui.separator.diagonal.stripeRatio', 0.35), 0, 1)
    // UI common opacities
    property real uiRippleOpacity: Utils.clamp(val('ui.ripple.opacity', 0.18), 0, 1)
    property real uiIconEmphasisOpacity: Utils.clamp(val('ui.icon.emphasisOpacity', 0.9), 0, 1)
    // Workspace indicator tuning
    property int  wsIconBaselineOffset: val('ws.icon.baselineOffset', 4)
    property int  wsIconSpacing: val('ws.icon.spacing', 1)
    // Submap icon baseline vs. text
    property int  wsSubmapIconBaselineOffset: val('ws.submap.icon.baselineOffset', 0)
    // Color of the submap icon
    property color wsSubmapIconColor: val('ws.submap.icon.color', accentPrimary)
    // Workspace label/icon paddings
    property int  wsLabelPadding: Utils.clamp(val('ws.label.padding', 6), 0, 64)
    property int  wsLabelLeftPadding: Utils.clamp(val('ws.label.leftPadding.normal', 2), -32, 64)
    property int  wsLabelLeftPaddingTerminal: Utils.clamp(val('ws.label.leftPadding.terminal', -2), -64, 64)
    property int  wsIconInnerPadding: Utils.clamp(val('ws.icon.innerPadding', 1), 0, 32)
    // NetworkUsage icon tuning
    property real networkIconScale: Utils.clamp(val('network.icon.scale', 0.7), 0.2, 3.0)
    property int  networkIconVAdjust: Utils.clamp(val('network.icon.vAdjust', 0), -100, 100)
    // VPN indicator opacities
    property real vpnConnectedOpacity: Utils.clamp(val('vpn.connectedOpacity', 0.8), 0, 1)
    property real vpnDisconnectedOpacity: Utils.clamp(val('vpn.disconnectedOpacity', 0.45), 0, 1)
    // VPN icon/layout tuning and accent mix
    property real vpnIconScale: Utils.clamp(val('vpn.icon.scale', 1.0), 0.2, 3.0)
    property int  vpnIconVAdjust: Utils.clamp(val('vpn.icon.vAdjust', 0), -100, 100)
    property int  vpnIconSpacing: Utils.clamp(val('vpn.icon.spacing', panelRowSpacingSmall), 0, 64)
    property int  vpnTextPadding: Utils.clamp(val('vpn.text.padding', panelRowSpacingSmall), 0, 64)
    property real vpnAccentSaturateBoost: Utils.clamp(val('vpn.accent.saturateBoost', 0.12), 0, 1)
    property real vpnAccentLightenTowardWhite: Utils.clamp(val('vpn.accent.lightenTowardWhite', 0.20), 0, 1)
    property real vpnDesaturateAmount: Utils.clamp(val('vpn.desaturateAmount', 0.45), 0, 1)
    // UI animation timings
    property int uiAnimQuickMs: Utils.clamp(val('ui.anim.quickMs', 120), 0, 2000)
    property int uiAnimRotateMs: Utils.clamp(val('ui.anim.rotateMs', 160), 0, 5000)
    property int uiAnimRippleMs: Utils.clamp(val('ui.anim.rippleMs', 320), 0, 10000)
    // UI spinner
    property int uiSpinnerDurationMs: Utils.clamp(val('ui.spinner.durationMs', 1000), 100, 600000)
    // Media emphasis scaling for icons
    property real mediaIconScaleEmphasis: val('media.iconScaleEmphasis', 1.15)
    // MPD flags
    property real mpdFlagsIconScale: Utils.clamp(val('media.mpd.flags.iconScale', 0.95), 0.1, 2.0)
    // Media album art fallback icon opacity
    property real mediaAlbumArtFallbackOpacity: Utils.clamp(val('media.albumArt.fallbackOpacity', 0.4), 0, 1)
    // Media time alphas
    property real mediaTimeAlphaPlaying: Utils.clamp(val('media.time.alpha.playing', 1.0), 0, 1)
    property real mediaTimeAlphaPaused: Utils.clamp(val('media.time.alpha.paused', 0.8), 0, 1)
    // MPD flags polling (fallback interval)
    property int mpdFlagsFallbackMs: Utils.clamp(val('media.mpd.flags.fallbackMs', 2500), 200, 600000)
    // Time/Clock module
    property real timeFontScale: Utils.clamp(val('time.font.scale', 1.0), 0.5, 3.0)
    property int  timeFontWeight: val('time.font.weight', Font.Medium)
    property color timeTextColor: val('time.text.color', textPrimary)
    // Keyboard layout module
    property int  keyboardHeight: Utils.clamp(val('keyboard.height', themeData.panelHeight), 16, 128)
    property int  keyboardMargin: Utils.clamp(val('keyboard.margin', 4), 0, 64)
    property int  keyboardMinWidth: Utils.clamp(val('keyboard.minWidth', 40), 0, 512)
    property real keyboardIconScale: Utils.clamp(val('keyboard.icon.scale', 1.0), 0.2, 3.0)
    property int  keyboardIconSpacing: Utils.clamp(val('keyboard.icon.spacing', 4), 0, 64)
    property int  keyboardIconPadding: Utils.clamp(val('keyboard.icon.padding', 4), 0, 64)
    property real keyboardTextPadding: Utils.clamp(val('keyboard.text.padding', 1.5), 0, 32)
    property int  keyboardIconBaselineOffset: Utils.clamp(val('keyboard.icon.baselineOffset', 0), -20, 20)
    property int  keyboardTextBaselineOffset: Utils.clamp(val('keyboard.text.baselineOffset', 0), -20, 20)
    property real keyboardFontScale: Utils.clamp(val('keyboard.font.scale', 0.9), 0.5, 2.0)
    property int  keyboardRadius: Utils.clamp(val('keyboard.radius', cornerRadiusSmall), 0, 64)
    // Keyboard opacity + text emphasis
    property real keyboardNormalOpacity: Utils.clamp(val('keyboard.opacity.normal', 1.0), 0, 1)
    property real keyboardHoverOpacity: Utils.clamp(val('keyboard.opacity.hover', 1.0), 0, 1)
    property bool keyboardTextBold: !!val('keyboard.text.bold', false)
    // Keyboard colors
    property color keyboardBgColor: val('keyboard.colors.bg', background)
    property color keyboardHoverBgColor: val('keyboard.colors.hoverBg', surfaceHover)
    property color keyboardTextColor: val('keyboard.colors.text', textPrimary)
    property color keyboardIconColor: val('keyboard.colors.icon', textSecondary)
    // UI easing (configurable via string names)
    property int uiEasingQuick: easingType(val('ui.anim.easing.quick', 'OutQuad'), 'OutQuad')
    property int uiEasingRotate: easingType(val('ui.anim.easing.rotate', 'OutCubic'), 'OutCubic')
    property int uiEasingRipple: easingType(val('ui.anim.easing.ripple', 'InOutCubic'), 'InOutCubic')
    property int uiEasingStdOut: easingType(val('ui.anim.easing.stdOut', 'OutCubic'), 'OutCubic')
    property int uiEasingStdIn: easingType(val('ui.anim.easing.stdIn', 'InCubic'), 'InCubic')
    property int uiEasingInOut: easingType(val('ui.anim.easing.inOut', 'InOutQuad'), 'InOutQuad')
    // Applauncher entry opacities
    property real applauncherClipboardEntryOpacity: Utils.clamp(val('applauncher.list.opacity.clipboard', 0.8), 0, 1)
    property real applauncherCommandEntryOpacity: Utils.clamp(val('applauncher.list.opacity.command', 0.9), 0, 1)
    property real applauncherNoMetaOpacity: Utils.clamp(val('applauncher.list.opacity.noMeta', 0.6), 0, 1)
    // Calendar popup sizing
    property int calendarWidth: Utils.clamp(val('calendar.size.width', themeData.calendarWidth), 200, 800)
    property int calendarHeight: Utils.clamp(val('calendar.size.height', themeData.calendarHeight), 200, 800)
    property int calendarPopupMargin: Utils.clamp(val('calendar.popupMargin', themeData.calendarPopupMargin), 0, 32)
    property int calendarBorderWidth: val('calendar.borderWidth', themeData.calendarBorderWidth)
    property int calendarCellSize: Utils.clamp(val('calendar.cellSize', themeData.calendarCellSize), 16, 64)
    property int calendarHolidayDotSize: val('calendar.holidayDotSize', themeData.calendarHolidayDotSize)
    // Calendar explicit spacings/margins
    property int calendarDowSpacing: val('calendar.dow.spacing', 0)
    property int calendarDowSideMargin: val('calendar.dow.sideMargin', 0)
    property int calendarGridSpacing: val('calendar.grid.spacing', 0)
    // Calendar font sizes (logical px before per-screen scaling)
    property int calendarTitleFontPx: Utils.clamp(val('calendar.font.titlePx', 18), 8, 64)
    property int calendarDowFontPx: Utils.clamp(val('calendar.font.dowPx', 15), 6, 48)
    property int calendarDayFontPx: Utils.clamp(val('calendar.font.dayPx', 24), 8, 64)
    // Calendar DOW styles
    property bool calendarDowItalic: val('calendar.dow.italic', true)
    property bool calendarDowUnderline: val('calendar.dow.underline', true)
    // Calendar shape factors
    property real calendarCellRadiusFactor: Utils.clamp(val('calendar.cell.radiusFactor', 0.33), 0, 1)
    property real calendarHolidayDotRadiusFactor: Utils.clamp(val('calendar.holidayDot.radiusFactor', 0.5), 0, 1)
    // Calendar opacities
    property real calendarTitleOpacity: Utils.clamp(val('calendar.opacity.title', 0.7), 0, 1)
    property real calendarDowOpacity: Utils.clamp(val('calendar.opacity.dow', 0.9), 0, 1)
    property real calendarOtherMonthDayOpacity: Utils.clamp(val('calendar.opacity.otherMonthDay', 0.3), 0, 1)
    // Tunable factor for dark accent on calendar highlights (today/selected/hover)
    property real calendarAccentDarken: Utils.clamp(val('calendar.accentDarken', themeData.calendarAccentDarken), 0, 1)
    // Spectrum opacities
    property real spectrumFillOpacity: Utils.clamp(val('spectrum.fillOpacity', 0.35), 0, 1)
    property real spectrumPeakOpacity: Utils.clamp(val('spectrum.peakOpacity', 0.7), 0, 1)
    // Diagonal separator stripe opacity
    property real uiSeparatorStripeOpacity: Utils.clamp(val('ui.separator.diagonal.stripeOpacity', 0.9), 0, 1)
    // Derived accent/surface/border tokens (formula-based)
    // Keep simple and perceptually stable; expose tokens for reuse
    // Each derived token may be overridden by matching *Override property in Theme.json
    property color accentHover: (val('colors.overrides.accentHover', themeData.accentHoverOverride) !== undefined)
        ? val('colors.overrides.accentHover', themeData.accentHoverOverride) : Color.towardsWhite(accentPrimary, 0.2)
    property color accentActive: (val('colors.overrides.accentActive', themeData.accentActiveOverride) !== undefined)
        ? val('colors.overrides.accentActive', themeData.accentActiveOverride) : Color.towardsBlack(accentPrimary, 0.2)
    property color accentDarkStrong: (val('colors.overrides.accentDarkStrong', themeData.accentDarkStrongOverride) !== undefined)
        ? val('colors.overrides.accentDarkStrong', themeData.accentDarkStrongOverride) : Color.towardsBlack(accentPrimary, 0.8)
    property color surfaceHover: (val('colors.overrides.surfaceHover', themeData.surfaceHoverOverride) !== undefined)
        ? val('colors.overrides.surfaceHover', themeData.surfaceHoverOverride) : Color.withAlpha(textPrimary, 0.06)
    property color surfaceActive: (val('colors.overrides.surfaceActive', themeData.surfaceActiveOverride) !== undefined)
        ? val('colors.overrides.surfaceActive', themeData.surfaceActiveOverride) : Color.withAlpha(textPrimary, 0.10)
    property color borderSubtle: (val('colors.overrides.borderSubtle', themeData.borderSubtleOverride) !== undefined)
        ? val('colors.overrides.borderSubtle', themeData.borderSubtleOverride) : Color.withAlpha(textPrimary, 0.15)
    property color borderStrong: (val('colors.overrides.borderStrong', themeData.borderStrongOverride) !== undefined)
        ? val('colors.overrides.borderStrong', themeData.borderStrongOverride) : Color.withAlpha(textPrimary, 0.30)
    property color overlayWeak: (val('colors.overrides.overlayWeak', themeData.overlayWeakOverride) !== undefined)
        ? val('colors.overrides.overlayWeak', themeData.overlayWeakOverride) : Color.withAlpha(shadow, 0.08)
    property color overlayStrong: (val('colors.overrides.overlayStrong', themeData.overlayStrongOverride) !== undefined)
        ? val('colors.overrides.overlayStrong', themeData.overlayStrongOverride) : Color.withAlpha(shadow, 0.18)
}
