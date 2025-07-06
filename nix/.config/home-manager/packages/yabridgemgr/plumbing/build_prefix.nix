{ runCommand, wineWowPackages, fetchzip, xorg, squashfsTools
, username ? "wineuser", plugins ? [ ] }:
runCommand "build_prefix" {
  nativeBuildInputs = [ wineWowPackages.full xorg.xorgserver squashfsTools ];
} (''
  mkdir $out
  export WINEPREFIX=$(pwd)/prefix
  mkdir home
  export HOME=$(pwd)/home

  Xvfb :8456 -screen 0 1024x768x16 &
  XVFB_PID=$!
  export DISPLAY=:8456.0
  export USER=${username}

  echo "--------------------"
  echo "Creating Wine Prefix"
  echo "--------------------"
  wine hostname

  echo "--------------------"
  echo "Installing Plugins"
  echo "--------------------"

'' + (builtins.foldl' (a: b: a + b + "\n") "" plugins) + ''

  echo "--------------------"
  echo "Waiting for wine to be done"
  echo "--------------------"
  wineserver --wait

  echo "--------------------"
  echo "Creating squashfs image"
  echo "--------------------"
  mksquashfs prefix $out/wineprefix.squashfs

  kill $XVFB_PID
'')
