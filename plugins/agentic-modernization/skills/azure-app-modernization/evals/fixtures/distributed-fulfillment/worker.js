const { Pool } = require("pg");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const config = require("./config.json");

const db = new Pool({ connectionString: process.env.DATABASE_URL });
const storage = new S3Client({ region: config.awsRegion });

async function processMessage(message, partnerClient) {
  const { fulfillmentId } = JSON.parse(message.Body);
  await db.query(
    "update fulfillment set attempts = attempts + 1, status = 'processing' where id = $1",
    [fulfillmentId],
  );

  const partnerResult = await partnerClient.submit(fulfillmentId);
  await db.query(
    "update fulfillment set status = $2, partner_reference = $3 where id = $1",
    [fulfillmentId, "completed", partnerResult.reference],
  );
}

async function exportNightly(date) {
  const rows = await db.query(
    "select order_id, status, partner_reference from fulfillment where updated_at::date = $1",
    [date],
  );
  await storage.send(new PutObjectCommand({
    Bucket: config.exportBucket,
    Key: "partner/latest.csv",
    Body: rows.rows.map((row) => Object.values(row).join(",")).join("\n"),
  }));
}

module.exports = { processMessage, exportNightly };
