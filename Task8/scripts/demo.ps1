$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8088'
$rid = 'pr8-' + [guid]::NewGuid().ToString('N')
Write-Host '=== Практика 8 • Маршрут заказа в микросервисной системе ===' -ForegroundColor Cyan
Write-Host "[TRACE] requestId=$rid"
Write-Host '[01] Проверка здоровья API Gateway и сервисов' -ForegroundColor Yellow
Invoke-RestMethod "$base/api/system/health" | ConvertTo-Json
Write-Host '[02] Каталог доступных товаров от Supplier Service' -ForegroundColor Yellow
(Invoke-RestMethod "$base/api/products")[0..2] | Format-Table
Write-Host '[03] Новый заказ: синхронная проверка поставщика' -ForegroundColor Yellow
$order = Invoke-RestMethod -Method Post -Uri "$base/api/orders" -Headers @{ 'X-Request-ID'=$rid } `
  -ContentType 'application/json; charset=utf-8' -Body '{"productId":1,"quantity":2}'
$order | Select-Object id, productId, quantity, totalKopecks, status | Format-List
Write-Host "[04] Ожидаем создание доставки через RabbitMQ для заказа №$($order.id)" -ForegroundColor Yellow
$delivery=$null
for($i=0;$i -lt 25;$i++) {
    try {$delivery=Invoke-RestMethod "$base/api/deliveries/by-order/$($order.id)"; break}
    catch {Start-Sleep -Seconds 1}
}
if(-not $delivery){throw 'Delivery not created. Inspect order-service and delivery-service logs.'}
$delivery | Select-Object id, orderId, status, totalKopecks | Format-List
Write-Host '[05] Повтор события: проверка идемпотентности' -ForegroundColor Yellow
Invoke-RestMethod -Method Post "$base/api/orders/$($order.id)/replay-event" | ConvertTo-Json
Start-Sleep -Seconds 2
(Invoke-RestMethod "$base/api/deliveries/by-order/$($order.id)") | ConvertTo-Json
Write-Host '[06] Жизненный цикл: CREATED → ACCEPTED → IN_TRANSIT → DELIVERED' -ForegroundColor Yellow
foreach($status in @('ACCEPTED','IN_TRANSIT','DELIVERED')) {
  $body = @{status=$status} | ConvertTo-Json
  Invoke-RestMethod -Method Put -Uri "$base/api/deliveries/$($delivery.id)/status" `
    -Headers @{'X-Request-ID'=$rid} -ContentType 'application/json; charset=utf-8' -Body $body | ConvertTo-Json
  Start-Sleep -Seconds 2
}
Write-Host '[ИТОГ] Заказ и доставка обработаны; значения получены из действующих сервисов' -ForegroundColor Green
Write-Host "Логи по requestId: docker compose logs --since 5m api-gateway order-service supplier-service delivery-service | Select-String $rid"
Write-Host "SSE для новой доставки: curl.exe -N $base/api/deliveries/<deliveryId>/events"

