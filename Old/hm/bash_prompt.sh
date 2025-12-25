# originally by lm3m @ https://gist.github.com/lm3m/d6118ffc350f68807e5019b61c43f3a8
# Very, very fast, only requiring a couple of fork()s (and no forking at all to determine the current git branch)

if [[ "$USER" == "root" ]]
then
  export PS1="\e[1;31m\]\u \[\e[1;33m\]\w\[\e[0m\]";
else
  export PS1="\[\e[1;33m\]\w\[\e[0m\]";
fi

# 100% pure Bash (no forking) function to determine the name of the current git branch
gitbranch() {
  export GITBRANCH=""

  local repo=""
  local gitdir=""
  [[ ! -z "$repo" ]] && gitdir="$repo/.git"

  # If we don't have a last seen git repo, or we are in a different directory
  if [[ -z "$repo" || "$PWD" != "$repo"* || ! -e "$gitdir" ]]; then
    local cur="$PWD"
    while [[ ! -z "$cur" ]]; do
      if [[ -f "$cur"/.git ]]; then
        repo=$(<"$cur/.git")
        repo=${repo:8}
        gitdir="$repo"
        break
      fi
      if [[ -d "$cur/.git" ]]; then
        repo="$cur"
        gitdir="$cur/.git"
        break
      fi
      cur="${cur%/*}"
    done
  fi

  if [[ -z "$gitdir" ]]; then
    unset _GITBRANCH_LAST_REPO
    return 0
  fi
  export _GITBRANCH_LAST_REPO="${repo}"
  local head=""
  local branch=""
  read head < "$gitdir/HEAD"
  case "$head" in
    ref:*)
      branch="${head##*/}"
      ;;
    "")
      branch=""
      ;;
    *)
      branch="d:${head:0:7}"
      ;;
  esac
  if [[ -z "$branch" ]]; then
    return 0
  fi
  export GITBRANCH="$branch"
}

PS1_green='\[\e[32m\]'
PS1_blue='\[\e[34m\]'
PS1_reset='\[\e[0m\]'
_mk_prompt() {
  # Change the window title of X terminals
  case $TERM in
    xterm*|rxvt*|Eterm)
      echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"
      ;;
    screen)
      echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"
      ;;
  esac

  # Un-screw virtualenv stuff
  if [[ ! -z "${_OLD_VIRTUAL_PS1-}" ]]; then
    export PS1="$_OLD_VIRTUAL_PS1"
    unset _OLD_VIRTUAL_PS1
  fi

  if [[ -z "${_MK_PROMPT_ORIG_PS1-}" ]]; then
    export _MK_PROMPT_ORIG_PS1="$PS1"
  fi

  local prefix=()
  local jobcount="$(jobs -p | wc -l)"
  if [[ "$jobcount" -gt 0 ]]; then
    local job="${jobcount##* } job"
    [[ "$jobcount" -gt 1 ]] && job="${job}s"
    prefix=("$prefix$job")
  fi

  gitbranch
  if [[ ! -z "$GITBRANCH" ]]; then
    if [[ ! -z "$prefix" ]]; then
      prefix="$prefix:"
    fi
    prefix="$prefix${PS1_green}$GITBRANCH${PS1_reset}"
  fi

  local virtualenv="${VIRTUAL_ENV##*/}"
  if [[ ! -z "$virtualenv" ]]; then
    if [[ ! -z "$prefix" ]]; then
      prefix="$prefix:"
    fi
    prefix="$prefix${PS1_blue}$virtualenv${PS1_reset}"
  fi

  PS1="$_MK_PROMPT_ORIG_PS1"

  if [ "$SSH_CONNECTION" ]; then
    PS1="@\h:$PS1"
  else
    PS1="$PS1"
  fi

  if [[ ! -z "$prefix" ]]; then
    PS1="${prefix[@]}:$PS1"
  fi

  PS1="[$PS1] "

  export PS1
}
export PROMPT_COMMAND=_mk_prompt
