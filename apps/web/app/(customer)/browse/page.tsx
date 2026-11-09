import { Suspense } from 'react';
import BrowseClient from './BrowseClient';

export default function BrowsePage() {
  return (
    <Suspense fallback={<main className="container"><p>Loading…</p></main>}>
      <BrowseClient />
    </Suspense>
  );
}
