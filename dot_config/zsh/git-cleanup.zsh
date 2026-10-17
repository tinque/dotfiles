# Git cleanup helpers: gone branches, merged worktrees, and their Docker environments.
#
#   gbgD / gbgd     delete local branches whose upstream is gone (-D / -d)
#   gwtclean [-n] [-f]
#                   remove worktrees whose branch is merged or gone, with their
#                   Docker containers, then delete the branch
#   gclean [-n] [-f]
#                   full repo cleanup: fetch/prune, merged worktrees, gone and
#                   merged leftover branches, orphaned worktree containers
#
#   -n  dry run, print what would be removed
#   -f  also remove dirty or locked worktrees

# Remote default branch, e.g. "origin/main".
_gc_default_ref() {
  local ref
  ref=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  if [[ -z $ref ]]; then
    for ref in origin/main origin/master; do
      git rev-parse --verify --quiet "$ref" >/dev/null && break
      ref=
    done
  fi
  [[ -n $ref ]] && print -r -- "$ref"
}

# Branches with a gone upstream that are not checked out in any worktree.
_gc_gone_branches() {
  git for-each-ref --format='%(refname:short)%09%(upstream:track)%09%(worktreepath)' refs/heads |
    awk -F'\t' '$2 == "[gone]" && $3 == "" {print $1}'
}

# Run a command, or only print it in dry-run mode ($_gc_dry).
_gc_run() {
  if (( _gc_dry )); then
    print -r -- "  [dry-run] $*"
  else
    "$@"
  fi
}

# Remove Docker containers created from a directory (compose working_dir label
# under $1), plus networks and volumes of compose projects left without containers.
_gc_docker_clean() {
  local dir=$1 main_project=$2
  command -v docker >/dev/null && docker info >/dev/null 2>&1 || return 0

  local -a ids projects
  local id project wd
  while IFS=$'\t' read -r id project wd; do
    [[ $wd == "$dir" || $wd == "$dir"/* ]] || continue
    ids+=("$id")
    [[ -n $project ]] && projects+=("$project")
  done < <(docker ps -a --no-trunc --format '{{.ID}}\t{{.Label "com.docker.compose.project"}}\t{{.Label "com.docker.compose.project.working_dir"}}')

  (( ${#ids} )) || return 0
  print -r -- "  docker: removing ${#ids} container(s)"
  _gc_run docker rm -f "${ids[@]}" >/dev/null

  for project in ${(u)projects}; do
    # The project is shared with another checkout (e.g. a fixed "-p" name): keep its resources.
    local -a left
    left=(${(f)"$(docker ps -aq --no-trunc --filter "label=com.docker.compose.project=$project")"})
    (( ${#${left:|ids}} )) && continue
    local -a nets vols
    nets=(${(f)"$(docker network ls -q --filter "label=com.docker.compose.project=$project")"})
    (( ${#nets} )) && _gc_run docker network rm "${nets[@]}" >/dev/null
    # Never drop the main checkout's volumes (its data survives "compose down").
    [[ $project == "$main_project" ]] && continue
    vols=(${(f)"$(docker volume ls -q --filter "label=com.docker.compose.project=$project")"})
    if (( ${#vols} )); then
      print -r -- "  docker: removing ${#vols} volume(s) of project $project"
      _gc_run docker volume rm "${vols[@]}" >/dev/null
    fi
  done
}

gbgD() {
  git fetch -p || return 1
  _gc_gone_branches | xargs -n 1 git branch -D
}

gbgd() {
  git fetch -p || return 1
  _gc_gone_branches | xargs -n 1 git branch -d
}

gwtclean() {
  local _gc_dry=0 force=0 opt OPTIND
  while getopts "nf" opt; do
    case $opt in
      n) _gc_dry=1 ;;
      f) force=1 ;;
      *) print -u2 "usage: gwtclean [-n] [-f]"; return 2 ;;
    esac
  done

  local main_wt default_ref current_wt
  main_wt=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0, 10); exit}')
  [[ -n $main_wt ]] || { print -u2 "gwtclean: not a git repository"; return 1; }
  default_ref=$(cd "$main_wt" && _gc_default_ref)
  [[ -n $default_ref ]] || { print -u2 "gwtclean: cannot resolve origin default branch"; return 1; }
  current_wt=$(git rev-parse --show-toplevel)
  local main_project=${${main_wt:t}:l}

  local -a paths heads branches locks
  local line wt="" head="" branch="" locked=""
  while IFS= read -r line; do
    case $line in
      "worktree "*) wt=${line#worktree } ;;
      "HEAD "*) head=${line#HEAD } ;;
      "branch "*) branch=${line#branch refs/heads/} ;;
      locked*) locked=1 ;;
      "")
        if [[ -n $wt && $wt != "$main_wt" ]]; then
          paths+=("$wt"); heads+=("$head"); branches+=("$branch"); locks+=("$locked")
        fi
        wt="" head="" branch="" locked=""
        ;;
    esac
  done < <(git -C "$main_wt" worktree list --porcelain; print)

  local i reason removed=0
  for i in {1..${#paths}}; do
    wt=${paths[i]} head=${heads[i]} branch=${branches[i]} locked=${locks[i]}
    reason=""
    if [[ -n $branch && $(git -C "$main_wt" for-each-ref --format='%(upstream:track)' "refs/heads/$branch") == "[gone]" ]]; then
      reason="upstream gone"
    elif git -C "$main_wt" merge-base --is-ancestor "$head" "$default_ref" 2>/dev/null; then
      reason="merged into $default_ref"
    fi
    [[ -n $reason ]] || continue

    local label=${branch:-detached ${head:0:8}}
    if [[ $wt == "$current_wt" ]]; then
      print -r -- "skip  $label ($reason): you are inside this worktree"
      continue
    fi
    if (( ! force )); then
      if [[ -n $locked ]]; then
        print -r -- "skip  $label ($reason): locked (active session?), use -f"
        continue
      fi
      if [[ -d $wt && -n $(git -C "$wt" status --porcelain 2>/dev/null) ]]; then
        print -r -- "skip  $label ($reason): uncommitted changes, use -f"
        continue
      fi
    fi

    print -r -- "clean $label ($reason) -> $wt"
    _gc_docker_clean "$wt" "$main_project"
    if (( force )); then
      _gc_run git -C "$main_wt" worktree remove --force --force "$wt"
    else
      _gc_run git -C "$main_wt" worktree remove "$wt"
    fi || continue
    [[ -n $branch ]] && _gc_run git -C "$main_wt" branch -D "$branch"
    (( removed++ ))
  done

  _gc_run git -C "$main_wt" worktree prune
  print -r -- "gwtclean: $removed worktree(s) removed"
}

gclean() {
  local _gc_dry=0 opt OPTIND
  local -a passthru
  while getopts "nf" opt; do
    case $opt in
      n) _gc_dry=1; passthru+=(-n) ;;
      f) passthru+=(-f) ;;
      *) print -u2 "usage: gclean [-n] [-f]"; return 2 ;;
    esac
  done

  local main_wt
  main_wt=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0, 10); exit}')
  [[ -n $main_wt ]] || { print -u2 "gclean: not a git repository"; return 1; }

  print "==> fetch"
  git -C "$main_wt" fetch -p || return 1

  print "==> worktrees"
  gwtclean "${passthru[@]}" || return 1

  local default_ref
  default_ref=$(cd "$main_wt" && _gc_default_ref)

  print "==> branches"
  local b
  for b in $(cd "$main_wt" && _gc_gone_branches); do
    print -r -- "delete $b (upstream gone)"
    _gc_run git -C "$main_wt" branch -D "$b"
  done
  # Local-only leftovers (no upstream) already contained in the default branch.
  if [[ -n $default_ref ]]; then
    local name upstream wtpath
    while IFS=$'\t' read -r name upstream wtpath; do
      [[ -z $upstream && -z $wtpath && $name != "${default_ref#origin/}" ]] || continue
      git -C "$main_wt" merge-base --is-ancestor "refs/heads/$name" "$default_ref" || continue
      print -r -- "delete $name (merged into $default_ref, no upstream)"
      _gc_run git -C "$main_wt" branch -D "$name"
    done < <(git -C "$main_wt" for-each-ref --format='%(refname:short)%09%(upstream)%09%(worktreepath)' refs/heads)
  fi

  print "==> docker orphans"
  # Containers created from a worktree directory of this repo that no longer exists.
  if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
    local wd
    for wd in ${(u)${(f)"$(docker ps -a --format '{{.Label "com.docker.compose.project.working_dir"}}')"}}; do
      [[ $wd == "$main_wt"/* && ! -d $wd ]] || continue
      print -r -- "orphan $wd"
      _gc_docker_clean "$wd" "${${main_wt:t}:l}"
    done
  fi

  print "==> done"
}
