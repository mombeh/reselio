'use client';
import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { fetchPublicProduct } from '@/lib/api';

export default function PublicProductPage() {
  const params = useParams<{ publicId: string }>();
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const product = await fetchPublicProduct(params.publicId);
        const storeId = (product as any).storeId;
        if (!storeId) throw new Error('Store not found');
        router.replace(`/store/${storeId}`);
      } catch (e) {
        setError((e as Error).message);
      }
    })();
  }, [params.publicId, router]);

  if (error) return <main style={{padding:24}}>Error: {error}</main>;
  return <main style={{padding:24}}>Loading store…</main>;
}
