param([Parameter(Mandatory)][string]$Game)

$ErrorActionPreference = 'Stop'
$gameFile = Get-Item -LiteralPath $Game
if ($gameFile.PSIsContainer) { throw 'Select the game executable.' }
$exe = Join-Path $PSScriptRoot 'victory.exe'
foreach ($path in @($exe, (Join-Path $PSScriptRoot 'D3D12\D3D12Core.dll'))) {
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing: $path" }
}
$settings = @{
    VICTORY_GAME_DIR = $gameFile.DirectoryName
    VICTORY_CACHE_DIR = Join-Path $env:LOCALAPPDATA 'VIctory-BR-8bb5142d\cache'
    VICTORY_RT_MISS = '1'
    VICTORY_RELAY = '2'
    VICTORY_CARD_STEPS = '2'
    VICTORY_THIN = '0'
    VICTORY_DISPLAY_MODE = '1920x1080'
    VICTORY_PIPELINE_BOOK = '1'
    VICTORY_MEMORY_CARD_MB = '1024'
    VICTORY_UPSCALER = '6'
    VICTORY_AMBIENT = 'constant:0.1'
    VICTORY_AMBIENT_AIR = '0.8'
    VICTORY_CARD_BUFFERS_MIN_KB = '64'
    VICTORY_PORT_CONSTANTS = '1'
    VICTORY_NO_WATCHDOG = '1'
    VICTORY_PIPELINE_WORKERS = '4'
    VICTORY_LOG = 'info'
}
$log = Join-Path $PSScriptRoot ("victory-checkpoint-{0}.log" -f (Get-Date -Format yyyyMMdd-HHmmss))
$before = @{}
Push-Location -LiteralPath $PSScriptRoot
try {
    foreach ($name in (@($settings.Keys) + @('VICTORY_ASYNC_SUBMIT', 'VICTORY_CARD_REHASH_RUNS'))) {
        $before[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        [Environment]::SetEnvironmentVariable($name, $settings[$name], 'Process')
    }
    Write-Host "Log: $log"
    $ErrorActionPreference = 'Continue'
    & $exe run $gameFile.FullName --console series-s --execute *> $log
    Write-Host "Exit code: $LASTEXITCODE"
} finally {
    foreach ($name in $before.Keys) {
        [Environment]::SetEnvironmentVariable($name, $before[$name], 'Process')
    }
    Pop-Location
    Write-Host "Log: $log"
}
