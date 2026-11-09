'use client';
import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { fetchStore, fetchProducts, submitGuestOrder, Store, Product, GuestOrderResponse } from '@/lib/api';

type Selection = { product: Product; quantity: number };
type View = 'catalog' | 'cart' | 'checkout';

export default function StorePage() {
  const params = useParams<{ userId: string }>();
  const [store, setStore] = useState<Store | null>(null);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState<string | null>(null);
  const [favs, setFavs] = useState<Set<string>>(new Set());
  const [selection, setSelection] = useState<Selection[]>([]);
  const [view, setView] = useState<View>('catalog');

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
    setSelection((prev) => prev.map((s) => (s.product._id === id ? { ...s, quantity: Math.max(1, Math.min(qty, s.product.quantity)) } : s)));
  };
  const remove = (id: string) => setSelection((prev) => prev.filter((s) => s.product._id !== id));

  const categories = Array.from(new Set(products.map((p) => p.category).filter(Boolean)));
  const filtered = products.filter((p) => p.name.toLowerCase().includes(search.toLowerCase()) && (category ? p.category === category : true));
  const estimate = selection.reduce((sum, s) => sum + s.product.price * s.quantity, 0);
  const itemCount = selection.reduce((sum, s) => sum + s.quantity, 0);

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
      setView('catalog');
    } catch (e) {
      setSubmitError((e as Error).message);
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return <main className="container" style={{paddingBottom:100}}>Loading…</main>;
  if (error) return <main className="container">Error: {error}</main>;
  if (!store) return <main className="container">Store not found</main>;

  if (confirmation) {
    return (
      <main className="container">
        <h1>Order Confirmed</h1>
        <p>{confirmation.message}</p>
        <p>Order reference: <strong>{confirmation.orderNumber}</strong></p>
        <p>No payment has been processed.</p>
      </main>
    );
  }

  if (view === 'cart') {
    return (
      <main className="container">
        <h1>Cart</h1>
        {selection.map((s) => (
          <div key={s.product._id} className="cart-row">
            {s.product.imageUrl && <img src={s.product.imageUrl} alt={s.product.name} width={48} height={48} />}
            <div>
              <div>{s.product.name}</div>
              <div>{Math.round(s.product.price)} FCFA</div>
            </div>
            <button className="btn" onClick={() => updateQty(s.product._id, s.quantity - 1)} disabled={s.quantity <= 1}>−</button>
            <span>{s.quantity}</span>
            <button className="btn" onClick={() => updateQty(s.product._id, s.quantity + 1)} disabled={s.quantity >= s.product.quantity}>+</button>
            <button className="btn" onClick={() => remove(s.product._id)}>Remove</button>
            <div>Line: {Math.round(s.product.price * s.quantity)} FCFA</div>
          </div>
        ))}
        <p>Estimated total: {Math.round(estimate)} FCFA</p>
        <button className="btn" onClick={() => setView('catalog')}>Continue Shopping</button>
        <button className="btn" onClick={() => setView('checkout')}>Proceed to Checkout</button>
      </main>
    );
  }

  if (view === 'checkout') {
    return (
      <main className="container">
        <h1>Checkout</h1>
        <div className="checkout">
          <label className="field">Full name *<input className="input" value={fullName} onChange={(e)=>setFullName(e.target.value)} required /></label>
          <label className="field">Phone number *<input className="input" value={phone} onChange={(e)=>setPhone(e.target.value)} required type="tel" /></label>
          <label className="field">Email (optional)<input className="input" value={email} onChange={(e)=>setEmail(e.target.value)} type="email" /></label>
          <label className="field">Delivery address (optional)<input className="input" value={address} onChange={(e)=>setAddress(e.target.value)} /></label>
          <label className="field">Notes (optional)<textarea className="input" value={notes} onChange={(e)=>setNotes(e.target.value)} /></label>
          {submitError && <p style={{color:'red'}}>{submitError}</p>}
          <p>Estimated total: {Math.round(estimate)} FCFA</p>
          <button className="btn" onClick={submit} disabled={submitting}>{submitting ? 'Submitting…' : 'Place Order'}</button>
          <button className="btn" onClick={() => setView('cart')}>Back to Cart</button>
        </div>
      </main>
    );
  }

  return (
    <>
    <main className="container">
      <div className="store-header">
        <h1>{store.name}</h1>
        <p className="store-desc">{store.description}</p>
        {store.address && <p className="store-meta">Address: {store.address}</p>}
        {store.phone && <p className="store-meta">Phone: {store.phone}</p>}
      </div>
      <input className="input" placeholder="Search products" value={search} onChange={(e)=>setSearch(e.target.value)} style={{marginBottom:12}} />
      <div style={{display:'flex',gap:8,flexWrap:'wrap',margin:'8px 0'}}>
        <button className="btn" onClick={()=>setCategory(null)}>All</button>
        {categories.map((c)=>(<button key={c} className="btn" onClick={()=>setCategory(c ?? null)}>{c}</button>))}
      </div>
      <h2 className="section-title">Available Products</h2>
      <ul className="grid" style={{listStyle:'none',padding:0}}>
        {filtered.map((p) => (
          <li key={p._id} className="card">
            <div style={{position:'relative'}}>
              <img src={p.imageUrl || ''} alt={p.name} style={{width:'100%',height:120,objectFit:'cover',borderRadius:8,background:'#eee'}} onError={(e)=>{(e.target as HTMLImageElement).style.display='none';}} />
              <button onClick={() => setFavs((prev)=>{const n=new Set(prev); if(n.has(p._id)) n.delete(p._id); else n.add(p._id); return n;})} style={{position:'absolute',top:6,right:6,background:'#fff',border:'none',borderRadius:999,padding:4}}>{favs.has(p._id)?'♥':'♡'}</button>
            </div>
            <h3 style={{margin:'4px 0',fontSize:14}}>{p.name}</h3>
            <p style={{margin:'2px 0',fontSize:12,color:'#6b7280'}}>{Math.round(p.price)} FCFA</p>
            <button className="btn" onClick={() => addToSelection(p)} disabled={selection.some((s) => s.product._id === p._id)} style={{width:'100%'}}>
              {selection.some((s) => s.product._id === p._id) ? 'Selected' : 'Select'}
            </button>
          </li>
        ))}
      </ul>
      {selection.length > 0 && (
        <div className="cart-bar">
          <span>{itemCount} items • {Math.round(estimate)} FCFA</span>
          <button className="btn" onClick={() => setView('cart')}>View Cart</button>
        </div>
      )}
    </main>
    <nav className="bottomnav" style={{position:'fixed',bottom:0,left:0,right:0,display:'flex',justifyContent:'space-around',background:'#fff',padding:8,borderTop:'1px solid #ddd'}}>
      <a href="/home">Home</a>
      <a href="/browse">Browse</a>
      <a href="/orders">Orders</a>
      <a href="/profile">Profile</a>
    </nav>
    </>
  );
}
