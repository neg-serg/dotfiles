{ ... }: {
  # fd, ripgrep, direnv, shell helpers (nix-your-shell), posh toggle
  programs.fd = {
    enable = true;
    ignores = [".git/"];
  };
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--no-heading"
      "--smart-case"
      "--follow"
      "--hidden"
      "--glob=!.git/"
      "--glob=!node_modules/"
      "--glob=!yarn.lock"
      "--glob=!package-lock.json"
      "--glob=!.yarn/"
      "--glob=!_build/"
      "--glob=!tags"
      "--glob=!.pub-cache"
    ];
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  programs = {
    oh-my-posh = {
      enable = false;
      useTheme = "atomic";
    };
    nix-your-shell.enable = true;
  };
}
