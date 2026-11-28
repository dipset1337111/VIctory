$ErrorActionPreference = 'Stop'
$root = 'C:\Project Leonida\BR-Mouse-DLSS'
Set-Location -LiteralPath $root
foreach ($file in 'victory.exe','Play.ps1','D3D12\D3D12Core.dll') {
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) { throw "Missing $root\$file" }
}
$env:VICTORY_CACHE_DIR = Join-Path $env:LOCALAPPDATA 'VIctory-BR-8bb5142d\cache'
$book = Join-Path $env:VICTORY_CACHE_DIR 'pipelines\early-pipelines.txt'
if (!(Test-Path -LiteralPath $book -PathType Leaf) -or (Get-Item -LiteralPath $book).Length -eq 0) {
    throw "No previously used pipeline list in $book. Keep the existing cache."
}
$stamp = Get-Date -Format yyyyMMdd-HHmmss
$warmLog = Join-Path $root "Warm-$stamp.log"
$memoryLog = Join-Path $root "Memory-$stamp.csv"
Write-Host 'Preparing previously used pipelines. Completed entries are remembered.'
$ErrorActionPreference = 'Continue'
& '.\victory.exe' warm --used --jobs 2 2>&1 | Tee-Object -FilePath $warmLog
$code = $LASTEXITCODE
if ($code -ne 0) { throw "Warm failed ($code). Log: $warmLog" }
Write-Host 'Warm finished. Starting the installed Play.ps1.'
$job = Start-Job -ArgumentList $memoryLog -ScriptBlock {
    param($path)
    while ($true) {
        $m = Get-CimInstance Win32_PerfFormattedData_PerfOS_Memory -ErrorAction SilentlyContinue
        if ($m) {
            [pscustomobject]@{
                time = (Get-Date -Format 'HH:mm:ss')
                available_mb = $m.AvailableMBytes
                pages_read_sec = $m.PagesInputPersec
                committed_mb = [math]::Round($m.CommittedBytes / 1MB)
            } | Export-Csv -LiteralPath $path -Append -NoTypeInformation
        }
        Start-Sleep -Seconds 2
    }
}
try { & '.\Play.ps1' }
finally {
    Stop-Job $job
    Remove-Job $job
    Write-Host "Warm: $warmLog"
    Write-Host "Memory: $memoryLog"
}
