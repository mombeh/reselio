export const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

export function apiUrl(path: string): string {
  if (!API_BASE_URL) throw new Error('NEXT_PUBLIC_API_BASE_URL is not set');
  return `${API_BASE_URL.replace(/\/$/, '')}${path}`;
}

export type Store = { name: string; description: string; phone: string; address: string; logo: string | null };
export type Product = { _id: string; name: string; description: string; price: number; quantity: number; imageUrl?: string; availability: string };

export async function fetchStore(userId: string): Promise<Store | null> {
  const res = await fetch(apiUrl(`/stores/public/${userId}`));
  if (!res.ok) throw new Error('Store not found');
  const data = await res.json();
  if (!data) return null;
  return data as Store;
}

export async function fetchProducts(userId: string): Promise<Product[]> {
  const res = await fetch(apiUrl(`/products/public?storeId=${encodeURIComponent(userId)}&available=true`));
  if (!res.ok) throw new Error('Failed to load products');
  return res.json();
}

export async function fetchPublicProduct(publicId: string): Promise<{ storeId: string } & Record<string, unknown>> {
  const res = await fetch(apiUrl(`/products/public/${publicId}`));
  if (!res.ok) throw new Error('Product not found');
  return res.json();
}
