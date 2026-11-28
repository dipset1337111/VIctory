param([string]$Game)
$ErrorActionPreference = 'Stop'
$root = 'C:\Project Leonida'
$old = Join-Path $root 'br-prison-walk'
Set-Location -LiteralPath $PSScriptRoot
if (!(Test-Path '.\D3D12\D3D12Core.dll')) {
    Copy-Item -LiteralPath (Join-Path $old 'D3D12') -Destination . -Recurse -ErrorAction Stop
}
$knownGame = Join-Path $root 'GTA6.Xbox.v1.0.2.1-CYBERLEEK\game_scarlett_master.exe'
if (!$Game -and (Test-Path -LiteralPath $knownGame)) { $Game = $knownGame }
if (!$Game -and $env:VICTORY_GAME_DIR) {
    $candidate = Join-Path $env:VICTORY_GAME_DIR 'game_scarlett_master.exe'
    if (Test-Path -LiteralPath $candidate) { $Game = $candidate }
}
if (!$Game) {
    $games = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'game_scarlett_master.exe' -ErrorAction SilentlyContinue | Where-Object { Test-Path -LiteralPath (Join-Path $_.DirectoryName 'MicrosoftGame.config') })
    if ($games.Count -eq 1) { $Game = $games[0].FullName }
    else { $games.FullName; $Game = (Read-Host 'Full path to game_scarlett_master.exe').Trim('"') }
}
$exe = Get-Item -LiteralPath $Game
$env:VICTORY_GAME_DIR = $exe.DirectoryName
$env:VICTORY_CACHE_DIR = Join-Path $env:LOCALAPPDATA 'VIctory-BR-8bb5142d\cache'
$env:VICTORY_STREAMLINE_DIR = Join-Path $root 'NVIDIA-Test\NVIDIA-Test\nvidia-sdk\Streamline\bin\x64'
if (!(Test-Path (Join-Path $env:VICTORY_STREAMLINE_DIR 'sl.interposer.dll'))) {
    $sdk = Get-ChildItem -LiteralPath $root -Filter sl.interposer.dll -Recurse -File -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.DirectoryName 'sl.dlss.dll') } | Select-Object -First 1
    if ($sdk) { $env:VICTORY_STREAMLINE_DIR = $sdk.DirectoryName }
}
$env:VICTORY_DLSS = '1'
$env:VICTORY_FRAMEGEN = '0'
$env:VICTORY_DLSS_MODE = 'quality'
$env:VICTORY_MOUSE_CAPTURE = '1'
$env:VICTORY_MOUSE_WARP = '1'
$env:VICTORY_UPSCALER = '6'
$env:VICTORY_RT_MISS = '1'
$env:VICTORY_RELAY = '2'
$env:VICTORY_CARD_STEPS = '2'
$env:VICTORY_THIN = '1'
$env:VICTORY_DISPLAY_MODE = '1920x1080'
$env:VICTORY_PIPELINE_BOOK = '1'
$env:VICTORY_MEMORY_CARD_MB = '1024'
$env:VICTORY_AMBIENT = 'constant:0.1'
$env:VICTORY_AMBIENT_AIR = '0.8'
$env:VICTORY_CARD_BUFFERS_MIN_KB = '64'
$env:VICTORY_PORT_CONSTANTS = '1'
$env:VICTORY_RELAY_COPY = '1'
$env:VICTORY_TEXTURE_STAGE_MS = '16'
$env:VICTORY_NO_WATCHDOG = '1'
$env:VICTORY_PIPELINE_WORKERS = '4'
$env:VICTORY_UPLOAD_AHEAD = '1'
$env:VICTORY_JOIN_COPIES = '1'
$env:VICTORY_JOIN_PARTS = '8'
$env:VICTORY_LOG = 'info'
Remove-Item Env:\VICTORY_ASYNC_SUBMIT, Env:\VICTORY_CARD_REHASH_RUNS -ErrorAction SilentlyContinue
$log = Join-Path $PSScriptRoot ("BR-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))
Write-Host "Log: $log"
$ErrorActionPreference = 'Continue'
& '.\victory.exe' run $exe.FullName --console series-s --execute *> $log
exit $LASTEXITCODE
