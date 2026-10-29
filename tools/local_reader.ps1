<#
Tek Tribe World: local folder reader (read-only). Runs on the player's own PC.
It only reads files, never changes, moves or deletes them, and never uses the network.
Output per file: date, sha8, kind, xp. Titles, paths and contents never leave the PC (metadata zone).
XP is a game number only. It never feeds scores, ranks or money without a server-side
or owner-approved check.
Usage: powershell -ExecutionPolicy Bypass -File local_reader.ps1 -Root <folder> [-Out <file.json>] [-Days 30]
#>
param(
  [Parameter(Mandatory=$true)][string]$Root,
  [string]$Out = "",
  [int]$Days = 30
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Root -PathType Container)) { throw "Root folder not found" }
$exts = @('.md','.txt','.json','.yaml','.yml')
# XP per kind, inside the schema caps (note 0-10, hash_seal 0-15, run_log 0-5, fix 0-25, quest_done 0-30)
$xp = @{ note = 2; hash_seal = 5; run_log = 1; fix = 5; quest_done = 10 }
function Get-Kind([string]$name) {
  $n = $name.ToUpperInvariant()
  if ($n -match 'QUEST') { return 'quest_done' }
  if ($n -match '(^|_)FIX') { return 'fix' }
  if ($n -match 'SEAL|HASH') { return 'hash_seal' }
  if ($n -match '(^|_)(LOG|RUN)') { return 'run_log' }
  return 'note'
}
$since = (Get-Date).AddDays(-$Days)
$events = Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $exts -contains $_.Extension.ToLowerInvariant() -and $_.LastWriteTime -ge $since } |
  Sort-Object LastWriteTime |
  Select-Object -Last 2000 |
  ForEach-Object {
    $k = Get-Kind $_.BaseName
    [pscustomobject]@{
      date = $_.LastWriteTime.ToString('yyyy-MM-dd')
      sha8 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.Substring(0,8).ToLowerInvariant()
      kind = $k
      xp   = $xp[$k]
    }
  }
$json = ConvertTo-Json -InputObject @($events) -Depth 3
if ($Out) { Set-Content -LiteralPath $Out -Value $json -Encoding UTF8 } else { $json }
