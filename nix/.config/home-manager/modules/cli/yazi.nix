_: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {show_hidden = true;};
      opener.edit = [
        {
          run = "nvim \"$@\"";
          block = true;
        }
      ];
    };
    keymap = {
      manager.prepend_keymap = [
        {
          run = "close";
          on = ["<Esc>"];
        }
        {
          run = "close";
          on = ["<C-q>"];
        }
        {
          run = "yank --cut";
          on = ["d"];
        }
        {
          run = "remove --force";
          on = ["D"];
        }
        {
          run = "remove --permanently";
          on = ["X"];
        }
        {
          on = ["f"];
          run = "shell \"$SHELL\" --block";
          desc = "Open $SHELL here";
        }
      ];
    };
  };
}
