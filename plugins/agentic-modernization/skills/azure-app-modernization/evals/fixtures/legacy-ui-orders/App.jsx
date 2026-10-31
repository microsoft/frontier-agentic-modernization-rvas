import "./styles.css";

const orders = [
  { id: "SO-1042", customer: "Northwind Traders", status: "Awaiting approval", total: "$12,480" },
  { id: "SO-1041", customer: "Contoso Retail", status: "Approved", total: "$4,320" }
];

export function App({ isLoading = false, error = "" }) {
  return (
    <main className="app-shell">
      <header className="page-header">
        <div>
          <p className="eyebrow">Order operations</p>
          <h1>Approval queue</h1>
        </div>
        <button className="primary-action">Create order</button>
      </header>

      {isLoading && <p role="status">Loading orders...</p>}
      {error && <p className="error" role="alert">{error}</p>}

      {!isLoading && !error && (
        <section className="order-list" aria-label="Orders awaiting review">
          {orders.map((order) => (
            <article className="order-card" key={order.id}>
              <div>
                <p className="order-id">{order.id}</p>
                <h2>{order.customer}</h2>
              </div>
              <p className="status">{order.status}</p>
              <p className="total">{order.total}</p>
              <a href={`/orders/${order.id}`}>Review order</a>
            </article>
          ))}
        </section>
      )}
    </main>
  );
}
