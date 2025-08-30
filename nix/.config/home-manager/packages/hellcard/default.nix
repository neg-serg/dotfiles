with import <nixpkgs> {}; # Подключаем nixpkgs

  stdenv.mkDerivation rec {
    pname = "hellcard";
    version = "unstable-2025-04-23";

    src = fetchFromGitHub {
      owner = "danihek";
      repo = "hellcard";
      rev = "62fd97f7c71b52cdb630cb55ac18b9b9fc07ce45";
      hash = "sha256-LZfz2NZ8ibf1Pdut7vP+Lgj+8HpugvctxIuSI76LHcc=";
    };

    # Убедитесь, что все необходимые зависимости указаны здесь
    buildInputs = [
      # Пример: добавить зависимости, если они есть
      # cmake
      # pkg-config
    ];

    # Опционально: фазы сборки, если нужны кастомные команды
    buildPhase = ''
      make  # или другие команды сборки
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp hellcard $out/bin/  # убедитесь, что бинарник имеет правильное имя
    '';

    meta = {
      description = "";
      homepage = "https://github.com/danihek/hellcard";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  }
