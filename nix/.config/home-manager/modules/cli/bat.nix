{lib, ...}: {
  # Reduce activation noise: disable bat cache build step unless needed
  programs.bat.enable = false;
  programs.bat.config = {
    theme = lib.mkForce "ansi";
    italic-text = "always";
    paging = "never";
    decorations = "never";
  };
}
