import Link from 'next/link';

export default function CustomerLayout({ children }: { children: React.ReactNode }) {
  const nav = [
    { href: '/home', label: 'Home' },
    { href: '/browse', label: 'Browse' },
    { href: '/orders', label: 'Orders' },
    { href: '/profile', label: 'Profile' },
  ];
  return (
    <div style={{ display: 'flex' }}>
      <aside className="sidebar" style={{ display: 'none' }}>
        {nav.map((n) => <Link key={n.href} href={n.href}>{n.label}</Link>)}
      </aside>
      <main style={{ flex: 1, paddingBottom: 64 }}>{children}</main>
      <nav className="bottomnav" style={{ position: 'fixed', bottom: 0, left: 0, right: 0, display: 'flex', justifyContent: 'space-around', background: '#fff', padding: 8 }}>
        {nav.map((n) => <Link key={n.href} href={n.href}>{n.label}</Link>)}
      </nav>
    </div>
  );
}
