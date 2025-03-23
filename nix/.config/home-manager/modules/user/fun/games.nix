{pkgs, stable, ...}: {
  home.packages = with pkgs; [
    abuse # classic side-scrolling shooter customizable with LISP
    airshipper # for veloren voxel game
    angband # roguelike
    crawl # roguelike
    crawlTiles # roguelike
    endless-sky # space exploration game
    fheroes2 # free heroes 2 implementation
    flare # fantasy action RPG using the FLARE engine
    gnuchess # GNU chess engine
    gzdoom # open-source doom
    jazz2 # open source reimplementation of classic Jazz Jackrabbit 2 game
    nethack # roguelike
    shattered-pixel-dungeon # roguelike
    stable.brogue # roguelike
    stable.openmw # Unofficial open source engine reimplementation of the game Morrowind
    stable.unnethack # roguelike
    xaos # smooth fractal explorer
  ];
}
