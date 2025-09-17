provider "aws" {
  region  = "us-east-1"
  profile = "monique-estudo"
}

# 🔹 Sufixo aleatório para nomes únicos
resource "random_string" "sufixo" {
  length  = 6
  special = false
}

# ----------------------------
# 1️⃣ DynamoDB Table
# ----------------------------
resource "aws_dynamodb_table" "notas_fiscais" {
  name         = "NotasFiscais-${random_string.sufixo.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# ----------------------------
# 2️⃣ SQS Queue
# ----------------------------
resource "aws_sqs_queue" "queue" {
  name = "minha-fila-${random_string.sufixo.result}"
}

# ----------------------------
# 3️⃣ IAM Role + Policy para Lambda
# ----------------------------
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-role-${random_string.sufixo.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "LambdaSQSDynamoPolicy-${random_string.sufixo.result}"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:*",
          "sqs:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# ----------------------------
# 4️⃣ Lambda Functions
# ----------------------------
resource "aws_lambda_function" "producer" {
  function_name    = "LambdaProdutor-${random_string.sufixo.result}"
  filename         = "lambda_produtor.zip"
  source_code_hash = filebase64sha256("lambda_produtor.zip")
  runtime          = "python3.9"
  handler          = "lambda_produtor.lambda_handler"
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = { QUEUE_URL = aws_sqs_queue.queue.id }
  }
}

resource "aws_lambda_function" "consumer" {
  function_name    = "LambdaConsumidor-${random_string.sufixo.result}"
  filename         = "lambda_consumidor.zip"
  source_code_hash = filebase64sha256("lambda_consumidor.zip")
  runtime          = "python3.9"
  handler          = "lambda_consumidor.lambda_handler"
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.notas_fiscais.name
      QUEUE_URL  = aws_sqs_queue.queue.id   # <- adiciona aqui
    }
  }
}


# ----------------------------
# 5️⃣ Lambda Event Source Mapping
# ----------------------------
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
}

# ----------------------------
# 6️⃣ API Gateway
# ----------------------------
resource "aws_api_gateway_rest_api" "api" {
  name        = "NotasAPI-${random_string.sufixo.result}"
  description = "API Gateway para enviar mensagens ao SQS via Lambda"
}

resource "aws_api_gateway_resource" "notas" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "notas"
}

resource "aws_api_gateway_method" "post_notas" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.notas.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.notas.id
  http_method             = aws_api_gateway_method.post_notas.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.producer.invoke_arn
}

resource "aws_lambda_permission" "apigateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.producer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration, aws_api_gateway_method.post_notas]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

# ----------------------------
# 7️⃣ Outputs
# ----------------------------
output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}/notas"
}

output "queue_url" {
  value = aws_sqs_queue.queue.id
}

output "table_name" {
  value = aws_dynamodb_table.notas_fiscais.name
}
