# Root justfile delegating to HM justfile

_hm_justfile := "nix/.config/home-manager/justfile"

fmt:
    just --justfile {{_hm_justfile}} fmt

check:
    just --justfile {{_hm_justfile}} check

hm-neg:
    just --justfile {{_hm_justfile}} hm-neg

hm-lite:
    just --justfile {{_hm_justfile}} hm-lite

