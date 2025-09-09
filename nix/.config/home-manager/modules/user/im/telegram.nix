{python3Packages}:
python3Packages.buildPythonApplication rec {
  pname = "telegram-send";
  version = "0.25";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-5s2gAaieHNAjF/zQRWKIoM3VqlaXDexvvYOtmvHbBaw=";
  };

  propagatedBuildInputs = with python3Packages; [
    python-telegram-bot # Telegram Bot API client
    colorama # terminal colors in CLI output
    appdirs # XDG/app dirs discovery
  ];
}
