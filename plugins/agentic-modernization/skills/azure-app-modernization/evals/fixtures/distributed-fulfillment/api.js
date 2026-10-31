const express = require("express");
const { Pool } = require("pg");
const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const config = require("./config.json");

const app = express();
const db = new Pool({ connectionString: process.env.DATABASE_URL });
const queue = new SQSClient({ region: config.awsRegion });

app.post("/fulfillments", async (request, response) => {
  if (!request.headers["x-partner-key"]) {
    return response.status(401).json({ error: "partner key required" });
  }

  const result = await db.query(
    "insert into fulfillment(order_id, status) values ($1, 'accepted') returning id",
    [request.body.orderId],
  );

  await queue.send(new SendMessageCommand({
    QueueUrl: config.queueUrl,
    MessageBody: JSON.stringify({ fulfillmentId: result.rows[0].id }),
  }));

  return response.status(202).json({ id: result.rows[0].id });
});

app.listen(process.env.PORT || 3000);
