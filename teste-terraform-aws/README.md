# Projeto Terraform + LocalStack: SQS, Lambda e DynamoDB (Dio.me) 🚀

[![Terraform](https://img.shields.io/badge/Terraform-0.15+-blue.svg)](https://www.terraform.io/)
[![LocalStack](https://img.shields.io/badge/LocalStack-Latest-orange.svg)](https://localstack.cloud/)
[![Python](https://img.shields.io/badge/Python-3.9+-green.svg)](https://www.python.org/)

## Descrição

Este projeto demonstra como criar uma infraestrutura local usando **Terraform** e **LocalStack**, incluindo:

* Fila SQS para receber mensagens
* Tabela DynamoDB para armazenar dados
* Dois Lambdas:

  * **Lambda Produtor**: recebe dados via API Gateway e envia para o SQS
  * **Lambda Consumidor**: consome mensagens do SQS e insere no DynamoDB
* Configuração de permissões e triggers

---

## Estrutura do Projeto 📂

```
IAC-terraform/
├── main.tf
├── variables.tf (opcional)
├── outputs.tf (opcional)
├── bootstrap.ps1
├── lambda_produtor.py
├── lambda_consumidor.py
├── lambda_produtor.zip
├── lambda_consumidor.zip
├── README.md
└── .gitignore
```

---

## Pré-requisitos ⚡

* Docker
* LocalStack
* Terraform
* AWS CLI
* PowerShell (Windows) ou Terminal (Linux/macOS)

---

## 1️⃣ Subir LocalStack

```bash
docker run --rm -it -p 4566:4566 localstack/localstack
```

---

## 2️⃣ Criar recursos essenciais (DynamoDB)

No PowerShell, rode:

```powershell
./bootstrap.ps1
```

> Este script cria a tabela DynamoDB **NotasFiscais** caso ainda não exista.

---

## 3️⃣ Subir infraestrutura com Terraform

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

> No final, o Terraform exibirá a URL da API Gateway (`api_gateway_url`).

---

## 4️⃣ Empacotar e atualizar Lambdas 📦

### Empacotar:

```bash
zip lambda_produtor.zip lambda_produtor.py
zip lambda_consumidor.zip lambda_consumidor.py
```

### Atualizar código no LocalStack:

```bash
aws lambda update-function-code --function-name LambdaProdutor --zip-file fileb://lambda_produtor.zip --endpoint-url=http://localhost:4566
aws lambda update-function-code --function-name LambdaConsumidor --zip-file fileb://lambda_consumidor.zip --endpoint-url=http://localhost:4566
```

> **Opcional**: criar funções Lambda do zero (somente se ainda não existirem)

```bash
aws lambda create-function --function-name LambdaProdutor --runtime python3.9 --role arn:aws:iam::000000000000:role/lambda-role --handler lambda_produtor.lambda_handler --zip-file fileb://lambda_produtor.zip --endpoint-url=http://localhost:4566

aws lambda create-function --function-name LambdaConsumidor --runtime python3.9 --role arn:aws:iam::000000000000:role/lambda-role --handler lambda_consumidor.lambda_handler --zip-file fileb://lambda_consumidor.zip --endpoint-url=http://localhost:4566
```

---

## 5️⃣ Testar a API 🧪

Use **Postman** ou `curl`:

* **Método:** POST
* **URL:** `http://localhost:4566/restapis/<api_gateway_id>/dev/_user_request_/notas`
* **Body (JSON):**

```json
{
  "id":"NF-123",
  "cliente":"João Silva",
  "valor":1000.0,
  "data_emissao":"2025-02-01"
}
```

> Substitua `<api_gateway_id>` pelo valor exibido pelo Terraform no output `api_gateway_url`.

---

## 6️⃣ Verificar DynamoDB 🗄️

```bash
aws dynamodb scan --table-name NotasFiscais --endpoint-url http://localhost:4566
```

> Deve aparecer a entrada inserida pela Lambda Consumidor.

---

## 7️⃣ Comandos úteis LocalStack ⚙️

```bash
localstack stop
localstack start
```

---

## 💡 Dicas

* Sempre rode `bootstrap.ps1` antes do Terraform para garantir que a tabela DynamoDB exista.
* Atualize os zips das Lambdas sempre que alterar o código.
* Para limpar tudo: `terraform destroy -auto-approve`.

---

## 🔄 Fluxo do Sistema

```
API Gateway --> Lambda Produtor --> SQS --> Lambda Consumidor --> DynamoDB
```

> O fluxo garante que dados enviados via API sejam processados de forma assíncrona e armazenados na tabela.

---

## 🔗 Links Úteis

* [Terraform](https://www.terraform.io/)
* [LocalStack](https://localstack.cloud/)
* [Python 3.9](https://www.python.org/)


