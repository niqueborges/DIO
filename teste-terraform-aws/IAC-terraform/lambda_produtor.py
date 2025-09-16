import json
import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

LOCALSTACK_HOST = os.getenv("LOCALSTACK_HOST", "localstack") 
SQS_URL = "http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/minha-fila"


# Configuração do SQS
sqs = boto3.client("sqs", endpoint_url=SQS_URL)

def lambda_handler(event, context):
    logger.info("🚀 Lambda chamada! Recebendo evento...")
    logger.info(f"Evento recebido: {json.dumps(event)}")

    try:
        if "body" not in event:
            logger.error("❌ Erro: Evento não contém um 'body' válido.")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Requisição inválida. Nenhum body encontrado."}),
                "headers": {"Content-Type": "application/json"}
            }

        body = json.loads(event["body"])
        logger.info(f"📤 Tentando enviar mensagem para SQS: {body}")

        response = sqs.send_message(
            QueueUrl=SQS_URL,
            MessageBody=json.dumps(body)
        )

        logger.info(f"✅ Mensagem enviada para SQS! MessageId: {response['MessageId']}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Mensagem enviada com sucesso!", "messageId": response["MessageId"]}),
            "headers": {"Content-Type": "application/json"}
        }
    
    except Exception as e:
        logger.error(f"⚠️ Erro ao processar requisição: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
            "headers": {"Content-Type": "application/json"}
        }
