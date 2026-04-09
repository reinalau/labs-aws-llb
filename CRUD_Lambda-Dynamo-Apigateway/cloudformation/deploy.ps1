#!/usr/bin/env pwsh
# ============================================================
# deploy.ps1  —  Deploy Movies API CloudFormation stack to AWS
# ============================================================
# Usage:
#   .\deploy.ps1 [-Environment dev|staging|prod] [-Region us-east-1] [-StackName movies-api]
#
# Prerequisites:
#   - AWS CLI configured (aws configure) with sufficient permissions
#   - IAM permissions: cloudformation:*, lambda:*, dynamodb:*, apigateway:*, iam:*, logs:*
# ============================================================

param(
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",

    [string]$Region = "us-east-1",

    [string]$StackName = "movies-api"
)

$ErrorActionPreference = "Stop"

$TemplateFile = Join-Path $PSScriptRoot "cloudformation.yaml"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Movies API — CloudFormation Deploy" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Stack      : $StackName" -ForegroundColor Yellow
Write-Host " Environment: $Environment" -ForegroundColor Yellow
Write-Host " Region     : $Region" -ForegroundColor Yellow
Write-Host " Template   : $TemplateFile" -ForegroundColor Yellow
Write-Host ""

# ── Validate template ──────────────────────────────────────
Write-Host "[1/3] Validating CloudFormation template..." -ForegroundColor Cyan
aws cloudformation validate-template `
    --template-body file://$TemplateFile `
    --region $Region

if ($LASTEXITCODE -ne 0) {
    Write-Host "Template validation FAILED." -ForegroundColor Red
    exit 1
}
Write-Host "Template is valid." -ForegroundColor Green

# ── Check if stack already exists ─────────────────────────
Write-Host ""
Write-Host "[2/3] Checking stack status..." -ForegroundColor Cyan

$stackExists = $false
try {
    $stackInfo = aws cloudformation describe-stacks `
        --stack-name $StackName `
        --region $Region `
        --query "Stacks[0].StackStatus" `
        --output text 2>&1
    if ($LASTEXITCODE -eq 0) {
        $stackExists = $true
        Write-Host "Existing stack found (status: $stackInfo). Running UPDATE..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "No existing stack found. Running CREATE..." -ForegroundColor Yellow
}

# ── Deploy ─────────────────────────────────────────────────
Write-Host ""
Write-Host "[3/3] Deploying stack..." -ForegroundColor Cyan

aws cloudformation deploy `
    --template-file $TemplateFile `
    --stack-name $StackName `
    --parameter-overrides Environment=$Environment `
    --capabilities CAPABILITY_NAMED_IAM `
    --region $Region `
    --no-fail-on-empty-changeset

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Deployment FAILED. Check CloudFormation events:" -ForegroundColor Red
    Write-Host "  aws cloudformation describe-stack-events --stack-name $StackName --region $Region" -ForegroundColor Yellow
    exit 1
}

# ── Print outputs ──────────────────────────────────────────
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " Deployment SUCCESSFUL" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Stack Outputs:" -ForegroundColor Cyan

aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query "Stacks[0].Outputs[*].{Key:OutputKey,Value:OutputValue}" `
    --output table

# ── Print test endpoints ───────────────────────────────────
$baseUrl = aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" `
    --output text

# Remove trailing slash for cleaner concatenation
$baseUrl = $baseUrl.TrimEnd('/')

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " API Test Endpoints" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host " POST   (crear pelicula):" -ForegroundColor Yellow
Write-Host "   $baseUrl/Movies" -ForegroundColor White
Write-Host ""
Write-Host " PUT    (actualizar pelicula):" -ForegroundColor Yellow
Write-Host "   $baseUrl/Movies" -ForegroundColor White
Write-Host ""
Write-Host " DELETE (eliminar pelicula):" -ForegroundColor Yellow
Write-Host "   $baseUrl/Movies" -ForegroundColor White
Write-Host ""
Write-Host " GET    (obtener pelicula por titulo):" -ForegroundColor Yellow
Write-Host "   $baseUrl/Movies/{title}" -ForegroundColor White
Write-Host ""
Write-Host " Ejemplo curl POST:" -ForegroundColor DarkGray
Write-Host "   curl -X POST $baseUrl/Movies \`" -ForegroundColor DarkGray
Write-Host "     -H 'Content-Type: application/json' \`" -ForegroundColor DarkGray
Write-Host "     -d '{""title"":""Inception"",""year"":""2010"",""actors"":""DiCaprio""}'" -ForegroundColor DarkGray
Write-Host ""
