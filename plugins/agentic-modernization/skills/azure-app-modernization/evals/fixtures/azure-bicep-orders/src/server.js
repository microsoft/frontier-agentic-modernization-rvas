const express = require('express');
const sql = require('mssql');
const app = express();
app.use(express.json());
const pool = sql.connect(process.env.SQL_CONNECTION);

app.get('/orders/:id', async (req, res) => {
  const r = await (await pool).request().input('id', req.params.id)
    .query('SELECT id, status, total FROM orders WHERE id = @id');
  if (!r.recordset.length) return res.status(404).end();
  res.json(r.recordset[0]);
});

app.post('/orders', async (req, res) => {
  if (!req.body.lines || !req.body.lines.length) return res.status(400).json({ error: 'empty' });
  const r = await (await pool).request().input('total', req.body.total)
    .query("INSERT INTO orders(status,total) OUTPUT inserted.id VALUES('pending',@total)");
  res.status(201).json({ id: r.recordset[0].id });
});

app.listen(process.env.PORT || 8080);
