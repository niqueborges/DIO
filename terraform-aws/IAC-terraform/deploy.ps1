# deploy.ps1

Write-Host "[INFO] Criando pacotes ZIP das Lambdas..."

# Lambda Produtor
$prodZip = "lambda_produtor.zip"
if (Test-Path $prodZip) { Remove-Item $prodZip }
Compress-Archive -Path "lambda_produtor.py" -DestinationPath $prodZip
Write-Host "[INFO] Criado $prodZip"

# Lambda Consumidor
$consZip = "lambda_consumidor.zip"
if (Test-Path $consZip) { Remove-Item $consZip }
Compress-Archive -Path "lambda_consumidor.py" -DestinationPath $consZip
Write-Host "[INFO] Criado $consZip"

# Inicializa Terraform
Write-Host "[INFO] Inicializando Terraform..."
terraform init -reconfigure

# Planeja execução
Write-Host "[INFO] Planejando execução..."
terraform plan

# Aplica Terraform
Write-Host "[INFO] Aplicando Terraform..."
terraform apply -auto-approve

# Outputs
Write-Host "[INFO] Outputs do Terraform:"
terraform output
