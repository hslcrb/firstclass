# Skill repositories

`limstandards` and `limsflex` are private repositories mounted as Git submodules
inside `hslcrb/firstclass`:

| Local path | Private repository | Branch |
| --- | --- | --- |
| `.AGENTS/skills/limstandards` | [hslcrb/limstandards](https://github.com/hslcrb/limstandards) | `main` |
| `.AGENTS/skills/limsflex` | [hslcrb/limsflex](https://github.com/hslcrb/limsflex) | `main` |

## Clone and initialize

Authenticate with a GitHub account that can access all three repositories.

```powershell
git clone --recurse-submodules https://github.com/hslcrb/firstclass.git
```

For an existing clone, initialize only these submodules:

```powershell
git submodule update --init -- .AGENTS/skills/limstandards .AGENTS/skills/limsflex
```

Submodule initialization and updates normally leave a detached HEAD at the
commit recorded by the parent. Before editing or syncing, explicitly attach
each submodule to `main`:

```powershell
git -C .AGENTS/skills/limstandards switch main
git -C .AGENTS/skills/limsflex switch main
```

If a local `main` branch does not exist, create it from `origin/main` instead:

```powershell
git -C .AGENTS/skills/limstandards switch --track -c main origin/main
git -C .AGENTS/skills/limsflex switch --track -c main origin/main
```

The parent must also be on `main`. Do not run `git init` in a skill directory;
the submodule already owns its Git metadata.

## Commit and push together

From the parent repository, use Windows PowerShell 5.1 or later:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .AGENTS/sync-skills.ps1 -Message "Edit: update skill standards"
```

The script validates paths, branches, conflicts, and both configured and
effective GitHub remote URLs before making changes, including URL rewrites.
It stages and commits **all changes inside each skill**,
pushes both skill repositories, then commits and pushes their parent pointers
along with `.gitmodules`, this document, and the sync script. Existing local
commits are also pushed when there are no new file changes.

Unrelated parent changes are excluded. Unrelated **staged** parent changes
stop the script; commit or unstage them first. Unrelated unstaged or untracked
parent files remain untouched. The script does not switch branches or change
Git configuration.

## Retry after a failure

Three repository pushes are sequential, not atomic. If a later push fails,
an earlier repository may already have been updated. Local commits remain
intact, and parent pointers are committed only after both skill pushes succeed.

Resolve the reported Git, authentication, network, or non-fast-forward issue,
then rerun the same command. Rerunning pushes existing commits without creating
duplicate commits when nothing changed. A parent push failure can leave its
local commit waiting to be pushed. The script never force-pushes, resets, or
cleans a repository.
