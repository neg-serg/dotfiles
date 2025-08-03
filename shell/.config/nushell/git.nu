# Git aliases
def add [...args: string] { git add ...$args }
def checkout [...args: string] { git checkout ...$args }
def commit [...args: string] { git commit ...$args }
def gaa [] { git add --all }
def ga [] { git add }
def gama [] { git am --abort }
def gamc [] { git am --continue }
def gam [] { git am }
def gamscp [] { git am --show-current-patch }
def gams [] { git am --skip }
def gapa [] { git add --patch }
def gap [...args: string] { git apply ...$args }
def gapt [] { git apply --3way }
def gau [] { git add --update }
def gav [] { git add --verbose }
def gba [] { git branch -a }
def gbd [...args: string] { git branch -d ...$args }
def gbD [...args: string] { git branch -D ...$args }
def gb [] { git branch }
def gbl [...args: string] { git blame -b -w ...$args }
def gbnm [] { git branch --no-merged }
def gbr [] { git branch --remote }
def gbsb [] { git bisect bad }
def gbsg [] { git bisect good }
def gbs [] { git bisect }
def gbsr [] { git bisect reset }
def gbss [] { git bisect start }
def gca [] { git commit -v -a }
def 'gca!' [] { git commit -v -a --amend }
def gcam [...args: string] { git commit -a -m ...$args }
def 'gcan!' [] { git commit -v -a --no-edit --amend }
def 'gcans!' [] { git commit -v -a -s --no-edit --amend }
def gcas [] { git commit -a -s }
def gcasm [...args: string] { git commit -a -s -m ...$args }
def gcb [...args: string] { git checkout -b ...$args }
def gc [] { git commit -v }
def 'gc!' [] { git commit -v --amend }
def gclean [] { git clean -id }
def gcl [...args: string] { git clone --recurse-submodules ...$args }
def gcmsg [...args: string] { git commit -m ...$args }
def 'gcn!' [] { git commit -v --no-edit --amend }
def gco [...args: string] { git checkout ...$args }
def gcor [...args: string] { git checkout --recurse-submodules ...$args }
def gcount [] { git shortlog -sn }
def gcpa [] { git cherry-pick --abort }
def gcpc [] { git cherry-pick --continue }
def gcp [...args: string] { git cherry-pick ...$args }
def gcs [...args: string] { git commit -S ...$args }
def gcsm [...args: string] { git commit -s -m ...$args }
def gdca [] { git diff --cached }
def gdct [] { let tag = (git rev-list --tags --max-count=1 | str trim); git describe --tags $tag }
def gdcw [] { git diff --cached --word-diff }
def gd [] { git diff -w -U0 --word-diff-regex=[^[:space:]] }
def gds [] { git diff --staged }
def gdup [] { git diff @{upstream} }
def gdw [] { git diff --word-diff }
def gfa [] { git fetch --all --prune }
def gf [] { git fetch }
def gfo [] { git fetch origin }
def ggf [] { git push --force origin (git rev-parse --abbrev-ref HEAD | str trim) }
def ggfl [] { git push --force-with-lease origin (git rev-parse --abbrev-ref HEAD | str trim) }
def ggl [] { git pull origin (git rev-parse --abbrev-ref HEAD | str trim) }
def ggp [] { git push origin (git rev-parse --abbrev-ref HEAD | str trim) }
def ggsup [] { git branch --set-upstream-to=origin/(git rev-parse --abbrev-ref HEAD | str trim) }
def ggu [] { git pull --rebase origin (git rev-parse --abbrev-ref HEAD | str trim) }
def gignored [] { git ls-files -v | lines | where {|l| $l | str starts-with 'h' } }
def gignore [...args: string] { git update-index --assume-unchanged ...$args }
def gl [] { git pull }
def gma [] { git merge --abort }
def gm [...args: string] { git merge ...$args }
def gmtl [] { git mergetool --no-prompt }
def gpd [] { git push --dry-run }
def 'gpf!' [] { git push --force }
def gpf [] { git push --force-with-lease }
def gp [] { git push }
def gpr [] { git pull --rebase }
def gpristine [] { git reset --hard; git clean -dffx }
def gpsup [] { git push --set-upstream origin (git rev-parse --abbrev-ref HEAD | str trim) }
def gpv [] { git push -v }
def gra [...args: string] { git remote --add ...$args }
def grba [] { git rebase --abort }
def grbc [] { git rebase --continue }
def grb [] { git rebase }
def grbi [] { git rebase -i }
def grbo [...args: string] { git rebase --onto ...$args }
def grbs [] { git rebase --skip }
def grev [...args: string] { git revert ...$args }
def gr [] { git remote }
def grh [] { git reset }
def grhh [] { git reset --hard }
def grmc [...args: string] { git rm --cached ...$args }
def grm [...args: string] { git rm ...$args }
def grs [...args: string] { git restore ...$args }
def grup [] { git remote update }
def gs [] { git status --short -b }
def gsh [...args: string] { git show ...$args }
def gsi [] { git submodule init }
def gsps [] { git show --pretty=short --show-signature }
def gstaa [] { git stash apply }
def gsta [] { git stash push }
def gstall [] { git stash --all }
def gstc [] { git stash clear }
def gstd [] { git stash drop }
def gstl [] { git stash list }
def gstp [] { git stash pop }
def gsts [] { git stash show --text }
def gstu [] { git stash --include-untracked }
def gsu [] { git submodule update }
def gswc [...args: string] { git switch -c ...$args }
def gsw [...args: string] { git switch ...$args }
def gts [...args: string] { git tag -s ...$args }
def gu [] { git reset @ -- }
def gupa [] { git pull --rebase --autostash }
def gupav [] { git pull --rebase --autostash -v }
def gup [] { git pull --rebase }
def gupv [] { git pull --rebase -v }
def gwch [] { git whatchanged -p --abbrev-commit --pretty=medium }
def gx [] { git reset --hard @ }
def pull [] { git pull }
def push [] { git push }
def resolve [] { git mergetool --tool=nwim }
def stash [] { git stash }
def status [] { git status }
def uncommit [] { git reset --soft HEAD^ }
