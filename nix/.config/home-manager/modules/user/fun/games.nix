{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.abuse # classic side-scrolling shooter customizable with LISP
    pkgs.airshipper # for veloren voxel game
    pkgs.angband # roguelike
    pkgs.brogue # roguelike
    pkgs.crawl # roguelike
    pkgs.crawlTiles # roguelike
    pkgs.endless-sky # space exploration game
    pkgs.fheroes2 # free heroes 2 implementation
    pkgs.flare # fantasy action RPG using the FLARE engine
    pkgs.gnuchess # GNU chess engine
    pkgs.gzdoom # open-source doom
    pkgs.jazz2 # open source reimplementation of classic Jazz Jackrabbit 2 game
    pkgs.nethack # roguelike
    pkgs.openmw # Unofficial open source engine reimplementation of the game Morrowind
    pkgs.shattered-pixel-dungeon # roguelike
    # pkgs.unnethack # roguelike
    pkgs.xaos # smooth fractal explorer
  ];
}
