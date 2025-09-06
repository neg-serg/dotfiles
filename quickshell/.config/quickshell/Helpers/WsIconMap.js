// WsIconMap: maps submap names and keywords to Material Symbols with heuristics.
// Usage: import "../Helpers/WsIconMap.js" as WsMap; WsMap.submapIcon(name, Theme.wsSubmapIconOverrides)

function _defaultMap() {
  return {
    // movement / resizing
    move: "open_with",
    moving: "open_with",
    resize: "open_in_full",
    swap: "swap_horiz",
    swap_ws: "swap_horiz",
    // launching / apps
    launcher: "apps",
    launch: "apps",
    // media / volume / brightness
    media: "play_circle",
    volume: "volume_up",
    brightness: "brightness_6",
    // windows / tiling / workspaces / monitors
    window: "web_asset",
    windows: "web_asset",
    tile: "grid_on",
    tiling: "grid_on",
    ws: "grid_view",
    workspace: "grid_view",
    monitor: "monitor",
    display: "monitor",
    // tools / system
    system: "settings",
    tools: "build_circle",
    gaps: "crop_square",
    // text / edit / select / clipboard
    select: "select_all",
    edit: "edit",
    copy: "content_copy",
    paste: "content_paste",
    // terminals / code / search / screenshot
    terminal: "terminal",
    shell: "terminal",
    code: "code",
    search: "search",
    screenshot: "screenshot",
    // browsers
    browser: "language",
    web: "language",
    // explicit mappings for discovered submaps
    special: "view_in_ar",
    wallpaper: "wallpaper",
  };
}

function _geometricFallbackIcon(name) {
  var shapes = ["crop_square", "radio_button_unchecked", "change_history", "hexagon", "pentagon", "diamond"];
  var s = (String(name || "")).toLowerCase();
  var h = 0;
  for (var i = 0; i < s.length; i++) h = (h * 33 + s.charCodeAt(i)) >>> 0;
  return shapes[h % shapes.length];
}

function _heuristic(name) {
  var key = (String(name || "")).toLowerCase();
  if (/resiz/.test(key)) return "open_in_full";
  if (/move|drag/.test(key)) return "open_with";
  if (/swap/.test(key)) return "swap_horiz";
  if (/launch|launcher/.test(key)) return "apps";
  if (/media/.test(key)) return "play_circle";
  if (/vol|audio|sound/.test(key)) return "volume_up";
  if (/bright|light/.test(key)) return "brightness_6";
  if (/(^|_)ws|work|desk|tile|grid/.test(key)) return "grid_view";
  if (/mon|display|screen|output/.test(key)) return "monitor";
  if (/term|shell|tty/.test(key)) return "terminal";
  if (/code|dev/.test(key)) return "code";
  if (/search|find/.test(key)) return "search";
  if (/shot|screen.*shot|snap/.test(key)) return "screenshot";
  if (/browser|web|http/.test(key)) return "language";
  if (/select|sel/.test(key)) return "select_all";
  if (/edit/.test(key)) return "edit";
  if (/copy|yank/.test(key)) return "content_copy";
  if (/paste/.test(key)) return "content_paste";
  if (/sys|system|cfg|conf/.test(key)) return "settings";
  if (/gap/.test(key)) return "crop_square";
  return _geometricFallbackIcon(key);
}

function submapIcon(name, overrides) {
  var key = (String(name || "")).toLowerCase().trim();
  if (!key) return "";
  // overrides win
  if (overrides && overrides[key]) return overrides[key];
  var map = _defaultMap();
  if (map[key]) return map[key];
  return _heuristic(key);
}

// Export API
var WsIconMap = {
  submapIcon: submapIcon,
  fallback: _geometricFallbackIcon
};

// QML import compatibility: when imported as a namespace, return functions directly
if (typeof WsIconMap !== 'undefined') {
  // no-op; used via WsIconMap.submapIcon
}

// Also expose top-level for direct namespacing
function __qml_namespace__() { return WsIconMap }

