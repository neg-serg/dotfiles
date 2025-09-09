**Quickstart**

- Требования: установлен `nix` с фичами `flakes`, установлен Home Manager (как flake).
- Клонировать в `~/.dotfiles` или любую директорию и инициализировать сабмодули.
  - `git clone --recursive git@github.com:neg-serg/dotfiles.git ~/.dotfiles`

**Nix/Home Manager**

- Проверка и формат:
  - `cd nix/.config/home-manager`
  - `just fmt` — запустить treefmt
  - `just check` — `nix flake check -L`
- Переключить профиль Home Manager:
  - Полный: `just hm-neg` (эквивалент `home-manager switch --flake .#neg`)
  - Лёгкий: `just hm-lite` (эквивалент `home-manager switch --flake .#neg-lite`)
  - IaC: по умолчанию установлен Terraform (full‑профиль). Проверка: `terraform -version`.
    - Переключить бэкенд на OpenTofu: `features.dev.iac.backend = "tofu"` в HM.
- Включить локальные git-хуки (опционально):
  - `just hooks-enable` (ставит `core.hooksPath` на `.githooks` этого flake)

**Bootstrap (новая машина)**

- Включить фичи Nix: добавить в `/etc/nix/nix.conf` или экспортировать при вызовах:
  - `experimental-features = nix-command flakes`
- Если Home Manager не установлен как flake:
  - `nix run home-manager/master -- init --switch`
- Затем перейти к разделу выше и выполнить `just hm-neg` или `hm-lite`.

**Где что лежит**

- Пользовательская конфигурация HM и flake: `nix/.config/home-manager`.
- Скрипты: `bin/`.
- Конфиги оболочек и приложений: `shell/`, `rofi/`, `wm/`, `nvim/`, и т.д.
- Подробное старое описание перенесено в `docs/legacy.md`.
