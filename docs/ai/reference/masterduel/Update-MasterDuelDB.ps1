$ErrorActionPreference = 'Stop'

$url = 'https://dawnbrandbots.github.io/yaml-yugi/cards.json'
$repoRoot = Split-Path $PSScriptRoot -Parent
$target = Join-Path $repoRoot 'masterduel\cards.json'
$dir = Split-Path $target -Parent
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$temp = "$target.new"

try {
    Invoke-WebRequest -Uri $url -OutFile $temp -UseBasicParsing

    $data = @(Get-Content -LiteralPath $temp -Raw -Encoding UTF8 |
        ConvertFrom-Json -ErrorAction Stop)

    if ($data.Count -lt 10000) {
        throw "取得件数が異常に少ない（$($data.Count)件）。破損・欠損を疑い差し替えを中止します。"
    }

    $newHash = (Get-FileHash $temp -Algorithm SHA256).Hash

    if ((Test-Path $target) -and
        ((Get-FileHash $target -Algorithm SHA256).Hash -eq $newHash)) {
        Write-Host '変更なし：最新版を保持しています。'
        return
    }

    Move-Item -LiteralPath $temp -Destination $target -Force

    Write-Host "更新完了：$($data.Count) 件のデータ"
}
finally {
    Remove-Item $temp -Force -ErrorAction SilentlyContinue
}
