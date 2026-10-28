param([string]$Julia='')
$ErrorActionPreference='Stop'
$codeRoot=$PSScriptRoot

if (-not $Julia) {
    $juliaCommand = Get-Command julia -CommandType Application -ErrorAction SilentlyContinue
    if ($juliaCommand) {
        $Julia = $juliaCommand.Source
    } else {
        $juliaupRoot = Join-Path $env:USERPROFILE '.julia\juliaup'
        $installedJulia = Get-ChildItem -LiteralPath $juliaupRoot -Directory -Filter 'julia-*' -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            ForEach-Object { Join-Path $_.FullName 'bin\julia.exe' } |
            Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
            Select-Object -First 1
        if ($installedJulia) { $Julia = $installedJulia }
    }
}
if (-not $Julia) { throw 'Khong tim thay Julia. Chay: .\Run_all.ps1 -Julia DUONG_DAN_TOI_JULIA_EXE' }

function Run-JuliaStep([string[]]$JuliaArgs) {
    & $Julia @JuliaArgs
    if ($LASTEXITCODE -ne 0) { throw ('Julia failed: '+($JuliaArgs -join ' ')) }
}

Write-Output '=== KIEM TRA PHIEN BAN JULIA ==='
Run-JuliaStep @('--version')

Write-Output '=== CHAY CAC DEMO A01 DEN A08 ==='
for ($caseId=1; $caseId -le 8; $caseId++) {
    Write-Output ("`n>>> DEMO $caseId <<<")
    Run-JuliaStep @('--startup-file=no', '--history-file=no', (Join-Path $codeRoot 'demo.jl'), ("--ca=$caseId"))
}

Write-Output '=== CHAY BO KIEM THU THUAT TOAN ==='
Run-JuliaStep @('--startup-file=no', '--history-file=no', (Join-Path $codeRoot 'test\runtests.jl'))

Write-Output '=== CHAY KIEM THU NHAP DU LIEU ==='
Run-JuliaStep @('--startup-file=no', '--history-file=no', (Join-Path $codeRoot 'test\input_tests.jl'))

Write-Output '=== BANG INPUT / EXPECTED / ACTUAL / PASS ==='
Run-JuliaStep @('--startup-file=no', '--history-file=no', (Join-Path $codeRoot 'scripts\test_catalog.jl'))

Write-Output '=== CHAY BANG LAN VET VA KHAO SAT 3 QUY MO ==='
Run-JuliaStep @('--startup-file=no', '--history-file=no', (Join-Path $codeRoot 'scripts\trace_and_scales.jl'))

Write-Output '=== HOAN THANH TOAN BO CAC BUOC KIEM CHUNG! ==='
