param(
    [string]$RemoteUrl,
    [string]$Branch = "main"
)

if (-not $RemoteUrl) {
    Write-Error "RemoteUrl is required. Example: https://github.com/USER/REPO.git"
    exit 1
}

Set-Location -Path "$PSScriptRoot"

if (-not (Test-Path ".git")) {
    git init
}

git add .
git commit -m "Save project to GitHub"

git branch -M $Branch

git remote remove origin 2>$null

git remote add origin $RemoteUrl
git push -u origin $Branch
