{config, ...}: {
  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "~/music";
    settings = {
      #--=[ mpd ]=---------------
      mpd_host = "localhost";
      mpd_port = 6600;
      mpd_crossfade_time = "0";
      ncmpcpp_directory = "${config.xdg.configHome}/ncmpcpp";
      #--=[ Main ]=-------------------
      autocenter_mode = "yes";
      centered_cursor = "yes";
      user_interface = "classic";
      locked_screen_width_part = "70";
      display_bitrate = "yes";
      mouse_support = "no";
      mouse_list_scroll_whole_page = "no";
      use_console_editor = "yes";
      external_editor = "nvim";
      jump_to_now_playing_song_at_start = "yes";
      ask_before_clearing_playlists = "no";
      song_window_title_format = "ncmpcpp";
      default_find_mode = "wrapped";
      block_search_constraints_change_if_items_found = "no";
      follow_now_playing_lyrics = "no";
      #--=[ Playlist ]=---------------
      playlist_disable_highlight_delay = "1";
      playlist_show_remaining_time = "yes";
      playlist_shorten_total_times = "yes";
      playlist_display_mode = "classic";
      playlist_editor_display_mode = "columns";
      show_duplicate_tags = "no";
      cyclic_scrolling = "no";
      space_add_mode = "always_add";
      lines_scrolled = "1";
      #--=[ Progressbar ]=--------
      progressbar_look = "─╼ ";
      progressbar_color = "black";
      progressbar_elapsed_color = "239";
      #--=[ Bars ]=---------------
      song_status_format = "{$8%a} $(26)❯$(26)> {$8%t} $(26)❯$(26)> $b{$8%b}$/b $b({$8%y})$/b$(end)";
      song_list_format = "$(57)%5n  $(7)%26a$7$(238) ❯ $(250)%44t$(1)$R$(238)❮ $(250)%5l $7%28b$(end)";
      song_library_format = "{$(3)%n$(end)$(26) ❯ $(end)}{%t}|{%f}";
      now_playing_suffix = "$/b$(24)◂$(26)";
      current_item_prefix = "$b$(26)❯>";
      current_item_suffix = "$/b$/r$(end)";
      current_item_inactive_column_prefix = "$b$(25)$(end)";
      current_item_inactive_column_suffix = "$/b$/r$(end)";
      titles_visibility = "no";
      header_visibility = "no";
      statusbar_visibility = "no";
      #--=[ Media library ]=--------
      media_library_primary_tag = "artist";
      media_library_albums_split_by_date = "yes";
      #--=[ Browser ]=--------------
      browser_display_mode = "classic";
      incremental_seeking = "yes";
      seek_time = "4";
      message_delay_time = "1";
      #--=[ Colors ]=---------------
      colors_enabled = "yes";
      discard_colors_if_item_is_selected = "yes";
      header_window_color = "black";
      volume_color = "cyan";
      volume_change_step = "1";
      state_line_color = "black";
      state_flags_color = "green";
      main_window_color = "default";
      color1 = "cyan";
      color2 = "default";
      statusbar_color = "white";
      default_tag_editor_pattern = "%n - %t";
      ignore_leading_the = "yes";
      ignore_diacritics = "yes";
      search_engine_display_mode = "classic";
      default_place_to_search_in = "database";
      show_hidden_files_in_local_browser = "no";
      active_window_border = "black";
      empty_tag_marker = "⟬…⟭";
      regular_expressions = "extended";
      #--=[ Visualizer ]=---------------
      visualizer_data_source = "/tmp/audio.fifo";
      visualizer_output_name = "my_fifo";
      visualizer_in_stereo = "no";
      visualizer_color = "091,097,108,104,99,105,111";
      visualizer_look = "▞▋";
      visualizer_type = "ellipse";
    };
    bindings = [
      {
        key = "0";
        command = "show_browser";
      }
      {
        key = "1";
        command = "show_playlist";
      }
      {
        key = "2";
        command = "show_media_library";
      }
      {
        key = "3";
        command = "dummy";
      }
      {
        key = "4";
        command = "dummy";
      }
      {
        key = "5";
        command = "dummy";
      }
      {
        key = "6";
        command = "dummy";
      }
      {
        key = "7";
        command = "dummy";
      }
      {
        key = "a";
        command = "add_selected_items";
      }
      {
        key = "backspace";
        command = ["jump_to_parent_directory" "replay_song" "jump_to_parent_directory" "replay_song"];
      }
      {
        key = "b";
        command = "seek_backward";
      }
      {
        key = "c";
        command = "clear_main_playlist";
      }
      {
        key = "`";
        command = "add_random_items";
      }
      {
        key = "'";
        command = "dummy";
      }
      {
        key = "\\\\";
        command = "dummy";
      }
      {
        key = "`";
        command = "dummy";
      }
      {
        key = "/";
        command = "find_item_forward";
      }
      {
        key = "~";
        command = "jump_to_media_library";
      }
      {
        key = ";";
        command = "jump_to_position_in_song";
      }
      {
        key = ">";
        command = "next";
      }
      {
        key = "<";
        command = "previous";
      }
      {
        key = "]";
        command = "scroll_down_album";
      }
      {
        key = "}";
        command = "scroll_down_artist";
      }
      {
        key = "[";
        command = "scroll_up_album";
      }
      {
        key = "{";
        command = "scroll_up_artist";
      }
      {
        key = "?";
        command = "show_search_engine";
      }
      {
        key = "@";
        command = "show_server_info";
      }
      {
        key = "`";
        command = "toggle_browser_sort_mode";
      }
      {
        key = "`";
        command = "toggle_library_tag_type";
      }
      {
        key = "|";
        command = "toggle_mouse";
      }
      {
        key = "-";
        command = "volume_down";
      }
      {
        key = "+";
        command = "volume_up";
      }
      {
        key = "ctrl-d";
        command = "page_down";
      }
      {
        key = "ctrl-l";
        command = "toggle_screen_lock";
      }
      {
        key = "ctrl-p";
        command = "set_selected_items_priority";
      }
      {
        key = "ctrl-u";
        command = "page_up";
      }
      {
        key = "d";
        command = "delete_playlist_items";
      }
      {
        key = "down";
        command = "dummy";
      }
      {
        key = "e";
        command = "edit_directory_name";
      }
      {
        key = "e";
        command = "edit_library_album";
      }
      {
        key = "e";
        command = "edit_library_tag";
      }
      {
        key = "e";
        command = "edit_playlist_name";
      }
      {
        key = "e";
        command = "edit_song";
      }
      {
        key = "E";
        command = "jump_to_tag_editor";
      }
      {
        key = "f1";
        command = "show_help";
      }
      {
        key = "F";
        command = "dummy";
      }
      {
        key = "f";
        command = "seek_forward";
      }
      {
        key = "G";
        command = "move_end";
      }
      {
        key = "g";
        command = "move_home";
      }
      {
        key = "h";
        command = "previous_column";
      }
      {
        key = "I";
        command = "show_artist_info";
      }
      {
        key = "i";
        command = "show_song_info";
      }
      {
        key = "j";
        command = "scroll_down";
      }
      {
        key = "k";
        command = "scroll_up";
      }
      {
        key = "L";
        command = "dummy";
      }
      {
        key = "l";
        command = "next_column";
      }
      {
        key = "left";
        command = "dummy";
      }
      {
        key = "M";
        command = "toggle_media_library_columns_mode";
      }
      {
        key = "mouse";
        command = "mouse_event";
      }
      {
        key = "n";
        command = "next_found_item";
      }
      {
        key = "N";
        command = "previous_found_item";
      }
      {
        key = "P";
        command = "dummy";
      }
      {
        key = "p";
        command = "pause";
      }
      {
        key = "q";
        command = "quit";
      }
      {
        key = "R";
        command = "jump_to_browser";
      }
      {
        key = "r";
        command = "jump_to_playing_song";
      }
      {
        key = "right";
        command = "dummy";
      }
      {
        key = "S";
        command = "show_search_engine";
      }
      {
        key = "s";
        command = "stop";
      }
      {
        key = "shift-tab";
        command = "previous_screen";
      }
      {
        key = "tab";
        command = "next_screen";
      }
      {
        key = "t";
        command = "jump_to_tag_editor";
      }
      {
        key = "u";
        command = "update_database";
      }
      {
        key = "up";
        command = "dummy";
      }
      {
        key = "w";
        command = "toggle_find_mode";
      }
      {
        key = "y";
        command = "save_tag_changes";
      }
      {
        key = "y";
        command = "start_searching";
      }
      {
        key = "Y";
        command = "toggle_replay_gain_mode";
      }
      {
        key = "z";
        command = "dummy";
      }
    ];
  };
}
