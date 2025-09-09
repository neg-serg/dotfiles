# DONT BELIEVE IT!
I will create new readme later

<img src="https://i.imgur.com/RlmtERk.jpg" alt="terminal_new" align="right" height="320px">

<img src="https://i.imgur.com/Zb7WXjz.jpg" alt="firefox_new" align="right" height="320px">

<img src="https://i.imgur.com/cVMnzUi.jpg" alt="devenv_new" align="right" height="320px">

<img src="https://i.imgur.com/RTEo3vM.jpg" alt="music_new" align="right" height="320px">

## Shell and terminal emulators

[alacritty](https://github.com/alacritty/alacritty) -- a cross-platform,
GPU-accelerated terminal emulator, my only option for now. Using
[zsh](https://www.zsh.org/) -- the best of the best shell for me, pretty
complex custom config. Zsh has pretty compact config with fast startup and
support of customized [p10k](https://github.com/romkatv/powerlevel10k) and
[zinit](https://github.com/zdharma/zinit) plugin manager. For noninteractive
use and scripts use [dash](http://gondor.apana.org.au/~herbert/dash/) the
Almquist shell direct successor as fast and compact bourne-shell derivative.
**dircolors** -- my 256-color filetype-based dircolors, it supports a lot of
filetypes. [tmux](https://github.com/tmux/tmux/wiki) -- most modern terminal
multiplexor.

## Dev environment and docs

[neovim](https://neovim.io/) -- using neovim as only editor option for now.
It's used as my only developement environment for the all programming
languages. I also created a custom [neg](https://github.com/neg-serg/neg)
neovim colorscheme [git](https://git-scm.com/) -- as vcs system,
[gdb](https://www.gnu.org/software/gdb/) -- GNU debugger as debugger. Using
fast and tiny [zathura](https://pwmt.org/projects/zathura/) pdf/djvu/whatever
viewer with UX similar to vim. [taskwarrior](https://taskwarrior.org/) --
basic config for my GTD-like tool taskwarrior.

## X11 and UX

[i3-gaps](https://github.com/Airblader/i3) -- my current WM. I migrated to it
after many years of using my fork of Notion WM. It has extremely
sophisticated and unusial customization with help of my
[negwm](https://github.com/neg-serg/negwm) to make it UX more similar to
[ion3](https://tuomov.iki.fi/software/) and [notion](https://notionwm.net/),
with a lot of unique features as run of raise over windows tags, multiwindow
scratchpads, config generator and more, rofi-menu generator and more. Also
I'm using Gnome integration in i3 with pleasure.

https://github.com/neg-serg/negi3mods

I presumptuously think that this is the most sophisticated thing that was
created with the help of these i3ipc tools in the world ever and is also
a good example of creating some new stuff with i3ipc. Though it python-based
it's really fast because of client-server architecture.

**gtk** -- using custom version of
[Kora](https://github.com/bikass/kora)
[dunst](https://dunst-project.org/) -- my minimalistic notification daemon,
which also used for mpd-notification.
[polybar](https://github.com/polybar/polybar) -- my favorite statusbar.
**keymaps** -- alternative keymaps. I am using xmodmaprc with caps-lock
rebinded to ctrl, etc.
[rofi](https://github.com/davatorium/rofi) -- dmenu analogue to run programs,
find windows, everything, used very widely. It's definitely my favorite menu
generator.
[picom](https://github.com/yshui/picom)
Compositing manager, modern fork of compton with support of very fancy kawase
blur algorithm and some new experimental backends.

Some stuff from Gnome project:

**gnome-keyring-daemon**: Gnome keyring daemon

**gpaste**: GPaste clipboard manager daemon, using it with help of rofi.

and some misc stuff:

**udiskie** automounter

## Music and media

For music I am using local storage with MPD Music Player Daemon, ncmpcpp mpd
client, managing library with picard and beets. Also using mpdas as last.fm
scrobbler mpd-notification script for fancy MPD Notification with help of
dunst. For video I am using **mpv** minimalistic, fast and customizable video
player. For images I am using my fork of **sxiv**. I do not using it a lot,
but like picture preview feature(in terminal, based on w3m).

## Web and network stuff

If you are vimperator fan like me please try tridactyl. Vimperator-like
firefox addon which brings vim-like keybindings and UX in firefox. After some
patching and user-css stuff it become nice enough for daily use. You can find
it config here:

https://github.com/neg-serg/dotfiles/tree/master/tridactyl

**stig** -- custom colorscheme for this nice transmission-client for
transmission-daemon. It's the most beautiful transmission-client as I know.

**imgur-screenshot** -- command line interface imgur uploader.

**nm-applet**: Network manager applet

## Games

**dos** -- configs for dos emulators.

## Support

If you like my stuff, you can [buy me a coffee](https://www.buymeacoffee.com/negserg).
# nixos-home

