{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "hy-de-panel";
  version = "0.8.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rubiin";
    repo = "HyDePanel";
    rev = "v${version}";
    hash = "sha256-yirSv2/+ZqBjLuhoBdY6AgBswk1p8EdYcNfIf0w1jxU=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    click
    fabric
    loguru
    psutil
    pycairo
    pygobject
    rlottie-python
    setproctitle
  ];

  pythonImportsCheck = [
    "hy_de_panel"
  ];

  meta = {
    description = "Modular panel written on fabric";
    homepage = "https://github.com/rubiin/HyDePanel.git";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "hy-de-panel";
  };
}
