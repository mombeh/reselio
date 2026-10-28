'use client';
import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { fetchStore, fetchProducts, Store, Product } from '@/lib/api';

export default function StorePage() {
  const params = useParams<{ userId: string }>();
  const [store, setStore] = useState<Store | null>(null);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const [s, p] = await Promise.all([fetchStore(params.userId), fetchProducts(params.userId)]);
        setStore(s);
        setProducts(p);
      } catch (e) {
        setError((e as Error).message);
      } finally {
        setLoading(false);
      }
    })();
  }, [params.userId]);

  if (loading) return <main style={{padding:24}}>Loading…</main>;
  if (error) return <main style={{padding:24}}>Error: {error}</main>;
  if (!store) return <main style={{padding:24}}>Store not found</main>;

  return (
    <main style={{padding:24,maxWidth:960,margin:'0 auto'}}>
      <h1>{store.name}</h1>
      <p>{store.description}</p>
      {store.address && <p>Address: {store.address}</p>}
      {store.phone && <p>Phone: {store.phone}</p>}
      <h2>Available Products</h2>
      {products.length === 0 ? (
        <p>No available products.</p>
      ) : (
        <ul style={{display:'grid',gridTemplateColumns:'repeat(auto-fill,minmax(200px,1fr))',gap:16,listStyle:'none',padding:0}}>
          {products.map((p) => (
            <li key={p._id} style={{border:'1px solid #ddd',padding:12,borderRadius:8}}>
              {p.imageUrl && <img src={p.imageUrl} alt={p.name} style={{width:'100%',height:160,objectFit:'cover'}} />}
              <h3>{p.name}</h3>
              <p>{p.description}</p>
              <p>{Math.round(p.price)} FCFA</p>
              <label>Qty: <input type="number" min={1} defaultValue={1} style={{width:60}} /></label>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}
