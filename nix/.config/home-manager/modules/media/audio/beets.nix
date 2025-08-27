{
  config,
  pkgs,
  ...
}: {
  programs.beets = {
    enable = false;
    package = pkgs.beets;
    settings = {
      plugins = [
        "bpm"
        "chroma"
        "duplicates"
        "edit"
        "embedart"
        "export"
        "fetchart"
        "fromfilename"
        "ftintitle"
        "fuzzy"
        "info"
        "lastgenre"
        "lastimport"
        "lyrics"
        "mbcollection"
        "mbsubmit"
        "mbsync"
        "mpdstats"
        "web"
      ];
      # "discogs"
      directory = "~/music"; # The default library root directory.
      library = "~/music/library.db"; # The default library database file to use.
      threaded = "yes";
      color = "yes";
      ui = {color = "yes";};
      per_disc_numbering = "no";
      original_date = "yes";
      import = {
        copy = false;
        incremental_skip_later = true;
        quiet_fallback = true;
        none_rec_action = "skip";
        duplicate_action = "remove";
      };
      chroma = {auto = "yes";};
      lastgenre = {
        auto = true;
        canonical = true;
        count = 5;
      };
      match = {ignored = ["missing_tracks" "unmatched_tracks"];};
      fetchart = {
        auto = "yes";
        cover_names = ["front" "back"];
        sources = ["filesystem" "coverart" "itunes" "amazon" "albumart" "wikipedia" "google"];
      };
      embedart = {
        auto = "yes";
        remove_art_file = "no";
      };
      lastfm = {user = "e7z0x1";};
      lyrics = {auto = "yes";};
      bbq = {fields = ["artist" "title" "album"];};
      include = ["${config.sops.secrets."musicbrainz.yaml".path}"];
    };
  };
}
