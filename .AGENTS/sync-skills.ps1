[CmdletBinding(DefaultParameterSetName = 'Sync')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Sync')]
    [ValidateNotNullOrEmpty()]
    [string]$Message,

    [Parameter(Mandatory = $true, ParameterSetName = 'Install')]
    [switch]$Install
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$messagePath = $null

try {
    $gitCommand = Get-Command git -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $gitFolder = Split-Path -Parent $gitCommand.Source
    $gitRoot = Split-Path -Parent $gitFolder
    $gitExecPath = & $gitCommand.Source --exec-path
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to locate the Git installation.'
    }
    $gitRuntimeRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $gitExecPath))
    $shellCandidates = @(
        (Join-Path $gitRuntimeRoot 'bin/sh.exe'),
        (Join-Path $gitRuntimeRoot 'usr/bin/sh.exe'),
        (Join-Path $gitRoot 'bin/sh.exe'),
        (Join-Path $gitRoot 'usr/bin/sh.exe')
    )
    $pathShell = Get-Command sh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pathShell) {
        $shellCandidates += $pathShell.Source
    }
    $shellPath = $shellCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $shellPath) {
        throw 'A POSIX shell is required. Install Git for Windows or run the .sh entry point from Git Bash.'
    }

    if ($Install) {
        $entryPoint = (Join-Path $PSScriptRoot 'install-skill-sync.sh').Replace('\', '/')
        & $shellPath $entryPoint
    }
    else {
        if ([string]::IsNullOrWhiteSpace($Message)) {
            throw 'Message must contain a commit message.'
        }
        $messagePath = [IO.Path]::GetTempFileName()
        [IO.File]::WriteAllText($messagePath, $Message, (New-Object Text.UTF8Encoding($false)))
        $entryPoint = (Join-Path $PSScriptRoot 'skill-sync.sh').Replace('\', '/')
        $shellMessagePath = $messagePath.Replace('\', '/')
        & $shellPath $entryPoint 'sync' $shellMessagePath
    }
    if ($LASTEXITCODE -ne 0) {
        throw 'Skill synchronization failed. Resolve the reported issue and rerun the same command; existing commits are preserved.'
    }
}
catch {
    Write-Error -Message $_.Exception.Message -ErrorAction Continue
    exit 1
}
finally {
    if ($messagePath -and (Test-Path -LiteralPath $messagePath -PathType Leaf)) {
        Remove-Item -LiteralPath $messagePath
    }
}
