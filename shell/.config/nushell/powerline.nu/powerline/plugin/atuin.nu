export-env {
    power register atuin {|bg|
        let theme = $env.NU_POWER_CONFIG.atuin.theme
        if ($env.ATUIN_SESSION? | is-not-empty) {
            [$bg '']
        } else {
            ['#504945' '']
        }
    } {
        theme: {
            on: white
        }
    } --when { which atuin | is-not-empty }
}
