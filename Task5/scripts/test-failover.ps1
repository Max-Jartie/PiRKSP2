param([string]$BaseUrl = 'http://localhost:8088')
$ErrorActionPreference = 'Stop'
Write-Host '=== Практика 5 / Устойчивость Traefik к отключению узла ===' -ForegroundColor Cyan
$containers = @(docker compose ps -q delivery-service)
if ($containers.Count -lt 2) {
    throw 'Need at least 2 delivery-service containers. Run: docker compose up -d --scale delivery-service=3'
}
$stopped = $containers[0]
Write-Host "[ТЕСТ] Останавливаем один контейнер: $stopped"
docker stop $stopped | Out-Host
try {
    Start-Sleep -Seconds 8
    1..12 | ForEach-Object {
        $response = Invoke-RestMethod "$BaseUrl/api/deliveries/1"
        Write-Host ("[УСПЕХ #{0}] Доставка {1} | Узел {2} | Сумма {3}" -f $_, $response.deliveryId, $response.servedBy, $response.total)
    }
} finally {
    Write-Host '[ВОССТАНОВЛЕНИЕ] Возвращаем отключённый контейнер...'
    docker start $stopped | Out-Host
}

