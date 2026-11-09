'use client';
import { useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { fetchProducts, Product } from '@/lib/api';

export default function BrowseClient() {
  const searchParams = useSearchParams();
  const storeId = searchParams.get('storeId') || '';
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState<string | null>(null);
  const [favs, setFavs] = useState<Set<string>>(new Set());

  useEffect(() => {
    (async () => {
      try {
        const p = await fetchProducts(storeId);
        setProducts(p);
      } catch (e) {
        setError((e as Error).message);
      } finally {
        setLoading(false);
      }
    })();
  }, [storeId]);

  const categories = Array.from(new Set(products.map((p) => p.category).filter(Boolean)));
  const filtered = products.filter((p) =>
    p.name.toLowerCase().includes(search.toLowerCase()) &&
    (category ? p.category === category : true)
  );

  return (
    <main className="container">
      <h1>Browse Products</h1>
      <input className="input" placeholder="Search" value={search} onChange={(e) => setSearch(e.target.value)} />
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', margin: '8px 0' }}>
        <button className="btn" onClick={() => setCategory(null)}>All</button>
        {categories.map((c) => (
          <button key={c} className="btn" onClick={() => setCategory(c ?? null)}>{c}</button>
        ))}
      </div>
      {loading && <p>Loading…</p>}
      {error && <p>Error: {error}</p>}
      {!loading && !error && filtered.length === 0 && <p>No products found.</p>}
      <ul className="grid" style={{ listStyle: 'none', padding: 0 }}>
        {filtered.map((p) => (
          <li key={p._id} className="card">
            {p.imageUrl && <img src={p.imageUrl} alt={p.name} style={{ width: '100%', height: 120, objectFit: 'cover' }} />}
            <h3>{p.name}</h3>
            {p.storeName && <p style={{ fontSize: 12, color: '#6b7280' }}>{p.storeName}</p>}
            <p>{Math.round(p.price)} FCFA</p>
            <p>{p.availability}</p>
            <button onClick={() => setFavs((prev) => {
              const next = new Set(prev);
              if (next.has(p._id)) next.delete(p._id); else next.add(p._id);
              return next;
            })}>{favs.has(p._id) ? '♥' : '♡'}</button>
          </li>
        ))}
      </ul>
    </main>
  );
}
