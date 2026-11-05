'use client';
import { useEffect, useState } from 'react';
import { fetchProducts, Product } from '@/lib/api';

export default function HomePage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const p = await fetchProducts('');
        setProducts(p.slice(0, 8));
      } catch (e) {
        setError((e as Error).message);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  return (
    <main className="container">
      <h1>Welcome to Reselio</h1>
      <p>Browse products from sellers.</p>
      <div style={{ display: 'flex', gap: 8, margin: '16px 0' }}>
        <a className="btn" href="/browse">Browse Products</a>
        <a className="btn" href="/orders">My Orders</a>
      </div>
      {loading && <p>Loading…</p>}
      {error && <p>Error: {error}</p>}
      {!loading && !error && (
        <>
          <h2>Featured Products</h2>
          <ul className="grid" style={{ listStyle: 'none', padding: 0 }}>
            {products.map((p) => (
              <li key={p._id} className="card">
                {p.imageUrl && <img src={p.imageUrl} alt={p.name} style={{ width: '100%', height: 120, objectFit: 'cover' }} />}
                <h3>{p.name}</h3>
                <p>{Math.round(p.price)} FCFA</p>
              </li>
            ))}
          </ul>
        </>
      )}
    </main>
  );
}
