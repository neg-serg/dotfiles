{ lib, config, pkgs, ... }:
{
  # Install tig and provide its configuration via XDG
  home.packages = config.lib.neg.filterByExclude [ pkgs.tig ];

  # Ensure ~/.config/tig is a real directory (remove stale/broken symlink)
  home.activation.fixTigConfigDir =
    config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/tig";

  # Ensure no leftover file blocks linking our config
  home.activation.fixTigConfigFile =
    config.lib.neg.mkEnsureAbsent "${config.xdg.configHome}/tig/config";

  # Write tig config as a Home Manager-managed file under XDG
  home.file."${config.xdg.configHome}/tig/config" = {
    text = ''
#--[ View settings ]-----------------------------------------------------------------------------------------------
set main-view = line-number:no,interval=5 id:no date:relative author:full commit-title:yes,graph,refs,overflow=no
set blame-view = date:relative author:full file-name:auto id:yes,color line-number:no,interval=5 text
set blob-view = line-number:yes,interval=1 text
set diff-view = line-number:yes,interval=1 text:yes,commit-title-overflow=no
set grep-view = file-name:no line-number:yes,interval=1 text
set log-view = line-number:yes,interval=1 text
set pager-view = line-number:yes,interval=1 text
set refs-view = date:relative author:full ref commit-title
set stage-view = line-number:yes,interval=1 text
set stash-view = line-number:no,interval=5 id:no date:default author:full commit-title
set status-view = line-number:no,interval=5 status:short file-name
set tree-view = line-number:no,interval=5 mode author:full file-size date:default id:no file-name

set show-changes = yes # Show changes commits in the main view?
set wrap-lines = no # Wrap long lines in pager views?
set tab-size = 2 # Number of spaces to use when expanding tabs
set line-graphics = utf-8 # Enum: ascii, default, utf-8

set reference-format = ⟨branch⟩ ⟨tag⟩ ❰remote❱ ~replace~

#--[ How to read content from git ]-----------------------------------------------------
set commit-order = default # Enum: default, topo, date, reverse (main)
set status-show-untracked-dirs = yes # Show files in untracked directories? (status)
set ignore-space = no # Enum: no, all, some, at-eol (diff)
set show-notes = yes # When non-bool passed as `--show-notes = ...` (diff)

set refresh-mode = auto # Enum: manual, auto, after-command, periodic
set refresh-interval = 10 # Interval in seconds between refreshes
set ignore-case = no # Ignore case when searching?
set focus-child = yes # Move focus to child view when opened?
set horizontal-scroll = 50% # Number of columns to scroll as % of width
set split-view-height = 80% # Number of lines for bottom view as % of height
set vertical-split = horizontal # Enum: horizontal, vertical, auto
set editor-line-number = yes # Automatically pass line number to editor?
set mouse = no # Enable mouse support?

bind main m view-main
bind main d view-diff
bind main l view-log
bind main t view-tree
bind main b view-blame
bind main h view-help
bind main s view-status
bind main y view-stash

# View manipulation
bind main <Enter> enter # Enter and open selected entry
bind main <Lt> back # Go back to the previous view state
bind main <C-N> next
bind main <C-P> previous
bind main , parent # Move to parent
bind main <Tab> view-next  # Move focus to the next view
bind main R refresh # Reload and refresh view
bind main O maximize # Maximize the current view
bind main q view-close # Close the current view
bind main Q quit # Close all views and quit

#--[ View specific ]------------------------------------------------------
bind status u status-update # Stage/unstage changes in file
bind status ! status-revert # Revert changes in file
bind status M status-merge # Open git-mergetool(1)
bind stage u status-update # Stage/unstage current diff (c)hunk
bind stage 1 stage-update-line # Stage/unstage current line
bind stage ! status-revert # Revert current diff (c)hunk
bind stage \\ stage-split-chunk # Split current diff (c)hunk
bind stage @ :/^@@ # Jump to next (c)hunk
bind main G :toggle commit-title-graph # Toggle revision graph visualization
bind main F :toggle commit-title-refs  # Toggle reference display (tags/branches)

#--[ Cursor navigation ]---------------
bind generic k move-up
bind generic j move-down
bind generic <C-D> move-page-down
bind generic <C-U> move-page-up
bind generic <Space> move-page-down

#--[ Scrolling ]-------------------------
bind generic <C-Y> scroll-line-up
bind generic <C-E> scroll-line-down

#--[ Searching ]---------------
bind generic / search
bind generic ? search-back
bind generic n find-next
bind generic N find-prev

#--[ Option manipulation ]----------------------------------------------------------
bind main o options # Open the options menu
bind main I :toggle sort-order # Toggle ascending/descending sort order
bind main i :toggle sort-field # Toggle field to sort by
bind main D :toggle date # Toggle date display
bind main A :toggle author # Toggle author display
bind main ~ :toggle line-graphics # Toggle (line) graphics mode
bind main F :toggle file-name # Toggle file name display
bind main W :toggle ignore-space # Toggle ignoring whitespace in diffs
bind main ? :toggle commit-order # Toggle commit ordering

#--[ Misc ]-----------------------------------------------------
bind generic e edit # Open in editor
bind generic : prompt # Open the prompt
bind generic <C-L> screen-redraw # Redraw the screen

#--[ Color settings ]----------------------
color "diff --" blue default
color "@@" magenta default
color "+" green default
color " +" green default
color "-" red default
color " -" red default
color "index " blue default
color "old file mode " blue default
color "new file mode " blue default
color "deleted file mode " blue default
color "copy from " blue default
color "copy to " blue default
color "rename from " blue default
color "rename to " blue default
color "similarity " blue default
color "dissimilarity " blue default
color "diff-tree " blue default
color "Author: " cyan default
color "Commit: " magenta default
color "Tagger: " magenta default
color "Merge: " blue default
color "Date: " blue default
color "AuthorDate: " blue default
color "CommitDate: " blue default
color "TaggerDate: " blue default
color "Refs: " red default
color "Reflog: " red default
color "Reflog message: " blue default
color "stash@{" magenta default
color "commit " green default
color "parent " blue default
color "tree " blue default
color "author " white default
color "committer " magenta default
color "    Signed-off-by" blue default
color "    Acked-by" blue default
color "    Tested-by" blue default
color "    Reviewed-by" blue default
color default default default
color cursor white 57
color title-blur black blue
color title-focus black blue
color status green default
color delimiter magenta default
color date blue default
color mode cyan default
color id magenta default
color overflow red default
color header blue default
color section cyan default
color directory blue default
color file default default
color grep.file blue default
color file-size default default
color line-number cyan default
color title-blur white black
color title-focus white black bold
color main-commit default default
color main-tag magenta default bold
color main-local-tag magenta default
color main-remote blue default
color main-replace cyan default
color main-tracked blue default bold
color main-ref cyan default
color main-head cyan default bold
color stat-none default default
color stat-staged magenta default
color stat-unstaged magenta default
color stat-untracked magenta default
color help-group blue default
color help-action blue default
color diff-stat blue default
color graph-commit 25 default

#--[ Mappings for colors read from git configuration. ]--
#--[ Set to "no" to disable. ]---------------------------
set git-colors = \
    branch.current=main-head \
    branch.local=main-ref \
    branch.plain=main-ref \
    branch.remote=main-remote \
    diff.meta=diff-header \
    diff.meta=diff-index \
    diff.meta=diff-oldmode \
    diff.meta=diff-newmode \
    diff.frag=diff-chunk \
    diff.old=diff-del \
    diff.new=diff-add \
    grep.filename=grep.file \
    grep.linenumber=grep.line-number \
    grep.separator=grep.delimiter \
    status.branch=status.header \
    status.added=stat-staged \
    status.updated=stat-staged \
    status.changed=stat-unstaged \
    status.untracked=stat-untracked
  '';
  };
}
