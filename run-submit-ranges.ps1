$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$exe = Join-Path $PSScriptRoot 'target\diag\victory.exe'
$game = Join-Path $root 'GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe'
$list = Join-Path $PSScriptRoot 'scripts\rt_off_hashes.txt'
foreach ($file in @($exe,$game,$list,(Join-Path $PSScriptRoot 'target\diag\D3D12\D3D12Core.dll'))) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Missing file: $file" }
}
$hashes = (Get-Content -LiteralPath $list -Raw).Trim() -split ','
if ($hashes.Count -ne 1034 -or ($hashes -notmatch '^[0-9a-fA-F]{16}$')) { throw 'Unexpected shader filter' }
$env:VICTORY_CACHE_DIR = Join-Path $env:LOCALAPPDATA 'VIctory-NVIDIA\cache'
$env:VICTORY_LOG = 'info'
$env:VICTORY_DYNAMIC_SLOTS = '524288'
$env:VICTORY_CARD_BUFFERS_MIN_MB = '1'
$env:VICTORY_CARD_BUFFERS_MB = '512'
$env:VICTORY_CARD_REHASH_RUNS = '1'
$env:VICTORY_JOIN_COPIES = '1'
$env:VICTORY_TEXTURE_NO_WAIT = '0'
$env:VICTORY_PIPELINE_BOOK = '1'
$env:VICTORY_TEXBACK_ASYNC = '1'
$env:VICTORY_RELAY = '1'
$env:VICTORY_CARD_STEPS = '0'
$env:VICTORY_SKIP_PIPELINES = $hashes -join ','
$env:VICTORY_CARD_ROOM_FOR_TARGETS_MB = '4096'
$env:VICTORY_NO_WATCHDOG = '1'
Remove-Item Env:VICTORY_WINDOWS_BAR_MB, Env:VICTORY_TEXTURE_BUDGET_MB -ErrorAction SilentlyContinue
$log = Join-Path $root ("victory-submit-ranges-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Write-Host "Log: $log"
$ErrorActionPreference = 'Continue'
& $exe run $game --execute --console series-x *> $log
Write-Host "Log: $log"
exit $LASTEXITCODE
