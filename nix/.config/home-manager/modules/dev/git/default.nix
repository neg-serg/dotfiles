{pkgs, ...}: {
  home.packages = with pkgs; [
    gist # manage github gists
    act # local github actions
    difftastic # syntax-aware diff
  ];

  programs.git = {
    enable = true;
    userName = "Sergey Miroshnichenko";
    userEmail = "serg.zorg@gmail.com";
    extraConfig = {
      commit = {verbose = true;};
      log = {decorate = "short";};
      core = {
        pager = "PAGER= delta --keep-plus-minus-markers --dark";
        whitespace = "trailing-space,cr-at-eol";
        excludesfile = "/etc/gitignore";
        editor = "nvr --remote-wait-silent";
        untrackedCache = true;
      };
      color = {
        pager = 0;
        grep = "auto";
        showbranch = "auto";
        ui = "auto";
        status = {
          added = 29;
          branch = 62;
          changed = "31 bold";
          header = 23;
          localBranch = 24;
          remoteBranch = 25;
          nobranch = 197;
          untracked = 235;
        };
        branch = {
          current = 67;
          local = "18 bold";
          remote = 25;
        };
        diff = {
          old = 126;
          new = 24;
          plain = 7;
          meta = 25;
          frag = 67;
          func = 68;
          commit = 4;
          whitespace = 54;
          colorMoved = "default";
        };
      };
      delta = {
        inspect-raw-lines = true;
        light = false;
        # line-numbers-left-format = "";
        # line-numbers-right-format = "";
        line-numbers-left-format = "";
        line-numbers-right-format = "│ ";
        navigate = false;
        side-by-side = false;
        syntax-theme = "base16-256";
        minus-emph-style = "\"#781f34\" bold \"#000000\"";
        minus-style = "\"#781f34\" \"#000000\"";
        whitespace-error-style = "22 reverse";
        plus-emph-style = "\"#357B63\" bold \"#000000\"";
        plus-style = "\"#017978\" \"#000000\"";
        zero-style = "#c6c6c6";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
      };
      man = {
        viewer = "nvimpager -p";
      };
      receive = {
        denyCurrentBranch = "ignore";
      };
      github = {
        user = "neg-serg";
      };
      diff = {
        tool = "nwim";
        algorithm = "patience";
        colorMoved = "default";
      };
      alias = {
        ap = "add --patch"; # thx to https://nuclearsquid.com/writings/git-add/
        hub = "!hub";
        patch = "!git --no-pager diff --no-color";
        subpull = "submodule foreach git pull";
        undo = "reset --soft @~";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      filter.lfs = {
        required = true;
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
      };
      push = {default = "simple";};
      pull = {rebase = true;};
      rebase = {
        autoStash = true;
        autosquash = true;
      };
      url = {
        "git@github.com:".pushInsteadOf = ["https://github.com/" "git://github.com/"];
        "https://aur.archlinux.org/".insteadOf = "aur:";
        "ssh://aur@aur.archlinux.org/".pushInsteadOf = "aur:";
        "https://codeberg.org/".insteadOf = "codeberg:";
        "ssh://git@codeberg.org/".pushInsteadOf = "codeberg:";
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      merge = {
        tool = "nvimdiff";
      };
      mergetool = {
        prompt = true;
      };
      credential = {
        helper = "cache --timeout=28800";
      };
      difftool.nwim = {
        cmd = "~/bin/v -d $LOCAL $REMOTE";
      };
      mergetool.nwim = {
        cmd = "~/bin/v -d $LOCAL $BASE $REMOTE $MERGED -c 'wincmd J | wincmd ='";
      };
      mergetool.nvimdiff = {
        keepBackup = true;
        cmd = "nvim -d \"$LOCAL\" \"$MERGED\" \"$REMOTE\"";
        trustExitCode = true;
      };
    };
  };
}
