param([string]$BaseUrl = 'http://localhost:8080')
$ErrorActionPreference = 'Stop'

Write-Host '=== Практика 7 • Реактивный HTTP / WebFlux ===' -ForegroundColor Cyan
Write-Host '[ШАГ 1] Получение списка через Flux<Delivery>' -ForegroundColor Yellow
$deliveries = [Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData("$BaseUrl/api/deliveries")) | ConvertFrom-Json
$deliveries | Select-Object id, orderId, darkstoreId, status, priceKopecks | Format-Table -AutoSize

if ($deliveries.Count -eq 0) {
    Write-Host '[ПОДСКАЗКА] Список пуст. Сначала добавьте доставку через POST /api/deliveries.'
    return
}

$id = $deliveries[0].id
Write-Host "[ШАГ 2] Одна доставка через Mono<Delivery>: id=$id" -ForegroundColor Yellow
$one = [Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData("$BaseUrl/api/deliveries/$id")) | ConvertFrom-Json
$one | Select-Object id, orderId, status, address, priceKopecks | Format-List

Write-Host '[ШАГ 3] Пошаговые SSE-события (без изменения состояния)' -ForegroundColor Yellow
curl.exe -N "$BaseUrl/api/deliveries/$id/demo-stream"
Write-Host '[ИТОГ] Ответы HTTP и события SSE получены' -ForegroundColor Green


