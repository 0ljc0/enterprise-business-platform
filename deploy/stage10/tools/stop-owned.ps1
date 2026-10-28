param([int]$ProcessId, [string]$RootPath)
$ErrorActionPreference='Stop'
$processInfo=Get-CimInstance Win32_Process -Filter "ProcessId=$ProcessId"
if ($null -eq $processInfo) { exit 0 }
$expected=Join-Path ([IO.Path]::GetFullPath($RootPath)) 'app.jar'
if ($processInfo.Name -notmatch '^java(w)?\.exe$' -or -not $processInfo.CommandLine.Contains($expected)) {
    throw 'PID ownership mismatch. Refusing to stop another process.'
}
Stop-Process -Id $ProcessId
