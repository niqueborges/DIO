provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3          = "http://localhost:4566"
    dynamodb    = "http://localhost:4566"
    lambda      = "http://localhost:4566"
    sqs         = "http://localhost:4566"
    sns         = "http://localhost:4566"
    apigateway  = "http://localhost:4566"
    iam         = "http://localhost:4566"
  }
}

# 🔹 Criar SQS (Fila de Mensagens)
resource "aws_sqs_queue" "queue" {
  name                      = "minha-fila"
  visibility_timeout_seconds = 30 # ⏳ Ajuste para evitar reprocessamento imediato
}

# 🔹 Criar Tabela DynamoDB
resource "aws_dynamodb_table" "notas_fiscais" {
  name         = "NotasFiscais"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# 🔹 Criar Função Lambda Produtor
resource "aws_lambda_function" "lambda_produtor" {
  function_name = "LambdaProdutor"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.9"
  handler       = "lambda_produtor.lambda_handler"

  filename         = "lambda_produtor.zip"
  source_code_hash = filebase64sha256("lambda_produtor.zip")
  timeout          = 10
}

# 🔹 Criar Função Lambda Consumidor
resource "aws_lambda_function" "lambda_consumidor" {
  function_name = "LambdaConsumidor"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.9"
  handler       = "lambda_consumidor.lambda_handler"

  filename         = "lambda_consumidor.zip"
  source_code_hash = filebase64sha256("lambda_consumidor.zip")
  timeout          = 30
}

# 🔹 Criar Role para Lambda com Políticas
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "LambdaSQSDynamoPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.notas_fiscais.arn
      }
    ]
  })
}


# 🔹 Anexar a política à Role do Lambda
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# 🔹 Criar Trigger para conectar SQS ao Lambda Consumidor
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.lambda_consumidor.arn
  batch_size       = 1
}

# 🔹 Criar API Gateway para chamar Lambda Produtor
resource "aws_api_gateway_rest_api" "notas_api" {
  name        = "NotasFiscaisAPI"
  description = "API para enviar mensagens ao SQS via Lambda"
}

resource "aws_api_gateway_resource" "notas_resource" {
  rest_api_id = aws_api_gateway_rest_api.notas_api.id
  parent_id   = aws_api_gateway_rest_api.notas_api.root_resource_id
  path_part   = "notas"
}

resource "aws_api_gateway_method" "post_notas" {
  rest_api_id   = aws_api_gateway_rest_api.notas_api.id
  resource_id   = aws_api_gateway_resource.notas_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.notas_api.id
  resource_id             = aws_api_gateway_resource.notas_resource.id
  http_method             = aws_api_gateway_method.post_notas.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_produtor.invoke_arn
}

resource "aws_lambda_permission" "apigateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_produtor.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.notas_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "notas_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.notas_api.id

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.notas_api.id
  deployment_id = aws_api_gateway_deployment.notas_api_deployment.id
  stage_name    = "dev"
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.notas_api.id
}

output "api_gateway_url" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.notas_api.id}/dev/_user_request_/notas"
}
