import json
import boto3
import logging
import os
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Detecta se está rodando dentro do Docker e ajusta a conexão
LOCALSTACK_HOST = os.getenv("LOCALSTACK_HOST", "host.docker.internal")  # <- Alterado aqui
ENDPOINT_URL = f"http://{LOCALSTACK_HOST}:4566"

dynamodb = boto3.resource("dynamodb", endpoint_url=ENDPOINT_URL)
table = dynamodb.Table("NotasFiscais")

sqs = boto3.client("sqs", endpoint_url=ENDPOINT_URL)
queue_url = f"{ENDPOINT_URL}/000000000000/minha-fila"

def lambda_handler(event, context):
    logger.info("🚀 Lambda chamada! Recebendo evento...")

    try:
        for record in event["Records"]:
            mensagem = json.loads(record["body"])
            mensagem["valor"] = Decimal(str(mensagem["valor"]))

            logger.info(f"📥 Salvando no DynamoDB: {mensagem}")
            table.put_item(Item=mensagem)

            receipt_handle = record["receiptHandle"]
            sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=receipt_handle)
            logger.info(f"✅ Mensagem deletada da fila: {receipt_handle}")

        return {"statusCode": 200, "body": json.dumps({"message": "Mensagens processadas com sucesso!"})}

    except Exception as e:
        logger.error(f"⚠️ Erro ao processar requisição: {str(e)}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
