_: {
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
}
