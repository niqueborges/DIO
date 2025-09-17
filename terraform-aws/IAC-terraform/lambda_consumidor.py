import os
import json
import boto3
import logging
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
sqs = boto3.client("sqs")

TABLE_NAME = os.environ["TABLE_NAME"]
QUEUE_URL  = os.environ["QUEUE_URL"]
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    logger.info("🚀 Lambda Consumidor chamada! Recebendo evento...")
    logger.info(f"Evento recebido: {json.dumps(event)}")

    try:
        for record in event.get("Records", []):
            mensagem = json.loads(record["body"])
            mensagem["valor"] = Decimal(str(mensagem["valor"]))
            table.put_item(Item=mensagem)

            receipt_handle = record.get("receiptHandle")
            if receipt_handle:
                sqs.delete_message(QueueUrl=QUEUE_URL, ReceiptHandle=receipt_handle)

        return {"statusCode": 200, "body": json.dumps({"message": "OK"})}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

