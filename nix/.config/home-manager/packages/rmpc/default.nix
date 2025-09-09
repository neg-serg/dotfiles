{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  cmake,
}:
rustPlatform.buildRustPackage rec {
  pname = "rmpc";
  version = "master";

  src = fetchFromGitHub {
    owner = "mierak";
    repo = "rmpc";
    rev = "master";
    # nix-prefetch-url --unpack https://github.com/mierak/rmpc/archive/master.tar.gz
    sha256 = "1515zxaamca8i1vvsiw5lwb6wjfmdz8ifh45z8m558w0xmx33dn1";
  };

  cargoHash = "sha256-ZHajqTkdw0wkNVws0fr9HFcC3JF1B6TuwP5CTGw/3nQ=";

  checkFlags = [
    # Test currently broken, needs to be removed. See https://github.com/mierak/rmpc/issues/254
    "--skip=core::scheduler::tests::interleaves_repeated_and_scheduled_jobs"
  ];

  nativeBuildInputs = [
    installShellFiles # install manpages and completions
    pkg-config # discover C libs for build
    cmake # build helper for native deps
  ];

  env.VERGEN_GIT_DESCRIBE = version;

  postInstall = ''
    installManPage target/man/rmpc.1

    installShellCompletion --cmd rmpc \
      --bash target/completions/rmpc.bash \
      --fish target/completions/rmpc.fish \
      --zsh target/completions/_rmpc
  '';

  meta = {
    changelog = "https://github.com/mierak/rmpc/releases/tag/${src.rev}";
    description = "TUI music player client for MPD with album art support via kitty image protocol";
    homepage = "https://mierak.github.io/rmpc/";
    license = lib.licenses.bsd3;
    longDescription = ''
      Rusty Music Player Client is a beautiful, modern and configurable terminal-based Music Player
      Daemon client. It was inspired by ncmpcpp and aims to provide an alternative with support for
      album art through kitty image protocol without any ugly hacks. It also features ranger/lf
      inspired browsing of songs and other goodies.
    '';
    maintainers = with lib.maintainers; [
      donovanglover
      bloxx12
    ];
    mainProgram = "rmpc";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
