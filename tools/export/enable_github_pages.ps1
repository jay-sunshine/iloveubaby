param(
    [Parameter(Mandatory = $false)]
    [string]$Token = $env:GITHUB_TOKEN,

    [Parameter(Mandatory = $false)]
    [string]$Owner = 'jay-sunshine',

    [Parameter(Mandatory = $false)]
    [string]$Repo = 'iloveu'
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Token)) {
    throw 'Missing GitHub token. Set GITHUB_TOKEN or pass -Token.'
}

$headers = @{
    Accept = 'application/vnd.github+json'
    Authorization = "Bearer $Token"
    'X-GitHub-Api-Version' = '2022-11-28'
}

$body = @{ build_type = 'workflow' } | ConvertTo-Json -Compress
$uri = "https://api.github.com/repos/$Owner/$Repo/pages"

try {
    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ContentType 'application/json'
    Write-Host "GitHub Pages created for $Owner/$Repo"
}
catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 409 -or $_.Exception.Response.StatusCode.value__ -eq 422) {
        $response = Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body -ContentType 'application/json'
        Write-Host "GitHub Pages updated for $Owner/$Repo"
    }
    else {
        throw
    }
}

Write-Host 'Expected URL:'
Write-Host "https://$Owner.github.io/$Repo/"

