# ProcessRunner (qs.Components)

Lightweight wrapper around Quickshell Io.Process with common quality-of-life features.

## Properties
- `cmd: string[]`: argv array, e.g. `["bash","-lc","ip -j -br a"]`.
- `env: object | null`: extra environment vars.
- `autoStart: bool` (default true for one-shot; false if polling via `intervalMs`).
- `intervalMs: int` (0 = run once; >0 = poll on interval).
- `backoffMs: int` (restart delay when not polling).
- `restartMode: 'always'|'never'` (when `intervalMs == 0`). Falls back to legacy `restartOnExit` if unset.
- `restartOnExit: bool` (deprecated; use `restartMode`).
- `parseJson: bool`: parse entire stdout as JSON when process exits and emit `json(obj)`.
- `jsonLine: bool`: parse each line as JSON while streaming. Falls back to `line(s)` if parse fails.
- `debounceMs: int`: debounce emission of streaming events (lines/chunks) to reduce UI churn.
- `stdinEnabled: bool`: open stdin to the child process.
- `rawMode: bool`: emit raw stdout via `chunk(string)` instead of line splitting.

## Signals
- `line(string)`: called per line in streaming mode.
- `json(var obj)`: JSON payload (either from `parseJson` end-parse or `jsonLine`).
- `chunk(string)`: raw chunk when `rawMode` is true.
- `exited(int code, int status)`: child exit notification.
- `started()`: emitted when process starts.

## Methods
- `start()`, `stop()`.
- `write(string)`: write to stdin (requires `stdinEnabled: true`).
- `closeStdin()`: convenience to close stdin via `stdinEnabled = false`.

## Usage patterns

1) One-shot JSON
```qml
ProcessRunner {
  cmd: ["bash","-lc","ip -j -br a"]
  parseJson: true
  onJson: (obj) => update(obj)
}
```

2) Streaming JSON lines
```qml
ProcessRunner {
  cmd: ["my-json-stream"]
  jsonLine: true
  debounceMs: 100 // optional throttle
  onJson: (o) => handle(o)
}
```

3) Raw chunks (binary-like)
```qml
ProcessRunner {
  cmd: ["cava","-p","/dev/stdin"]
  stdinEnabled: true
  rawMode: true
  onStarted: {
    write("[output]\nmethod=raw\nbit_format=8\n");
    stdinEnabled = false;
  }
  onChunk: (data) => consume(data)
}
```

4) Polling on interval
```qml
ProcessRunner {
  cmd: ["bash","-lc","uptime -p"]
  intervalMs: 5000
  restartMode: "never"
  onLine: (s) => uptimeLabel.text = s
}
```

Notes
- Prefer `jsonLine` for per-line JSON sources (fewer try/catch blocks).
- Use `debounceMs` to reduce UI churn for very chatty outputs.
- `restartMode` is only relevant when `intervalMs == 0`.

