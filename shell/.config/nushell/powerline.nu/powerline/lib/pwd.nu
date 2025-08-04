def 'path parents' [] {
    let p = $in | path expand | path split
    mut r = []
    for i in ($p | length | $in - 1)..0 {
        $r ++= [{ a: ($p | slice 0..$i), b: ($p | slice ($i + 1)..) }]
    }
    $r
}

def 'find vcs' [] {
    for i in ($in | path parents) {
        if ($i.a | append '.git' | path join | path exists) {
            return $i
        }
    }
}

export def "pwd_abbr" [bg] {
    let vcso = $env.PWD | find vcs
    let no_vcs = $vcso | is-empty
    let vcs = if $no_vcs {
        [$env.PWD]
    } else {
        [($vcso.a | path join), ($vcso.b | path join)]
    }
    let relative = do -i { $vcs.0 | path relative-to $env.HOME }
    let in_home = ($relative | describe -d).type == 'string'

    let cwd = if $in_home {
        if ($relative | is-empty) { '~' } else { $'~(char separator)($relative)' }
    } else {
        $vcs.0
    }

    mut dir_comp = ($cwd | path split)
    let mpl = if ($env.NU_POWER_FRAME == 'default') { 2 } else { 4 }
    if ($dir_comp | length) + ($vcso.b? | default [] | length) > 5 {
        let first = $dir_comp | first
        let last = $dir_comp | last
        let body = $dir_comp
        | slice 1..-2
        | each {|x| $x | str substring ..<$mpl }
        $dir_comp = ([$first $body $last] | flatten)
    }
    let dir_comp = $dir_comp | path join

    let theme = $env.NU_POWER_CONFIG.pwd

    let tm = if $in_home { ansi $theme.default } else { ansi $theme.out_home }
    let fg = if $no_vcs {
        $"($tm)($dir_comp)"
    } else {
        if ($vcs.1 | is-empty) {
            $"($tm)($dir_comp)"
        } else {
            [$"($tm)($dir_comp)(ansi $theme.vcs)" $"($vcs.1)"]
            | path join
        }
    }
    [$bg $fg]
}
