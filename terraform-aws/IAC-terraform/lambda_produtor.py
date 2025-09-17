import os
import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]

def lambda_handler(event, context):
    logger.info("🚀 Lambda Produtor chamada! Recebendo evento...")
    logger.info(f"Evento recebido: {json.dumps(event)}")

    if "body" not in event:
        return {"statusCode": 400, "body": json.dumps({"error": "Body inválido"})}

    try:
        body = json.loads(event["body"])
        response = sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(body))
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Mensagem enviada", "id": response["MessageId"]}),
        }
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
