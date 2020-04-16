# shellcheck shell=bash

type -t kubectl >/dev/null || return

function _k8s_kubectl_get_context_completion() {
    local ctx
    COMPREPLY=()
    while read -r ctx; do
        [[ $ctx == "${2}"* ]] && COMPREPLY+=("${ctx}")
    done < <(kubectl config get-contexts -o name)
}

function _k8s_kubectl_apply_files() {
    local cmd=($1)
    shift
    local i
    for i in "$@"; do
        cmd+=('-f' "${i}")
    done
    # shellcheck disable=SC2046
    kubectl "${cmd[@]}"
}

function _k8s_select_context() {
    local menu=$1
    local sel=()
    local cc
    cc=$(kubectl config current-context)
    local dfl=''
    local dfli=''
    local idx=0
    local i
    while read -r i; do
        local c=''
        idx=$(( idx + 1 ))
        [[ $i == "${cc}" ]] && c=1
        if [[ -n $menu ]]; then
            sel+=("${i}")
            if [[ -n $c ]]; then
                dfl=$i
                dfli=$idx
            fi
        else
            [[ -n $c ]] && echo -n '* ' || echo -n '  '
            echo "${i}"
        fi
    done < <(kubectl config get-contexts -o name)
    [[ -n $menu ]] || return
    local PS3
    PS3='Context'
    [[ -n $dfl ]] && PS3="${PS3} (currently ${dfli})"
    PS3="${PS3}? "
    local n
    select n in "${sel[@]}"; do
        if [[ -n $n ]]; then
            kubectl config use-context "${n}"
            break
        fi
    done
}

# Apply a set of k8s configs, but delete them in reverse order first.
function kdaf() {
    local backwards=()
    for i in $(seq $# 1); do
        backwards+=("${!i}")
    done
    _k8s_kubectl_apply_files delete "${backwards[@]}"
    _k8s_kubectl_apply_files apply "$@"
}

# Manipulate the current context.
function kcc() {
    local usage='
Usage: kcc [<name>|-h|-l|-m]

With no parameters specified, display the name of the current context.

<name> - switch to the context <name>
-h - Display this help
-l - List available contexts
-m - Select the current context from a menu
'
    case "$1" in
        -l) _k8s_select_context ;;
        -m) _k8s_select_context 1 ;;
        -*) echo "${usage}" >&2 ;;
        '') kubectl config current-context ;;
        *) kubectl config use-context "$@"
    esac
}

# Completion for kcc is the list of available contexts.
complete -o default -F _k8s_kubectl_get_context_completion kcc

# Alias 'k' to 'kubectl' and apply kubectl completion to it, if available.
alias k=kubectl
type -t __start_kubectl >/dev/null && complete -o default -F __start_kubectl k

# Apply or delete a list of config files, without requiring -f before each one.
alias kaf="_k8s_kubectl_apply_files apply"
alias kdf="_k8s_kubectl_apply_files delete"
