_hm_justfile := "nix/.config/home-manager/justfile"
_hm_dir := "nix/.config/home-manager"

fmt:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} fmt

check:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} check

lint:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} lint

hm-neg:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} hm-neg

hm-lite:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} hm-lite

clean-caches:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} clean-caches

