{pkgs, config, ...}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    abuse # classic side-scrolling shooter customizable with LISP
    airshipper # for veloren voxel game
    angband # roguelike
    brogue # roguelike
    crawl # roguelike
    crawlTiles # roguelike
    endless-sky # space exploration game
    fheroes2 # free heroes 2 implementation
    flare # fantasy action RPG using the FLARE engine
    gnuchess # GNU chess engine
    gzdoom # open-source doom
    jazz2 # open source reimplementation of classic Jazz Jackrabbit 2 game
    nethack # roguelike
    openmw # Unofficial open source engine reimplementation of the game Morrowind
    shattered-pixel-dungeon # roguelike
    # unnethack # roguelike
    xaos # smooth fractal explorer
  ]);
}
