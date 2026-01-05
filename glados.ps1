$gladosCookie = $env:GLADOS_COOKIE

if (-not $gladosCookie)
{
    Write-Error "Failed to get cookie!"
    exit 1
}

$requestBody = @{
    token = "glados.one"
} | ConvertTo-Json

$headers = @{
    "Cookie" = $gladosCookie
    "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:130.0) Gecko/20100101 Firefox/130.0"
}

try
{
    $response = Invoke-WebRequest `
        -Uri "https://glados.network/api/user/checkin" `
        -Method Post `
        -Header $headers `
        -ContentType "application/json" `
        -Body $requestBody
} catch
{
    Write-Error "Failed to check in due to network error!"
    exit 1
}

if ($response.StatusCode -ne 200)
{
    Write-Error "Failed to check in due to failed status code $($response.StatusCode)"
    exit 1
}

try
{
    $content = $response.Content | ConvertFrom-Json
} catch
{
    Write-Error "Failed to unserialize response json."
    exit 1
}

Write-Host "Check in response: $($content.message)"

if ($null -ne $content.list -and $content.list.Count -gt 0)
{
    $balance = $content.list[0].balance
    Write-Host "The points now are $balance"
} else
{
    Write-Error "No records found in response!"
    exit 1
}
