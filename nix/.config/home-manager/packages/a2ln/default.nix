{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "a2ln-server";
  version = "1.1.14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "patri9ck";
    repo = "a2ln-server";
    rev = version;
    hash = "sha256-6SVAFeVB/YpddJhSHgjIF43i2BAmFFADMwlygp9IrSU=";
  };

  build-system = [
    python3.pkgs.setuptools # build backend (setup.py)
  ];

  dependencies = with python3.pkgs; [
    pillow # image processing (icons/screens)
    pygobject # GObject/GTK bindings
    pyzmq # ZeroMQ messaging
    qrcode # QR code generation
  ];

  pythonImportsCheck = [
    "a2ln"
  ];

  meta = {
    description = "A way to display Android phone notifications on Linux (Server";
    homepage = "https://github.com/patri9ck/a2ln-server";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [];
    mainProgram = "a2ln-server";
  };
}
