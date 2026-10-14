[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Message
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Invoke-SkillGit {
    param(
        [string]$Repository,
        [string[]]$Arguments,
        [string]$Operation,
        [int[]]$AllowedExitCodes = @(0)
    )

    # Windows PowerShell represents native stderr as ErrorRecord objects.
    # Capture it without letting a successful Git warning terminate the script.
    $ErrorActionPreference = 'Continue'
    $output = @(& git -C $Repository @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    if ($AllowedExitCodes -notcontains $exitCode) {
        # Raw Git output can include credentials embedded in remote URLs.
        throw "Git $Operation failed (exit $exitCode). Local commits are preserved. Resolve the Git, authentication, or network issue and rerun this script."
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output | ForEach-Object { $_.ToString() })
    }
}

function Get-SkillGitText {
    param([string]$Repository, [string[]]$Arguments, [string]$Operation)

    $result = Invoke-SkillGit $Repository $Arguments $Operation
    return ($result.Output -join "`n")
}

function Test-SkillRemoteUrl {
    param([string]$Url, [string]$Name)

    $repositoryName = [regex]::Escape($Name)
    $pattern = "^(https://github\.com/hslcrb/$repositoryName(?:\.git)?/?|git@github\.com:hslcrb/$repositoryName(?:\.git)?|ssh://git@github\.com/hslcrb/$repositoryName(?:\.git)?/?)$"
    return ($Url -match $pattern)
}

function Assert-SkillRepository {
    param([string]$Repository, [string]$Name)

    if (-not (Test-Path -LiteralPath $Repository -PathType Container)) {
        throw "$Name is missing. Initialize the skill submodules before syncing."
    }
    $topLevel = Get-SkillGitText $Repository @('rev-parse', '--show-toplevel') "worktree validation for $Name"
    $expectedPath = [IO.Path]::GetFullPath($Repository).TrimEnd([char[]]'\/')
    $actualPath = [IO.Path]::GetFullPath($topLevel).TrimEnd([char[]]'\/')
    if (-not [string]::Equals($expectedPath, $actualPath, [StringComparison]::OrdinalIgnoreCase)) {
        throw "$Name is not an initialized repository at its expected path. Initialize the submodules before syncing."
    }

    $branch = Invoke-SkillGit $Repository @('symbolic-ref', '--quiet', '--short', 'HEAD') "branch validation for $Name" @(0, 1)
    if ($branch.ExitCode -ne 0 -or ($branch.Output -join "`n") -cne 'main') {
        throw "$Name must be on branch main with an attached HEAD. Switch branches explicitly before syncing."
    }
    $conflicts = Get-SkillGitText $Repository @('diff', '--name-only', '--diff-filter=U') "conflict validation for $Name"
    if ($conflicts) {
        throw "$Name has unresolved conflicts. Resolve them before syncing."
    }
    foreach ($operationPath in @('MERGE_HEAD', 'CHERRY_PICK_HEAD', 'REVERT_HEAD', 'rebase-merge', 'rebase-apply', 'sequencer')) {
        $gitPath = Get-SkillGitText $Repository @('rev-parse', '--git-path', $operationPath) "operation validation for $Name"
        if (-not [IO.Path]::IsPathRooted($gitPath)) {
            $gitPath = Join-Path $Repository $gitPath
        }
        if (Test-Path -LiteralPath $gitPath) {
            throw "$Name has a Git operation in progress. Finish it before syncing."
        }
    }

    $fetchUrls = Invoke-SkillGit $Repository @('config', '--get-all', 'remote.origin.url') "origin validation for $Name" @(0, 1)
    if ($fetchUrls.Output.Count -ne 1 -or -not (Test-SkillRemoteUrl $fetchUrls.Output[0] $Name)) {
        throw "$Name origin must point to the expected hslcrb repository on GitHub."
    }
    $pushUrls = Invoke-SkillGit $Repository @('config', '--get-all', 'remote.origin.pushurl') "push origin validation for $Name" @(0, 1)
    if ($pushUrls.Output.Count -gt 1 -or ($pushUrls.Output.Count -eq 1 -and -not (Test-SkillRemoteUrl $pushUrls.Output[0] $Name))) {
        throw "$Name push origin must point to the expected hslcrb repository on GitHub."
    }

    # Git URL rewrites can change the actual target while raw origin stays valid.
    $effectiveFetchUrls = Invoke-SkillGit $Repository @('remote', 'get-url', '--all', 'origin') "effective origin validation for $Name"
    if ($effectiveFetchUrls.Output.Count -ne 1 -or -not (Test-SkillRemoteUrl $effectiveFetchUrls.Output[0] $Name)) {
        throw "$Name effective origin must point to the expected hslcrb repository on GitHub. Check Git URL rewrite settings."
    }
    $effectivePushUrls = Invoke-SkillGit $Repository @('remote', 'get-url', '--push', '--all', 'origin') "effective push origin validation for $Name"
    if ($effectivePushUrls.Output.Count -ne 1 -or -not (Test-SkillRemoteUrl $effectivePushUrls.Output[0] $Name)) {
        throw "$Name effective push origin must point to the expected hslcrb repository on GitHub. Check Git URL rewrite settings."
    }
}

function Assert-ParentIndex {
    $staged = Invoke-SkillGit $root @('diff', '--cached', '--name-only', '--no-renames') 'parent staged path validation'
    foreach ($path in $staged.Output) {
        if ($managedPaths -cnotcontains $path) {
            throw 'The parent repository has unrelated staged changes. Commit or unstage those changes before syncing; this script leaves them intact.'
        }
    }
}

function Save-SkillCommit {
    param([string]$Repository, [string]$Name, [string[]]$Paths)

    Invoke-SkillGit $Repository (@('add', '--all', '--') + $Paths) "staging for $Name" | Out-Null
    if ($Name -eq 'firstclass') {
        Assert-ParentIndex
    }
    $difference = Invoke-SkillGit $Repository @('diff', '--cached', '--quiet', '--exit-code', '--') "commit comparison for $Name" @(0, 1)
    if ($difference.ExitCode -eq 1) {
        # PowerShell 5.1 can remove quotes from native command arguments.
        # A UTF-8 file preserves the message, including non-ASCII and newlines.
        $messagePath = [IO.Path]::GetTempFileName()
        try {
            [IO.File]::WriteAllText($messagePath, $Message, (New-Object Text.UTF8Encoding($false)))
            Invoke-SkillGit $Repository @('commit', '--file', $messagePath, '--cleanup=verbatim', '--') "commit for $Name" | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath $messagePath -PathType Leaf) {
                Remove-Item -LiteralPath $messagePath
            }
        }
        Write-Host "Committed $Name."
    }
}

try {
    if ([string]::IsNullOrWhiteSpace($Message)) {
        throw 'Message must contain a commit message.'
    }
    if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
        throw 'Git is required to sync the skill repositories.'
    }

    $root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
    $skillNames = @('limstandards', 'limsflex')
    $managedPaths = @(
        '.AGENTS/skills/limstandards',
        '.AGENTS/skills/limsflex',
        '.gitmodules',
        '.AGENTS/sync-skills.ps1',
        '.AGENTS/SKILL-REPOS.md'
    )

    # Validate every repository and the entire parent index before any mutation.
    Assert-SkillRepository $root 'firstclass'
    Assert-ParentIndex
    if (-not (Test-Path -LiteralPath (Join-Path $root '.gitmodules') -PathType Leaf)) {
        throw 'The parent repository is missing .gitmodules.'
    }
    $submoduleEntries = Invoke-SkillGit $root @('config', '--file', '.gitmodules', '--get-regexp', '^submodule\..*\.path$') 'submodule path validation'
    foreach ($name in $skillNames) {
        $path = ".AGENTS/skills/$name"
        $entry = Get-SkillGitText $root @('ls-files', '--stage', '--', $path) "gitlink validation for $name"
        if ($entry -cnotmatch ('^160000 [0-9a-f]+ 0\t' + [regex]::Escape($path) + '$')) {
            throw "$name must be a registered, conflict-free Git submodule."
        }
        $matchingKeys = @()
        foreach ($line in $submoduleEntries.Output) {
            $parts = $line -split '\s+', 2
            if ($parts.Count -eq 2 -and $parts[1] -ceq $path) {
                $matchingKeys += ($parts[0] -replace '\.path$', '.url')
            }
        }
        if ($matchingKeys.Count -ne 1) {
            throw "$name must have exactly one matching path in .gitmodules."
        }
        $moduleUrl = Get-SkillGitText $root @('config', '--file', '.gitmodules', '--get', $matchingKeys[0]) "submodule origin validation for $name"
        if (-not (Test-SkillRemoteUrl $moduleUrl $name)) {
            throw "$name .gitmodules URL must point to its expected hslcrb repository on GitHub."
        }
        Assert-SkillRepository (Join-Path $root $path) $name
    }

    foreach ($name in $skillNames) {
        Save-SkillCommit (Join-Path $root ".AGENTS/skills/$name") $name @('.')
    }
    foreach ($name in $skillNames) {
        Invoke-SkillGit (Join-Path $root ".AGENTS/skills/$name") @('push', 'origin', 'HEAD:refs/heads/main') "push for $name" | Out-Null
        Write-Host "Pushed $name."
    }

    # Publish parent pointers only after both referenced child commits are remote.
    Assert-ParentIndex
    Save-SkillCommit $root 'firstclass' $managedPaths
    Invoke-SkillGit $root @('push', '--recurse-submodules=check', 'origin', 'HEAD:refs/heads/main') 'push for firstclass' | Out-Null
    Write-Host 'Pushed firstclass. All three repositories are synced.'
}
catch {
    Write-Error -Message $_.Exception.Message -ErrorAction Continue
    exit 1
}
