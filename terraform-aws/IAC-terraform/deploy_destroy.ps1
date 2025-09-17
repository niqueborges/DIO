# Script PowerShell para deploy e destruir Terraform na AWS
# Limpa state antigo para evitar travamentos do LocalStack

param(
    [switch]$destroy
)

# Caminho para o diretório do Terraform
$terraform_dir = "F:\Github\DIO\teste-terraform-aws\IAC-terraform"

Set-Location $terraform_dir

if (-not $destroy) {
    Write-Host "Limpando state antigo do Terraform..." -ForegroundColor Yellow
    if (Test-Path terraform.tfstate) { Remove-Item terraform.tfstate -Force }
    if (Test-Path terraform.tfstate.backup) { Remove-Item terraform.tfstate.backup -Force }
}

if ($destroy) {
    Write-Host "Destruindo toda a infraestrutura na AWS..." -ForegroundColor Red
    terraform destroy -auto-approve
} else {
    Write-Host "Inicializando Terraform..." -ForegroundColor Green
    terraform init -reconfigure

    Write-Host "Planejando infraestrutura..." -ForegroundColor Green
    terraform plan

    Write-Host "Aplicando infraestrutura..." -ForegroundColor Green
    terraform apply -auto-approve

    Write-Host "Infraestrutura criada com sucesso!" -ForegroundColor Green
    Write-Host "API Gateway URL: $(terraform output -raw api_gateway_url)" -ForegroundColor Cyan
}

Write-Host "Fim do script." -ForegroundColor Yellow
# Fim do script.
