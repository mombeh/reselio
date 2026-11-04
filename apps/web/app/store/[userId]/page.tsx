'use client';
import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { fetchStore, fetchProducts, submitGuestOrder, Store, Product, GuestOrderResponse } from '@/lib/api';

type Selection = { product: Product; quantity: number };

export default function StorePage() {
  const params = useParams<{ userId: string }>();
  const [store, setStore] = useState<Store | null>(null);
  const [products, setProducts] = useState<Product[]>([]);
  const [search, setSearch] = useState('');
  const [cartOpen, setCartOpen] = useState(false);
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

  const filtered = products.filter((p) => p.name.toLowerCase().includes(search.toLowerCase()));
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
    <main className="container">
      <div className="store-header">
        <h1>{store.name}</h1>
        <p className="store-desc">{store.description}</p>
        {store.address && <p className="store-meta">Address: {store.address}</p>}
        {store.phone && <p className="store-meta">Phone: {store.phone}</p>}
      </div>

      <input className="input" placeholder="Search products" value={search} onChange={(e)=>setSearch(e.target.value)} style={{marginBottom:12}} />
      <h2 className="section-title">Available Products</h2>
      {products.length === 0 ? <p>No available products.</p> : (
        <ul className="grid" style={{listStyle:'none',padding:0}}>
          {filtered.map((p) => (
            <li key={p._id} className="card">
              {p.imageUrl && <img src={p.imageUrl} alt={p.name} style={{width:'100%',height:160,objectFit:'cover'}} />}
              <h3>{p.name}</h3>
              <p>{p.description}</p>
              <p>{Math.round(p.price)} FCFA</p>
              <button className="btn" onClick={() => addToSelection(p)} disabled={selection.some((s) => s.product._id === p._id)}>
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
                <input className="input" type="number" min={1} value={s.quantity} onChange={(e) => updateQty(s.product._id, Number(e.target.value))} style={{width:60}} />
                <button onClick={() => remove(s.product._id)}>Remove</button>
              </li>
            ))}
          </ul>
          <p>Estimated total: {Math.round(estimate)} FCFA (server confirms final total)</p>
        </section>
      )}

      {selection.length > 0 && (
        <div className="cart-bar">
          <span>{selection.length} items • {Math.round(estimate)} FCFA</span>
          <button className="btn" onClick={() => setCartOpen(true)}>View Cart</button>
        </div>
      )}
      {cartOpen && (
        <div className="cart-sheet">
          <h2>Cart</h2>
          {selection.map((s) => (
            <div key={s.product._id} className="cart-row">
              <span>{s.product.name}</span>
              <button className="btn" onClick={() => updateQty(s.product._id, s.quantity - 1)} disabled={s.quantity <= 1}>−</button>
              <span>{s.quantity}</span>
              <button className="btn" onClick={() => updateQty(s.product._id, s.quantity + 1)} disabled={s.quantity >= s.product.quantity}>+</button>
              <button className="btn" onClick={() => remove(s.product._id)}>Remove</button>
            </div>
          ))}
          <p>Estimated total: {Math.round(estimate)} FCFA</p>
          <button className="btn" onClick={() => setCartOpen(false)}>Proceed to Checkout</button>
        </div>
      )}
      <section className="section checkout">
        <h2>Guest Checkout</h2>
        <div style={{display:'grid',gap:8,maxWidth:480}}>
          <label className="field">Full name *<input className="input" value={fullName} onChange={(e)=>setFullName(e.target.value)} required /></label>
          <label className="field">Phone number *<input className="input" value={phone} onChange={(e)=>setPhone(e.target.value)} required type="tel" /></label>
          <label className="field">Email (optional)<input className="input" value={email} onChange={(e)=>setEmail(e.target.value)} type="email" /></label>
          <label className="field">Delivery address (optional)<input className="input" value={address} onChange={(e)=>setAddress(e.target.value)} /></label>
          <label className="field">Notes (optional)<textarea className="input" value={notes} onChange={(e)=>setNotes(e.target.value)} /></label>
          {submitError && <p style={{color:'red'}}>{submitError}</p>}
          <button className="btn" onClick={submit} disabled={submitting}>{submitting ? 'Submitting…' : 'Place Order'}</button>
        </div>
      </section>
    </main>
  );
}
