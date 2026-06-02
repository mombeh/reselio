const API_URL = __DEV__
  ? 'http://192.168.113.96:4000'
  : 'https://api.reselio.com';

type FetchOptions = {
  method?: 'GET' | 'POST' | 'PATCH' | 'DELETE' | 'PUT';
  token?: string | null;
  body?: unknown;
};

async function request<T>(endpoint: string, opts: FetchOptions = {}): Promise<T> {
  const { method = 'GET', token, body } = opts;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const res = await fetch(`${API_URL}${endpoint}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!res.ok) {
    const errorText = await res.text().catch(() => res.statusText);
    throw new Error(`API ${res.status}: ${errorText}`);
  }

  return res.json();
}

// ─── Auth ───────────────────────────────────────────────────────────────────

export const authApi = {
  register: (data: { name: string; email: string; password: string }) =>
    request<{ access_token: string; user: { id: string; email: string; name: string } }>(
      '/auth/register',
      { method: 'POST', body: data },
    ),

  login: (data: { email: string; password: string }) =>
    request<{ access_token: string; user: { id: string; email: string; name: string } }>(
      '/auth/login',
      { method: 'POST', body: data },
    ),

  me: (token: string) =>
    request<{ id: string; email: string; name: string; businessName?: string; phone?: string }>(
      '/auth/me',
      { token },
    ),
};

// ─── Users ──────────────────────────────────────────────────────────────────

export const usersApi = {
  getProfile: (token: string) =>
    request<{ id: string; email: string; name: string; businessName?: string; phone?: string }>(
      '/users/profile',
      { token },
    ),

  updateProfile: (
    token: string,
    data: { name?: string; email?: string; businessName?: string; phone?: string },
  ) => request('/users/profile', { method: 'PATCH', token, body: data }),

  updatePassword: (token: string, data: { currentPassword: string; newPassword: string }) =>
    request('/users/password', { method: 'PATCH', token, body: data }),
};

// ─── Orders ─────────────────────────────────────────────────────────────────

export type OrderStatus =
  | 'Waiting for Supplier'
  | 'Supplier Shipped'
  | 'Received'
  | 'Sent to Customer'
  | 'Delivered';

export interface Order {
  _id: string;
  userId: string;
  customerName: string;
  phone: string;
  productName: string;
  size?: string;
  color?: string;
  costPrice: number;
  sellingPrice: number;
  advancePaid: number;
  balance: number;
  profit: number;
  status: OrderStatus;
  createdAt: string;
}

export type OrdersResponse = {
  data: Order[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
};

export interface DashboardMetrics {
  totalOrders: number;
  totalRevenue: number;
  totalProfit: number;
  pendingDeliveries: number;
  outstandingBalances: number;
}

export interface MonthlyPoint {
  _id: { year: number; month: number };
  totalRevenue: number;
  totalProfit: number;
  totalOrders: number;
}

export interface StatusBreakdown {
  _id: OrderStatus;
  count: number;
  totalRevenue: number;
  totalProfit: number;
}

export interface TopProduct {
  _id: string;
  totalOrders: number;
  totalRevenue: number;
  totalProfit: number;
}

export interface DailySale {
  _id: string;
  totalOrders: number;
  totalRevenue: number;
  totalProfit: number;
}

export interface YearlyPoint {
  _id: number;
  totalRevenue: number;
  totalProfit: number;
  totalOrders: number;
}

export const ordersApi = {
  getAll: (token: string, query: { status?: string; search?: string; page?: number; limit?: number } = {}) => {
    const params = new URLSearchParams();
    if (query.status) params.set('status', query.status);
    if (query.search) params.set('search', query.search);
    params.set('page', String(query.page ?? 1));
    params.set('limit', String(query.limit ?? 20));
    return request<OrdersResponse>(`/orders?${params.toString()}`, { token });
  },

  getOne: (token: string, id: string) => request<Order>(`/orders/${id}`, { token }),

  create: (token: string, body: Record<string, unknown>) =>
    request<Order>('/orders', { method: 'POST', token, body }),

  updateStatus: (token: string, orderId: string, status: OrderStatus) =>
    request<Order>(`/orders/${orderId}/status`, { method: 'PATCH', token, body: { status } }),

  getDashboard: (token: string) =>
    request<DashboardMetrics>('/orders/dashboard', { token }),

  getMonthlyAnalytics: (token: string) =>
    request<MonthlyPoint[]>('/orders/analytics/monthly', { token }),

  getStatusBreakdown: (token: string) =>
    request<StatusBreakdown[]>('/orders/analytics/status', { token }),

  getTopProducts: (token: string) =>
    request<TopProduct[]>('/orders/analytics/products', { token }),

  getDailySales: (token: string, days?: number) =>
    request<DailySale[]>(`/orders/analytics/daily?days=${days ?? 30}`, { token }),

  getYearlyAnalytics: (token: string) =>
    request<YearlyPoint[]>('/orders/analytics/yearly', { token }),

  exportCsv: async (token: string): Promise<string> => {
    const res = await fetch(`${API_URL}/orders/export`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new Error(`Export failed: ${res.status}`);
    return res.text();
  },
};

// ─── Customers ──────────────────────────────────────────────────────────────

export interface Customer {
  _id: string;
  userId: string;
  name: string;
  phone: string;
  email?: string;
  address?: string;
  notes?: string;
  createdAt: string;
}

export interface CustomerSummary {
  _id: string;
  customerName: string;
  phone: string;
  totalOrders: number;
  totalSpent: number;
  totalOutstandingBalance: number;
  deliveredOrders: number;
}

export const customersApi = {
  getAll: (token: string) => request<Customer[]>('/orders/customers/list', { token }),

  getSummary: (token: string) =>
    request<CustomerSummary[]>('/orders/customers', { token }),

  create: (token: string, body: { name: string; phone: string; email?: string; address?: string; notes?: string }) =>
    request<Customer>('/orders/customers', { method: 'POST', token, body }),

  getOne: (token: string, id: string) => request<Customer>(`/orders/customers/${id}`, { token }),

  update: (token: string, id: string, body: { name?: string; phone?: string; email?: string; address?: string; notes?: string }) =>
    request<Customer>(`/orders/customers/${id}`, { method: 'PATCH', token, body }),

  delete: (token: string, id: string) =>
    request<void>(`/orders/customers/${id}`, { method: 'DELETE', token }),
};
