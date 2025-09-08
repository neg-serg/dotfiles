{
  # Desktop-oriented unfree packages
  desktop = [
    "abuse" # side-scrolling shooter (LISP)
    "ocenaudio" # audio editor
    "reaper" # DAW
    "vcv-rack" # modular synth
    "vital" # digital synth
    "roomeqwizard" # room acoustics
    "stegsolve" # image stego analyzer
    "volatility3" # memory forensics
    "cursor" # AI code editor (VS Code)
    "claude-code" # Claude Code client
    "yandex-browser-stable" # Yandex Browser (Chromium)
    "lmstudio" # local LLM app
    "code-cursor-fhs" # Cursor (FHS)
  ];

  # Headless/server preset: no unfree packages allowed
  headless = [ ];
}
