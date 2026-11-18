param(
    [int]$Count = 20,
    [string]$BaseUrl = 'http://localhost:8088'
)
$ErrorActionPreference = 'Stop'
Write-Host '=== Практика 5 / Проверка распределения трафика ===' -ForegroundColor Cyan
$instances = @()
for ($i = 1; $i -le $Count; $i++) {
    $reply = Invoke-RestMethod -Uri "$BaseUrl/api/deliveries/instance" -Method Get
    $instances += $reply.instanceId
    Write-Host ("Запрос {0,2}  ->  обслужил контейнер {1}" -f $i, $reply.instanceId)
}
Write-Host "`nСтатистика по экземплярам:" -ForegroundColor Cyan
$instances | Group-Object | Sort-Object Name | Format-Table Count, Name -AutoSize
if (($instances | Select-Object -Unique).Count -lt 2) {
    Write-Warning 'Пока замечен один экземпляр. Для балансировки масштабируйте delivery-service.'
}

