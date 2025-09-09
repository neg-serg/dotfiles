{
  config,
  lib,
  pkgs,
  ...
}: {
  # Remove stale ~/.config/mpv symlink that may point into this repo from older setups
  home.activation.fixMpvConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      MPVDIR="${config.xdg.configHome}/mpv"
      if [ -L "$MPVDIR" ]; then
        rm -f "$MPVDIR"
      fi
    '';

  programs.mpv = {
    enable = true;

    config = {
      # https://freetime.mikeconnelly.com/archives/5371
      # https://github.com/classicjazz/mpv-config
      # https://github.com/mpv-player/mpv/blob/master/DOCS/man/options.rst
      #--[Main]--------------------------------------------------
      input-ipc-server = "~/.config/mpv/socket";

      #--[Decoding]----------------------------------------------
      cache = "no";

      gpu-shader-cache-dir = "${config.home.homeDirectory}/tmp/";
      hwdec = "auto-safe";
      profile = "gpu-hq";
      # hwdec-codecs = "all";
      # icc-cache-dir = "${config.home.homeDirectory}/tmp/";
      vd-lavc-dr = true;
      vd-lavc-threads = "12";
      vo = "gpu-next";
      gpu-context = "wayland";
      gpu-api = "opengl";
      #--[ Debanding ]-------------------------------------------
      deband-grain = 48; # dynamic grain: set to "0" if using the static grain shader
      deband-iterations = 4; # deband steps

      deband = true; # enabled by default
      #--[ Interpolation ]---------------------------------------
      video-sync = "audio";

      interpolation = false;
      #--[Color]-------------------------------------------------
      # icc-profile-auto = true;
      # see https://github.com/mpv-player/mpv/wiki/Video-output---shader-stage-diagram

      # target-prim = "adobe";
      # target-prim = "bt.2020"; # target Rec.2020 (wide color gamut) for HDR TVs
      # target-prim = "bt.709"; # target Rec.709 for SDR TVs

      # vf = "format=colorlevels=full:colormatrix=auto";
      video-output-levels = "full";
      #--[Scaling]-----------------------------------------------
      cscale = "ewa_lanczossharp";

      dscale = "mitchell";
      linear-downscaling = false;
      scale = "ewa_lanczos";

      temporal-dither = "no";
      # Chroma subsampling means that chroma information is encoded at lower resolution than luma
      # In MPV, chroma is upscaled to luma resolution (video size) and then the converted RGB is upscaled to target resolution (screen size)
      # For detailed analysis of upscaler/downscaler quality, see https://artoriuz.github.io/blog/mpv_upscaling.html
      fbo-format = "rgba16hf"; # use with gpu-api=vulkan

      # chroma upscaling and downscaling
      # glsl-shaders-append="~/etc/mpv/shaders/KrigBilateral.glsl"
      # # luma upscaling
      # # note: any FSRCNNX above FSRCNNX_x2_8-0-4-1 is not worth the additional computional overhead
      # glsl-shaders="~/etc/mpv/shaders/FSRCNNX_x2_8-0-4-1.glsl"
      # glsl-shaders="~/etc/mpv/shaders/FSRCNNX_x2_8-0-4-1.glsl"
      # # luma downscaling
      # # note: ssimdownscaler is tuned for mitchell and downscaling=no
      # glsl-shaders-append="~/etc/mpv/shaders/SSimDownscaler.glsl"
      #--[Antiringing]-------------------------------------------
      cscale-antiring = "0.7"; # chroma upscale deringing
      dscale-antiring = "0.7"; # luma downscale deringing
      scale-antiring = "0.7"; # luma upscale deringing
      #--[Volume]------------------------------------------------
      ao = "pipewire,alsa,jack";
      volume-max = "100";
      #--[Language]----------------------------------------------
      alang = "en";
      slang = "ru,rus";
      #--[Geometry]----------------------------------------------
      border = "no";
      fullscreen = "yes";
      geometry = "100%:100%";
      #--[Subtitles]---------------------------------------------
      sub-auto = "fuzzy";
      sub-font = lib.mkForce ["Helvetica Neue LT Std" "HelveticaNeue LT CYR 57 Cond"];
      sub-gauss = ".82";
      sub-gray = "yes";
      sub-scale = "0.7";
      #--[OSD]---------------------------------------------------
      cursor-autohide = "500";
      osc = "no";
      osd-bar-align-y = "0";
      osd-bar-h = "3";
      osd-bar = "no";
      osd-border-color = lib.mkForce "#cc000000";
      osd-border-size = "1";
      osd-color = lib.mkForce "#bb6d839e";
      osd-font = lib.mkForce "Iosevka";
      osd-font-size = lib.mkForce "20";
      osd-status-msg = "$\{time-pos\} / $\{duration\} ($\{percent-pos\}%)$\{?estimated-vf-fps: FPS: $\{estimated-vf-fps\}\}";
      #--[Youtube-DL]--------------------------------------------
      ytdl-format = "bestvideo+bestaudio/best";
      #--[ETC]---------------------------------------------------
      screenshot-template = "~/dw/scr-%F_%P";
      # vim: set ft=dosini:
    };

    profiles = {
      #--[Audio]-------------------------------------------------
      "extension.ape" = {
        term-osd-bar-chars = "──╼ ·";
        term-osd-bar = true;
      };
      "extension.alac" = {
        term-osd-bar-chars = "──╼ ·";
        term-osd-bar = true;
      };
      "extension.flac" = {
        term-osd-bar-chars = "──╼ ·";
        term-osd-bar = true;
      };
      "extension.mp3" = {
        term-osd-bar-chars = "──╼ ·";
        term-osd-bar = true;
      };
      "extension.wav" = {
        term-osd-bar-chars = "──╼ ·";
        term-osd-bar = true;
      };
      "extension.gif" = {
        loop-file = true;
        osc = "no";
      };
      #--[Protocol Specific Configuration]-----------------------
      "protocol.http" = {
        cache-pause = false; # don't pause when the cache runs low
        cache = true;
      };
      "protocol.https" = {profile = "protocol.http";};
      "protocol.ytdl" = {profile = "protocol.http";};

      "4k60" = {
        # 2160p @ 60fps (3840x2160 UHDTV)
        profile-desc = "4k60";
        profile-cond = "((width ==3840 and height ==2160) and p[\"estimated-vf-fps\"]>=31)";
        # deband=yes # necessary to avoid blue screen with KrigBilateral.glsl
        deband = false; # turn off debanding because presume wide color gamut
        interpolation = false; # turn off interpolation because presume 60fps
        # UHD videos are already 4K so no luma upscaling is needed
        # UHD videos are YUV420 so chroma upscaling is still needed

        # glsl-shaders="~/etc/mpv/shaders/KrigBilateral.glsl" # enable if your hardware can support it
      };

      "4k30" = {
        # 2160p @ 24-30fps (3840x2160 UHDTV)
        profile-desc = "4k30";
        profile-cond = "((width ==3840 and height ==2160) and p[\"estimated-vf-fps\"]<31)";
        # deband=yes # necessary to avoid blue screen with KrigBilateral.glsl
        deband = false; # turn off debanding because presume wide color gamut
        # UHD videos are already 4K so no luma upscaling is needed
        # UHD videos are YUV420 so chroma upscaling is still needed

        # glsl-shaders="~/etc/mpv/shaders/KrigBilateral.glsl" # enable if your hardware can support it
      };

      "full-hd60" = {
        # 1080p @ 60fps (progressive ATSC)
        profile-desc = "full-hd60";
        profile-cond = "((width ==1920 and height ==1080) and not p[\"video-frame-info/interlaced\"] and p[\"estimated-vf-fps\"]>=31)";
        # apply all luma and chroma upscaling and downscaling settings
        interpolation = false; # no motion interpolation required because 60fps is hardware ceiling
      };

      "full-hd30" = {
        # 1080p @ 24-30fps (NextGen TV/ATSC 3.0, progressive Blu-ray)
        profile-desc = "full-hd30";
        profile-cond = "((width ==1920 and height ==1080) and not p[\"video-frame-info/interlaced\"] and p[\"estimated-vf-fps\"]<31)";
        # apply all luma and chroma upscaling and downscaling settings
        interpolation = false; # no motion interpolation required because 60fps is hardware ceiling
      };
    };

    scripts = with pkgs.mpvScripts; [
      cutter # cut and automatically concat videos
      mpris # MPRIS plugin
      quality-menu # ytdl-format quality menu
      seekTo # seek to spefici pos.
      sponsorblock # skip sponsored segments
      thumbfast # on-the-fly thumbnailer
      uosc # proximity UI
    ];

    scriptOpts = {
      osc = {
        deadzonesize = 0;
        scalewindowed = 0.666;
        scalefullscreen = 0.666;
        boxalpha = 140;
      };
      uosc = {
        timeline_line_width = 4;
        timeline_size = 30;
        timeline_persistency = "paused"; # Comma separated states when timeline should always be visible. available: paused, audio, image, video, idle
        controls = "menu,gap,subtitles,<has_many_audio>audio,<has_many_video>video,<has_many_edition>editions,<stream>stream-quality,gap,space,speed,space,shuffle,loop-playlist,loop-file,gap,prev,items,next,gap,fullscreen";
        # A comma delimited list of color overrides in RGB HEX format. Defaults:
        # foreground=ffffff,foreground_text=000000,background=000000,background_text=ffffff,curtain=111111,success=a5e075,error=ff616e
        color = lib.mkForce "foreground=005faf,foreground_text=000000,background=000000,background_text=6d839e";
        # A comma delimited list of opacity overrides for various UI element backgrounds and shapes.
        # This does not affect any text, which is always rendered fully opaque. Defaults:
        # timeline=0.9,position=1,chapters=0.8,slider=0.9,slider_gauge=1,controls=0,speed=0.6,menu=1,submenu=0.4,border=1,title=1,tooltip=1,thumbnail=1,curtain=0.8,idle_indicator=0.8,audio_indicator=0.5,buffering_indicator=0.3,playlist_position=0.8
        opacity = "volume=0.9,speed=0.6,menu=1,menu_parent=0.4,top_bar_title=0.8,window_border=0.8,curtain=0.5,timeline=0.9,timeline_chapters=0.7";
        # Where to display volume controls: none, left, right
        # Playback speed widget: mouse drag or wheel to change, click to reset

        # Controls all menus, such as context menu, subtitle loader/selector, etc

        # Top bar with window controls and media title
        # Can be: never, no-border, always
        top_bar_controls = "no";
        top_bar_title = "no"; # Can be: `no` (hide), `yes` (inherit title from mpv.conf), or a custom template string
        # Template string to enable alternative top bar title. If alt title matches main title,
        # it'll be hidden. Tip: use `${media-title}` for main, and `${filename}` for alt title.
        # Can be:
        #   `below`  => display alt title below the main one
        #   `toggle` => toggle the top bar title text between main and alt by clicking
        #               the top bar, or calling `toggle-title` binding
        top_bar_flash_on = "video";
        # Window border drawn in no-border mode

        # If there's no playlist and file ends, load next file in the directory Requires `keep-open=yes` in `mpv.conf`.

        # Enable uosc's playlist/directory shuffle mode
        # This simply makes the next selected playlist or directory item be random, just
        # like any other player in the world. It also has an easily togglable control button.

        scale = 1.1;
        scale_fullscreen = 1.1;
        font_scale = 1.1;

        # Execute command for background clicks shorter than this number of milliseconds, 0 to disable
        # Execution always waits for `input-doubleclick-time` to filter out double-clicks

        # Flash duration in milliseconds used by `flash-{element}` commands
        flash_duration = 2000;
        # Distances in pixels below which elements are fully faded in/out
        autohide = "yes"; # Hide UI when mpv autohides the cursor
        # Can be: none, flash, static, manual (controlled by flash-pause-indicator and decide-pause-indicator commands)
        # Sizes to list in stream quality menu
        stream_quality_options = "4320,2160,1440,1080,720,480";
        # Types to identify media files
        audio_types = "aac,ac3,aiff,ape,au,dsf,dts,flac,m4a,mid,midi,mka,mp3,mp4a,oga,ogg,opus,spx,tak,tta,wav,weba,wma,wv";
        subtitle_types = "aqt,ass,gsub,idx,jss,lrc,mks,pgs,pjs,psb,rt,slt,smi,sub,sup,srt,ssa,ssf,ttxt,txt,usf,vt,vtt";
        # Default open-file menu directory
      };
    };

    bindings = lib.mkMerge [
      {
        # mpv keybindings
        "+" = "add panscan +0.1";
        "-" = "add panscan -0.1";
        "tab" = "script-binding uosc/toggle-ui";

        "space" = "cycle pause; script-binding uosc/flash-pause-indicator";
        "p" = "cycle pause; script-binding uosc/flash-pause-indicator";
        "ctrl+enter" = "script-binding uosc/open-file";

        "i" = "script-message-to uosc flash-top-bar";

        ## the line under this one is not a comment
        "Ctrl+h" = "multiply speed 1/1.1";
        "Ctrl+l" = "multiply speed 1.1";
        "Ctrl+H" = "set speed 1.0";

        # Next 3 currently only work with --no-ass
        "r" = "add sub-pos -1"; # move subtitles up
        "t" = "add sub-pos +1"; # down
        "v" = "cycle sub-visibility 1";
        "F" = "cycle fullscreen 1";
        #--[ Sometimes I double click and the window will resize ]--
        #--[ This makes it idiot proof ]----------------------------
        #--[ Navigation ]---------------
        "right" = "seek +5; script-binding uosc/flash-timeline";
        "left" = "seek -5; script-binding uosc/flash-timeline";
        "up" = "seek +30; script-binding uosc/flash-timeline";
        "down" = "seek -30; script-binding uosc/flash-timeline";
        "l" = "seek +5; script-binding uosc/flash-timeline";
        "h" = "seek -5; script-binding uosc/flash-timeline";
        "L" = "seek +60; script-binding uosc/flash-timeline";
        "H" = "seek -60; script-binding uosc/flash-timeline";
        #--[ Volume ]-------------------
        "0" = "no-osd add volume +1; script-binding uosc/flash-volume";
        "9" = "no-osd add volume -1; script-binding uosc/flash-volume";
        "WHEEL_UP" = "no-osd add volume +1; script-binding uosc/flash-volume";
        "WHEEL_DOWN" = "no-osd add volume -1; script-binding uosc/flash-volume";
        "m" = "no-osd cycle mute; script-binding uosc/flash-volume";
        "A" = "cycle audio 1";
        #--[ Playlist control ]---------
        ">" = "script-binding uosc/next; script-message-to uosc flash-elements top_bar,timeline";
        "<" = "script-binding uosc/prev; script-message-to uosc flash-elements top_bar,timeline";
        "ESC" = "playlist_next";
        "R" = "cycle_values window-scale 2 0.5 1"; # switch between 2x, 1/2, unresized window size
        "j" = "cycle sub";
        "s" = "cycle sub";

        "mbtn_left" = "cycle pause 1";
        "mbtn_right" = "script-binding uosc/menu";
        ## vim: set cc= tw=0 ft=input.conf:
      }
    ];
  };
}
