<#
Tek Tribe World: MiniBot.si pocket #1 (OFFLINE, read-only). Same pattern as tools/local_reader.ps1.
Reads local files only. Never writes outside -OutDir, never uses the network, never writes to E:.
Shows: next roadmap step, last local git commit, gate status. Missing values show 'unknown'.
Usage: powershell -ExecutionPolicy Bypass -File minibot_pocket.ps1 -Roots <path-to-minibot-repo> [-GameRoot <path-to-this-repo>] [-OutDir <dir inside pockets/>]
#>
param(
  [Parameter(Mandatory=$true)][string[]]$Roots,
  [string]$GameRoot = (Join-Path $PSScriptRoot '..\..'),
  [string]$OutDir = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
if ($OutDir -match '^[Ee]:') { throw 'Never write to E:' }
$OutFull = [System.IO.Path]::GetFullPath($OutDir).TrimEnd('\','/')
$Allowed = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot)).TrimEnd('\','/')
if ($OutFull -ne $Allowed -and -not $OutFull.StartsWith($Allowed + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'OutDir must be inside the pockets folder' }
$U = 'unknown'
function Esc([string]$s) { [System.Net.WebUtility]::HtmlEncode($s) }

# 1. Next roadmap step (from MINIBOT_ROADMAP.md: '## Next stone', else first bullet of '## Next')
$road = $null
foreach ($r in $Roots) { if (Test-Path -LiteralPath $r) {
  $f = Get-ChildItem -LiteralPath $r -Recurse -File -Filter 'MINIBOT_ROADMAP.md' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($f) { $road = $f; break } } }
$next = $U; $roadDate = $U
if ($road) {
  $roadDate = $road.LastWriteTime.ToString('yyyy-MM-dd')
  $lines = Get-Content -LiteralPath $road.FullName
  $sec = $null; $stone = @(); $nextB = @()
  foreach ($l in $lines) {
    if ($l -match '^##\s+(.+)$') { $sec = $Matches[1].Trim(); continue }
    if ($sec -eq 'Next stone' -and $l.Trim() -and -not $l.StartsWith('-')) { $stone += $l.Trim() }
    if ($sec -eq 'Next' -and $l -match '^-\s+(.+)$') { $nextB += $Matches[1].Trim() }
  }
  if ($stone.Count) { $next = $stone[0] } elseif ($nextB.Count) { $next = $nextB[0] }
}

# 2. Last commit from local git (first root that is inside a git work tree)
$commit = [ordered]@{ sha8 = $U; date = $U; message = $U }
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) { foreach ($r in $Roots) { if (Test-Path -LiteralPath $r) {
  $o = $null; $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  try { $o = & git -C $r log -1 --format='%H|%ad|%s' --date=short -- . 2>$null } catch { $o = $null }
  $ErrorActionPreference = $prev
  if ($LASTEXITCODE -eq 0 -and $o) { $p = "$o".Split('|',3); $commit = [ordered]@{ sha8 = $p[0].Substring(0,8); date = $p[1]; message = $p[2] }; break } } } }

# 3. Gate status: M5 / M5b count as PASS only if a REMOTE log with 'RESULT: PASS' exists locally
function Gate([string]$pat) {
  if (-not (Test-Path -LiteralPath $GameRoot)) { return $U }
  $hit = Get-ChildItem -LiteralPath $GameRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $pat } |
    Where-Object { Select-String -LiteralPath $_.FullName -Pattern 'RESULT: PASS' -Quiet }
  if ($hit) { 'PASS' } else { 'closed (no remote PASS log found)' }
}
$m5 = Gate '^m5_remote.*log'
$m5b = Gate '^m5b_remote.*log'
$si = if ($m5 -eq 'PASS' -and $m5b -eq 'PASS') { 'unlockable (needs owner yes)' } else { 'LOCKED' }

$snap = [ordered]@{
  pocket = 'MiniBot.si'; mode = 'OFFLINE'; generated = (Get-Date).ToString('yyyy-MM-dd HH:mm')
  roadmap = [ordered]@{ next_step = $next; file_date = $roadDate }
  last_commit = $commit
  gates = [ordered]@{ M5 = $m5; M5b = $m5b; si_messaging = $si }
}
$json = ConvertTo-Json $snap -Depth 4
Set-Content -LiteralPath (Join-Path $OutDir 'minibot_pocket.json') -Value $json -Encoding UTF8

$html = @"
<!doctype html><html><head><meta charset="utf-8"><meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'">
<title>MiniBot.si pocket (OFFLINE)</title><style>
body{background:#14121c;color:#e8e2d0;font-family:Georgia,serif;max-width:640px;margin:40px auto;padding:0 16px}
.b{display:inline-block;background:#5a1e1e;color:#ffd7d7;padding:4px 10px;border-radius:4px;font:bold 14px monospace;letter-spacing:2px}
.c{border:1px solid #6b5a2e;border-radius:8px;padding:12px 16px;margin:14px 0;background:#1d1a28}
h1{color:#d9b85c}h2{margin:0 0 6px;font-size:15px;color:#b9a46a;text-transform:uppercase}.u{color:#888;font-style:italic}code{color:#9fd}
</style></head><body>
<span class="b">OFFLINE POCKET</span><h1>MiniBot.si</h1>
<p class="u">Read from local files on this PC. Not connected. Generated $(Esc $snap.generated).</p>
<div class="c"><h2>Next roadmap step</h2>$(Esc $next)<br><small>roadmap file date: $(Esc $roadDate)</small></div>
<div class="c"><h2>Last commit</h2><code>$(Esc $commit.sha8)</code> &middot; $(Esc $commit.date)<br>$(Esc $commit.message)</div>
<div class="c"><h2>Gates</h2>M5: $(Esc $m5)<br>M5b: $(Esc $m5b)<br>SI messaging: <b>$(Esc $si)</b></div>
</body></html>
"@
Set-Content -LiteralPath (Join-Path $OutDir 'minibot_pocket.html') -Value $html -Encoding UTF8
Write-Output $json
