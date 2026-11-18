$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8088'
Write-Host '=== Практика 8 • Испытание отказоустойчивости ===' -ForegroundColor Cyan
Write-Host '[01] Состояние системы до отказа' -ForegroundColor Yellow
Invoke-RestMethod "$base/api/system/health" | ConvertTo-Json
Write-Host '[02] Отключаем Supplier Service (базу данных не трогаем)' -ForegroundColor Yellow
docker compose stop supplier-service
Write-Host '[03] Проверяем Gateway при недоступном поставщике' -ForegroundColor Yellow
Invoke-RestMethod "$base/api/system/health" | ConvertTo-Json
Write-Host '[04] Проверяем отказ создания заказа: ожидается HTTP 503' -ForegroundColor Yellow
$timer=[Diagnostics.Stopwatch]::StartNew()
try {
  Invoke-RestMethod -Method Post -Uri "$base/api/orders" -ContentType 'application/json' `
      -Body '{"productId":1,"quantity":2}' | ConvertTo-Json
} catch {
  Write-Host "[ОЖИДАЕМЫЙ ОТКАЗ] $($_.Exception.Message)"
}
$timer.Stop()
Write-Host "[ЗАМЕР] Время ответа: $($timer.Elapsed.TotalSeconds) с"
Write-Host '[05] Возобновляем работу Supplier Service' -ForegroundColor Yellow
docker compose start supplier-service
Write-Host '[ГОТОВО] Сервис запускается; состояние: docker compose ps'
Write-Host 'Circuit breaker может оставаться OPEN примерно 8 секунд перед проверкой HALF_OPEN.'

