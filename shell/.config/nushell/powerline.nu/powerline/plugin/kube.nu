### kubernetes
export def ensure-cache [cache path action] {
    let ts = (do -i { ls ($path | into glob) | sort-by modified | reverse | get 0.modified })
    if ($ts | is-empty) { return false }
    let tc = (do -i { ls $cache | get 0.modified })
    if not (($cache | path exists) and ($ts < $tc)) {
        mkdir ($cache | path dirname)
        do $action | save -f $cache
    }
    open $cache
}

def "kube ctx" [] {
    mut cache = ''
    mut file = ''
    if ($env.KUBECONFIG? | is-empty) {
        $cache = ([$nu.cache-dir 'power'] | path join 'kube.json')
        $file = $"($env.HOME)/.kube/config"
    } else {
        $cache = ([$nu.cache-dir 'power'] | path join $"kube-($env.KUBECONFIG | str replace -a '/' ':').json")
        $file = $env.KUBECONFIG
    }
    if not ($file | path exists) { return null }
    ensure-cache $cache $file {
        do -i {
            kubectl config get-contexts
            | from ssv -a
            | where {|x| $x.CURRENT | is-not-empty }
            | get 0
        }
    }
}

export-env {
    power register kube {|bg|
        let ctx = kube ctx
        if ($ctx | is-empty) {
            [$bg ""]
        } else {
            let c = $env.NU_POWER_CONFIG.kube
            let t = $c.theme
            let p = if $c.reverse {
                $"(ansi $t.namespace)($ctx.NAMESPACE)(ansi $t.separator)($c.separator)(ansi $t.context)($ctx.NAME)"
            } else {
                $"(ansi $t.context)($ctx.NAME)(ansi $t.separator)($c.separator)(ansi $t.namespace)($ctx.NAMESPACE)"
            }
            [$bg $"($p)"]
        }
    } {
        theme: {
            context: cyan
            separator: purple
            namespace: yellow
        }
        reverse: false
        separator: ':'
    } --when { which kubectl | is-not-empty }
}
