param([long]$DeliveryId = 1, [string]$BaseUrl = 'http://localhost:8088')
$ErrorActionPreference = 'Stop'

Write-Host '=== Практика 5: REST через Traefik ===' -ForegroundColor Cyan
Write-Host '[1] Заказ, полученный от Order Service' -ForegroundColor Yellow
$order = Invoke-RestMethod "$BaseUrl/api/orders/$DeliveryId"
$order | Select-Object id, darkstoreId, status, total, servedBy | Format-List

Write-Host '[2] Доставка, сформированная через межсервисный запрос' -ForegroundColor Yellow
$delivery = Invoke-RestMethod "$BaseUrl/api/deliveries/$DeliveryId"
$delivery | Select-Object deliveryId, darkstoreId, status, total, servedBy, orderServiceInstance | Format-List

Write-Host ('[ИТОГ] Доставка {0} получена от {1}; источник заказа: {2}' -f `
    $delivery.deliveryId, $delivery.servedBy, $delivery.orderServiceInstance) -ForegroundColor Green


