'use client';
import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { fetchStore, fetchProducts, submitGuestOrder, Store, Product, GuestOrderResponse } from '@/lib/api';

type Selection = { product: Product; quantity: number };

export default function StorePage() {
  const params = useParams<{ userId: string }>();
  const [store, setStore] = useState<Store | null>(null);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selection, setSelection] = useState<Selection[]>([]);
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [address, setAddress] = useState('');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [confirmation, setConfirmation] = useState<GuestOrderResponse | null>(null);

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

  const addToSelection = (product: Product) => {
    setSelection((prev) => {
      const existing = prev.find((s) => s.product._id === product._id);
      if (existing) return prev;
      return [...prev, { product, quantity: 1 }];
    });
  };

  const updateQty = (id: string, qty: number) => {
    setSelection((prev) => prev.map((s) => (s.product._id === id ? { ...s, quantity: Math.max(1, qty) } : s)));
  };

  const remove = (id: string) => setSelection((prev) => prev.filter((s) => s.product._id !== id));

  const estimate = selection.reduce((sum, s) => sum + s.product.price * s.quantity, 0);

  const submit = async () => {
    setSubmitError(null);
    if (!fullName.trim() || !phone.trim()) {
      setSubmitError('Full name and phone number are required.');
      return;
    }
    if (selection.length === 0) {
      setSubmitError('Select at least one product.');
      return;
    }
    setSubmitting(true);
    try {
      const res = await submitGuestOrder({
        storeId: params.userId,
        items: selection.map((s) => ({ productId: s.product._id, quantity: s.quantity })),
        guest: { fullName, phoneNumber: phone, email: email || undefined, address: address || undefined, notes: notes || undefined },
      });
      setConfirmation(res);
      setSelection([]);
    } catch (e) {
      setSubmitError((e as Error).message);
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return <main style={{padding:24}}>Loading…</main>;
  if (error) return <main style={{padding:24}}>Error: {error}</main>;
  if (!store) return <main style={{padding:24}}>Store not found</main>;

  if (confirmation) {
    return (
      <main style={{padding:24,maxWidth:640,margin:'0 auto'}}>
        <h1>Order Confirmed</h1>
        <p>{confirmation.message}</p>
        <p>Order reference: <strong>{confirmation.orderNumber}</strong></p>
        <p>No payment has been processed.</p>
      </main>
    );
  }

  return (
    <main style={{padding:24,maxWidth:960,margin:'0 auto'}}>
      <h1>{store.name}</h1>
      <p>{store.description}</p>
      {store.address && <p>Address: {store.address}</p>}
      {store.phone && <p>Phone: {store.phone}</p>}

      <h2>Available Products</h2>
      {products.length === 0 ? <p>No available products.</p> : (
        <ul style={{display:'grid',gridTemplateColumns:'repeat(auto-fill,minmax(200px,1fr))',gap:16,listStyle:'none',padding:0}}>
          {products.map((p) => (
            <li key={p._id} style={{border:'1px solid #ddd',padding:12,borderRadius:8}}>
              {p.imageUrl && <img src={p.imageUrl} alt={p.name} style={{width:'100%',height:160,objectFit:'cover'}} />}
              <h3>{p.name}</h3>
              <p>{p.description}</p>
              <p>{Math.round(p.price)} FCFA</p>
              <button onClick={() => addToSelection(p)} disabled={selection.some((s) => s.product._id === p._id)}>
                {selection.some((s) => s.product._id === p._id) ? 'Selected' : 'Select'}
              </button>
            </li>
          ))}
        </ul>
      )}

      {selection.length > 0 && (
        <section style={{marginTop:24}}>
          <h2>Your Selection</h2>
          <ul style={{listStyle:'none',padding:0}}>
            {selection.map((s) => (
              <li key={s.product._id} style={{display:'flex',gap:8,alignItems:'center',marginBottom:8}}>
                <span>{s.product.name}</span>
                <input type="number" min={1} value={s.quantity} onChange={(e) => updateQty(s.product._id, Number(e.target.value))} style={{width:60}} />
                <button onClick={() => remove(s.product._id)}>Remove</button>
              </li>
            ))}
          </ul>
          <p>Estimated total: {Math.round(estimate)} FCFA (server confirms final total)</p>
        </section>
      )}

      <section style={{marginTop:24}}>
        <h2>Guest Checkout</h2>
        <div style={{display:'grid',gap:8,maxWidth:480}}>
          <label>Full name *<input value={fullName} onChange={(e)=>setFullName(e.target.value)} required /></label>
          <label>Phone number *<input value={phone} onChange={(e)=>setPhone(e.target.value)} required type="tel" /></label>
          <label>Email (optional)<input value={email} onChange={(e)=>setEmail(e.target.value)} type="email" /></label>
          <label>Delivery address (optional)<input value={address} onChange={(e)=>setAddress(e.target.value)} /></label>
          <label>Notes (optional)<textarea value={notes} onChange={(e)=>setNotes(e.target.value)} /></label>
          {submitError && <p style={{color:'red'}}>{submitError}</p>}
          <button onClick={submit} disabled={submitting}>{submitting ? 'Submitting…' : 'Place Order'}</button>
        </div>
      </section>
    </main>
  );
}
