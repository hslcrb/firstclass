#!/bin/sh
# Portable root workflow. No force-push, reset, clean, merge, or hidden background fetch.
set -euf

die() { printf 'Skill sync: %s\n' "$*" >&2; exit 1; }
START_DIR=$(pwd -P)
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
LOCAL_ENV=$(git rev-parse --local-env-vars)
if [ -n "${GIT_INDEX_FILE-}" ]; then
    case "$GIT_INDEX_FILE" in /*|[A-Za-z]:/*) ;; *) GIT_INDEX_FILE="$START_DIR/$GIT_INDEX_FILE"; export GIT_INDEX_FILE ;; esac
fi

# Hooks export repository-local Git variables. Child commands must not inherit
# the root's Git directory or temporary index; root staging must retain its index.
root_git() (
    for env_name in $LOCAL_ENV; do
        [ "$env_name" = GIT_INDEX_FILE ] || unset "$env_name"
    done
    git -C "$ROOT" "$@"
)
repo_git() (
    repo_path=$1; shift
    for env_name in $LOCAL_ENV; do unset "$env_name"; done
    git -C "$repo_path" "$@"
)
repo_for() {
    case "$1" in firstclass) printf '%s\n' "$ROOT" ;; *) printf '%s/.AGENTS/skills/%s\n' "$ROOT" "$1" ;; esac
}
valid_url() {
    case "$1" in
        "https://github.com/hslcrb/$2"|"https://github.com/hslcrb/$2.git"|"https://github.com/hslcrb/$2/"|"https://github.com/hslcrb/$2.git/"|"git@github.com:hslcrb/$2"|"git@github.com:hslcrb/$2.git"|"ssh://git@github.com/hslcrb/$2"|"ssh://git@github.com/hslcrb/$2.git"|"ssh://git@github.com/hslcrb/$2/"|"ssh://git@github.com/hslcrb/$2.git/") return 0 ;;
        *) return 1 ;;
    esac
}
validate_repo() {
    validation_name=$1
    validation_repo=$(repo_for "$validation_name")
    [ -d "$validation_repo" ] || die "$validation_name is missing; run the installer."
    actual_root=$(repo_git "$validation_repo" rev-parse --show-toplevel) || die "$validation_name is not initialized."
    actual_root=$(CDPATH= cd -- "$actual_root" && pwd -P)
    [ "$actual_root" = "$validation_repo" ] || die "$validation_name is not a repository at its expected path."
    branch=$(repo_git "$validation_repo" symbolic-ref --quiet --short HEAD || :)
    if [ "${2-}" != install ]; then
        [ "$branch" = main ] || die "$validation_name must have an attached main branch; run the installer for a fresh clone."
    elif [ -n "$branch" ] && [ "$branch" != main ]; then
        die "$validation_name is on $branch; switch to main explicitly."
    fi
    [ -z "$(repo_git "$validation_repo" ls-files --unmerged)" ] || die "$validation_name has unresolved conflicts."
    for operation in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply sequencer; do
        operation_path=$(repo_git "$validation_repo" rev-parse --git-path "$operation")
        case "$operation_path" in /*|[A-Za-z]:/*) ;; *) operation_path="$validation_repo/$operation_path" ;; esac
        [ ! -e "$operation_path" ] || die "$validation_name has an unfinished Git operation."
    done
    raw_url=$(repo_git "$validation_repo" config --get-all remote.origin.url || :)
    valid_url "$raw_url" "$validation_name" || die "$validation_name origin must be its expected hslcrb GitHub repository."
    raw_push=$(repo_git "$validation_repo" config --get-all remote.origin.pushurl || :)
    [ -z "$raw_push" ] || valid_url "$raw_push" "$validation_name" || die "$validation_name push origin is unexpected."
    effective_url=$(repo_git "$validation_repo" remote get-url --all origin)
    valid_url "$effective_url" "$validation_name" || die "$validation_name effective fetch target is unexpected; check URL rewrite settings."
    effective_push=$(repo_git "$validation_repo" remote get-url --push --all origin)
    valid_url "$effective_push" "$validation_name" || die "$validation_name effective push target is unexpected; check URL rewrite settings."
}
validate_modules() {
    [ -f "$ROOT/.gitmodules" ] || die '.gitmodules is missing.'
    module_entries=$(root_git config --file .gitmodules --get-regexp '^submodule\..*\.path$') || die '.gitmodules has no registered submodules.'
    for module_name in limstandards limsflex; do
        module_path=".AGENTS/skills/$module_name"
        entry=$(root_git ls-files --stage -- "$module_path")
        expected_suffix=$(printf ' 0\t%s' "$module_path")
        case "$entry" in "160000 "*"$expected_suffix") ;; *) die "$module_name must be a conflict-free registered gitlink." ;; esac
        case "$entry" in *'
'*) die "$module_name has multiple index entries." ;; esac
        match_count=0; module_key=
        old_ifs=$IFS; IFS='
'
        for module_line in $module_entries; do
            line_key=${module_line%% *}; line_path=${module_line#* }
            if [ "$line_path" = "$module_path" ]; then
                match_count=$((match_count + 1)); module_key=${line_key%.path}.url
            fi
        done
        IFS=$old_ifs
        [ "$match_count" -eq 1 ] || die "$module_name must have exactly one .gitmodules entry."
        module_url=$(root_git config --file .gitmodules --get-all "$module_key")
        valid_url "$module_url" "$module_name" || die "$module_name has an unexpected .gitmodules URL."
    done
}
validate_all() {
    validate_repo firstclass
    validate_modules
    validate_repo limstandards "${1-}"
    validate_repo limsflex "${1-}"
}
fetch_all() {
    for fetch_name in firstclass limstandards limsflex; do
        printf 'Fetching %s...\n' "$fetch_name"
        fetch_repo=$(repo_for "$fetch_name")
        repo_git "$fetch_repo" fetch --prune --no-recurse-submodules origin +refs/heads/main:refs/remotes/origin/main || die "fetch failed for $fetch_name; local work is preserved."
        # Git's built-in recursive push checks use configured fetch mappings.
        # Keep existing mappings and add main only when no usual mapping covers it.
        fetch_specs=$(repo_git "$fetch_repo" config --get-all remote.origin.fetch || :)
        main_mapping=no
        old_ifs=$IFS; IFS='
'
        for fetch_spec in $fetch_specs; do
            case "$fetch_spec" in
                '+refs/heads/*:refs/remotes/origin/*'|'refs/heads/*:refs/remotes/origin/*'|'+refs/heads/main:refs/remotes/origin/main'|'refs/heads/main:refs/remotes/origin/main') main_mapping=yes ;;
            esac
        done
        IFS=$old_ifs
        if [ "$main_mapping" = no ]; then
            repo_git "$fetch_repo" config --local --add remote.origin.fetch +refs/heads/main:refs/remotes/origin/main
        fi
    done
}
check_remote_state() {
    for state_name in firstclass limstandards limsflex; do
        state_repo=$(repo_for "$state_name")
        repo_git "$state_repo" show-ref --verify --quiet refs/remotes/origin/main || die "$state_name origin/main is missing after fetch."
        repo_git "$state_repo" merge-base --is-ancestor refs/remotes/origin/main HEAD || die "$state_name is behind or diverged from origin/main. Reconcile it explicitly and retry; no local work was discarded."
    done
}
save_children() {
    for child_name in limstandards limsflex; do
        child_repo=$(repo_for "$child_name")
        repo_git "$child_repo" add --all -- . || die "staging failed for $child_name."
        if repo_git "$child_repo" diff --cached --quiet --exit-code; then continue; fi
        if [ -n "${MESSAGE_FILE-}" ]; then
            repo_git "$child_repo" commit --file "$MESSAGE_FILE" --cleanup=verbatim -- || die "commit failed for $child_name; staged work is preserved."
        else
            repo_git "$child_repo" commit --message "Edit: update $child_name skill" -- || die "commit failed for $child_name; staged work is preserved."
        fi
    done
    root_git add -- .AGENTS/skills/limstandards .AGENTS/skills/limsflex || die 'staging parent gitlinks failed.'
}
require_clean_children() {
    for clean_name in limstandards limsflex; do
        [ -z "$(repo_git "$(repo_for "$clean_name")" status --porcelain --untracked-files=all)" ] || die "$clean_name has uncommitted work. Commit from the firstclass root before pushing."
    done
}
check_tree_pointers() {
    pointer_tree=$1
    for pointer_name in limstandards limsflex; do
        pointer_entry=$(root_git ls-tree "$pointer_tree" -- ".AGENTS/skills/$pointer_name")
        set -- $pointer_entry
        [ "$#" -eq 4 ] && [ "$1" = 160000 ] && [ "$2" = commit ] || die "$pointer_name is not a gitlink in the pushed parent tree."
        child_head=$(repo_git "$(repo_for "$pointer_name")" rev-parse HEAD)
        [ "$3" = "$child_head" ] || die "the parent tree does not record the current $pointer_name commit. Commit from the firstclass root and retry."
    done
}
push_children() {
    for push_name in limstandards limsflex; do
        repo_git "$(repo_for "$push_name")" push --recurse-submodules=no origin HEAD:refs/heads/main || die "push failed for $push_name. Local commits are preserved; retry the root push."
    done
}
managed_path() {
    case "$1" in
        .AGENTS/skills/limstandards|.AGENTS/skills/limsflex|.gitmodules|.gitattributes|.AGENTS/skill-sync.sh|.AGENTS/install-skill-sync.sh|.AGENTS/sync-skills.ps1|.AGENTS/SKILL-REPOS.md|.AGENTS/hooks/pre-commit|.AGENTS/hooks/pre-push) return 0 ;;
        *) return 1 ;;
    esac
}
require_managed_index() {
    staged_paths=$(root_git -c core.quotePath=false diff --cached --name-only --no-renames)
    old_ifs=$IFS; IFS='
'
    for staged_path in $staged_paths; do
        managed_path "$staged_path" || die 'the parent index contains unrelated staged changes; commit or unstage them before explicit sync.'
    done
    IFS=$old_ifs
}
stage_managed() {
    for managed_file in .AGENTS/skills/limstandards .AGENTS/skills/limsflex .gitmodules .gitattributes .AGENTS/skill-sync.sh .AGENTS/install-skill-sync.sh .AGENTS/sync-skills.ps1 .AGENTS/SKILL-REPOS.md .AGENTS/hooks/pre-commit .AGENTS/hooks/pre-push; do
        if [ -e "$ROOT/$managed_file" ] || root_git ls-files --error-unmatch -- "$managed_file" >/dev/null 2>&1; then
            root_git add --all -- "$managed_file" || die "staging failed for $managed_file."
        fi
    done
}
install_hooks() {
    existing_hooks=$(root_git config --get core.hooksPath || :)
    case "$existing_hooks" in
        '')
            default_hooks=$(root_git rev-parse --git-path hooks)
            case "$default_hooks" in /*|[A-Za-z]:/*) ;; *) default_hooks="$ROOT/$default_hooks" ;; esac
            for hook_name in pre-commit pre-push; do
                [ ! -f "$default_hooks/$hook_name" ] || die "an existing $hook_name hook is active. Integrate the tracked hook before installing; it was not overwritten."
            done
            ;;
        .AGENTS/hooks) ;;
        *) die 'core.hooksPath already points elsewhere. Integrate the tracked hooks before installing; the existing setting was not overwritten.' ;;
    esac
    for hook_name in pre-commit pre-push; do
        [ -f "$ROOT/.AGENTS/hooks/$hook_name" ] || die "$hook_name tracked hook is missing."
    done
    chmod +x "$ROOT/.AGENTS/hooks/pre-commit" "$ROOT/.AGENTS/hooks/pre-push"
    root_git config --local core.hooksPath .AGENTS/hooks
    root_git config --local fetch.recurseSubmodules on-demand
    root_git config --local push.recurseSubmodules on-demand
    root_git config --local push.default simple
    root_git config --local branch.main.remote origin
    root_git config --local branch.main.merge refs/heads/main
    root_git config --local branch.main.pushRemote origin
}

COMMAND=${1-}; [ "$#" -eq 0 ] || shift
case "$COMMAND" in
    install)
        validate_repo firstclass
        validate_modules
        # Initialize only missing children: never rewind an existing worktree.
        for install_name in limstandards limsflex; do
            install_repo=$(repo_for "$install_name")
            if [ ! -e "$install_repo/.git" ]; then
                root_git submodule update --init -- ".AGENTS/skills/$install_name" || die "$install_name initialization failed; check access to its private repository."
            fi
        done
        validate_all install
        fetch_all
        for install_name in limstandards limsflex; do
            install_repo=$(repo_for "$install_name")
            install_branch=$(repo_git "$install_repo" symbolic-ref --quiet --short HEAD || :)
            if [ -z "$install_branch" ]; then
                [ -z "$(repo_git "$install_repo" status --porcelain --untracked-files=all)" ] || die "$install_name has changes on a detached HEAD; attach it manually first."
                install_head=$(repo_git "$install_repo" rev-parse HEAD)
                if repo_git "$install_repo" show-ref --verify --quiet refs/heads/main; then
                    [ "$(repo_git "$install_repo" rev-parse refs/heads/main)" = "$install_head" ] || die "$install_name main differs from its detached commit; reconcile it explicitly."
                    repo_git "$install_repo" checkout main
                else
                    repo_git "$install_repo" checkout -b main
                fi
            fi
            # Explicit settings also work when a clone's fetch refspec omits main.
            repo_git "$install_repo" config --local branch.main.remote origin
            repo_git "$install_repo" config --local branch.main.merge refs/heads/main
        done
        install_hooks
        printf '%s\n' 'Installed root commit/push hooks. Each operation fetches all three repositories first.'
        ;;
    pre-commit)
        [ "${LIM_SKILL_SYNC_ACTIVE-}" != 1 ] || exit 0
        export LIM_SKILL_SYNC_ACTIVE=1
        validate_all
        fetch_all
        check_remote_state
        save_children
        ;;
    pre-push)
        [ "${LIM_SKILL_SYNC_ACTIVE-}" != 1 ] || exit 0
        [ "${1-}" = origin ] || die 'automatic synchronization supports pushing origin main from the firstclass root.'
        valid_url "${2-}" firstclass || die 'the root push target is unexpected.'
        export LIM_SKILL_SYNC_ACTIVE=1
        validate_all
        push_head=$(root_git rev-parse HEAD)
        push_count=0
        while read -r local_ref local_sha remote_ref remote_sha; do
            [ -n "$local_ref" ] || continue
            push_count=$((push_count + 1))
            case "$local_ref" in refs/heads/main|HEAD) ;; *) die 'automatic synchronization supports only the current main branch.' ;; esac
            [ "$remote_ref" = refs/heads/main ] && [ "$local_sha" = "$push_head" ] || die 'automatic synchronization supports only the current main branch pushed to origin/main.'
        done
        [ "$push_count" -le 1 ] || die 'push only main for automatic skill synchronization.'
        fetch_all
        check_remote_state
        require_clean_children
        check_tree_pointers "$push_head"
        push_children
        ;;
    sync)
        [ "$#" -eq 1 ] || die 'usage: sh .AGENTS/skill-sync.sh sync <UTF-8-message-file>'
        MESSAGE_FILE=$1
        [ -s "$MESSAGE_FILE" ] || die 'the commit message file is missing or empty.'
        case "$MESSAGE_FILE" in /*|[A-Za-z]:/*) ;; *) MESSAGE_FILE="$START_DIR/$MESSAGE_FILE" ;; esac
        export LIM_SKILL_SYNC_ACTIVE=1
        validate_all
        require_managed_index
        fetch_all
        check_remote_state
        save_children
        push_children
        stage_managed
        require_managed_index
        if ! root_git diff --cached --quiet --exit-code; then
            root_git commit --file "$MESSAGE_FILE" --cleanup=verbatim -- || die 'parent commit failed; local commits and staging are preserved.'
        fi
        require_clean_children
        check_tree_pointers "$(root_git rev-parse HEAD)"
        root_git push --recurse-submodules=check origin HEAD:refs/heads/main || die 'parent push failed; local commits are preserved. Retry sync or the root push.'
        printf '%s\n' 'Synced limstandards, limsflex, and firstclass.'
        ;;
    *) die 'usage: skill-sync.sh {install|pre-commit|pre-push|sync <UTF-8-message-file>}' ;;
esac
