export-env {
    power register ai {|bg|
        let c = $env.NU_POWER_CONFIG.ai
        let t = $c.theme
        if ($env.AI_SESSION? | is-not-empty) {
            let s = term size | get columns
            let i = if $s >= $c.width {
                let sn = ai-session
                $"(ansi $t.info)($sn.model)@($sn.provider)"
            } else {
                ''
            }
            [$bg $'($i)(ansi $t.session)✨($env.AI_SESSION)']
        } else {
            ['#504945' null]
        }
    } {
        width: 120
        theme: {
            info: xpurplea
            session: grey
        }
    }
}
