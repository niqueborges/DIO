# bootstrap.ps1 - Cria tabela DynamoDB no LocalStack se não existir

# Lista as tabelas existentes
$tables = aws --endpoint-url=http://localhost:4566 dynamodb list-tables --output text

# Checa se a tabela NotasFiscais já existe
if (-not ($tables -match "NotasFiscais")) {
    Write-Host "Criando tabela DynamoDB 'NotasFiscais' no LocalStack..."
    aws --endpoint-url=http://localhost:4566 dynamodb create-table `
        --table-name NotasFiscais `
        --attribute-definitions AttributeName=id,AttributeType=S `
        --key-schema AttributeName=id,KeyType=HASH `
        --billing-mode PAY_PER_REQUEST
    Write-Host "Tabela criada com sucesso!"
} else {
    Write-Host "Tabela 'NotasFiscais' já existe. Pulando criação."
}
# Fim do script