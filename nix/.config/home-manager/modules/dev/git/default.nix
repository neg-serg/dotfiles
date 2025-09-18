{ lib, pkgs, config, xdg ? import ../../lib/xdg-helpers.nix { inherit lib; }, ... }:
with lib;
  mkIf config.features.dev.enable (lib.mkMerge [
    # Link user excludes file from repo into ~/.config/git/ignore with guards
    (xdg.mkXdgSource "git/ignore" {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/git/.config/git/ignore";
      recursive = false;
    })
    # Git hooks via helper: ensure parent dir is real and mark as executable
    (xdg.mkXdgSource "git/hooks/pre-commit" {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail
        # Repo root configured in HM (dotfilesRoot)
        repo="${config.neg.dotfilesRoot}/nix/.config/home-manager"
        # Run flake checks for HM (format docs, evals, etc.)
        (cd "$repo" && nix flake check -L)
        # Format the repo via treefmt (Nix, shell, Python, etc.)
        (cd "$repo" && nix fmt)
        # Sanity: reject whitespace errors in staged diff
        git diff --check
        # Stage any formatter changes
        git add -u
      '';
      executable = true;
    })
    (xdg.mkXdgSource "git/hooks/commit-msg" {
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail
        f="$1"
        first_line="$(sed -n '1p' "$f" | tr -d '\r')"
        # Allowed exceptions
        case "$first_line" in
          Merge\ *|Revert\ *|fixup!*|squash!*|WIP:*|WIP\ *)
            exit 0 ;;
        esac
        # Require one or more [scope] blocks followed by a space
        if echo "$first_line" | ${lib.getExe' pkgs.gnugrep "grep"} -qE '^\[[^][]+\]( \[[^][]+\])*\s'; then
          exit 0
        fi
        echo "Commit message must start with [scope] subject" >&2
        echo "Got: '$first_line'" >&2
        echo "Examples: [activation] ..., [docs] ..., [features] ..., [symlinks] ..." >&2
        exit 1
      '';
      executable = true;
    })
    {
    home.packages = with pkgs; config.lib.neg.pkgsList [
      act # run GitHub Actions locally
      difftastic # syntax-aware diff viewer
      gh # GitHub CLI
      gist # manage GitHub gists
    ];

    programs.git = {
      enable = true;
      userName = "Sergey Miroshnichenko";
      userEmail = "serg.zorg@gmail.com";
      extraConfig = {
        commit = {verbose = true;};
        log = {decorate = "short";};
        fetch = {shallow = true;};
        clone = {filter = "blob:none";};
        core = {
          pager = "delta";
          whitespace = "trailing-space,cr-at-eol";
          excludesfile = "${config.xdg.configHome}/git/ignore";
          editor = "nvr --remote-wait-silent";
          untrackedCache = true;
          sshCommand = "ssh -i ~/.ssh/id_neg";
        };
        color = {
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
          line-numbers-left-format = "";
          line-numbers-right-format = "│ ";
          navigate = false;
          side-by-side = false;
          syntax-theme = "base16-256";
          true-color = "auto";
          minus-emph-style = "#781f34 bold #000000";
          minus-style = "#781f34 #000000";
          whitespace-error-style = "22 reverse";
          plus-emph-style = "#357B63 bold #000000";
          plus-style = "#017978 #000000";
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
          dts = "!delta --side-by-side --color-only";
          hub = "!gh";
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
          "git@github.com:".insteadOf = "https://github.com/";
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
          helper = "!${pkgs.pass-git-helper}/bin/pass-git-helper --file ~/.config/git/pass.yml";
        };
        difftool.nwim = {
          cmd = "~/bin/v -d $LOCAL $REMOTE";
        };
        mergetool.nwim = {
          cmd = "~/bin/v -d $LOCAL $BASE $REMOTE $MERGED -c 'wincmd J | wincmd ='";
        };
        mergetool.delta = {
          cmd = "delta --merge-base \"$BASE\" \"$LOCAL\" \"$REMOTE\" > \"$MERGED\"";
          trustExitCode = false;
        };
        mergetool.nvimdiff = {
          keepBackup = true;
          cmd = "nvim -d \"$LOCAL\" \"$MERGED\" \"$REMOTE\"";
          trustExitCode = true;
        };
      };
    };
    }
  ])
