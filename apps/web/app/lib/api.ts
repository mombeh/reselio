const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://reselio.onrender.com';

export interface ApiResponse<T> {
  data?: T;
  error?: string;
}

async function fetchApi<T>(
  endpoint: string,
  options?: RequestInit
): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      return {
        error: errorData.message || `HTTP error! status: ${response.status}`,
      };
    }

    const data = await response.json();
    return { data: data as T };
  } catch (error) {
    return {
      error: error instanceof Error ? error.message : 'An unexpected error occurred',
    };
  }
}

interface UserCountResponse {
  count: number;
}

interface OrderStatsResponse {
  totalOrders: number;
  totalRevenue: number;
  totalProfit: number;
  pendingDeliveries: number;
  outstandingBalances: number;
}

interface CustomerSummary {
  _id: string;
  customerName: string;
  phone: string;
  totalOrders: number;
  totalSpent: number;
  totalOutstandingBalance: number;
  deliveredOrders: number;
}

interface Customer {
  _id: string;
  userId: string;
  name: string;
  phone: string;
  email?: string;
  address?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

interface MonthlyAnalytics {
  _id: {
    year: number;
    month: number;
  };
  totalRevenue: number;
  totalProfit: number;
  totalOrders: number;
}

interface AuthResponse {
  access_token: string;
  user?: {
    id: string;
    email: string;
    name: string;
  };
}

interface Order {
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
  status: string;
  createdAt: string;
  updatedAt: string;
}

interface CreateOrderDto {
  customerName: string;
  phone: string;
  productName: string;
  size?: string;
  color?: string;
  costPrice: number;
  sellingPrice: number;
  advancePaid?: number;
}

// API Client methods
export const api = {
  // Health check
  healthCheck: () => fetchApi<string>('/'),

  // Users
  getUsers: () => fetchApi<any[]>('/users'),
  
  getUserCount: async (): Promise<ApiResponse<UserCountResponse>> => {
    const result = await fetchApi<any[]>('/users');
    if (result.data && !result.error) {
      return { data: { count: result.data.length } };
    }
    if (result.error) {
      return { error: result.error };
    }
    return { data: { count: 0 } };
  },

  // Auth
  login: (email: string, password: string) =>
    fetchApi<AuthResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    }),

  register: (email: string, password: string, name: string) =>
    fetchApi<AuthResponse>('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password, name }),
    }),

  // Orders
  getOrders: (token?: string) =>
    fetchApi<{ data: Order[]; total: number; page: number; limit: number; totalPages: number }>('/orders', {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    }),

  getDashboardMetrics: (token?: string) =>
    fetchApi<OrderStatsResponse>('/orders/dashboard', {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    }),

  getCustomers: (token?: string) =>
    fetchApi<CustomerSummary[]>('/orders/customers', {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    }),

  getMonthlyAnalytics: (token?: string) =>
    fetchApi<MonthlyAnalytics[]>('/orders/analytics/monthly', {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    }),

  createOrder: (token: string, orderData: CreateOrderDto) =>
    fetchApi<Order>('/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify(orderData),
    }),

  updateOrderStatus: (token: string, orderId: string, status: string) =>
    fetchApi<Order>(`/orders/${orderId}/status`, {
      method: 'PATCH',
      headers: { Authorization: `Bearer ${token}` },
      body: JSON.stringify({ status }),
    }),

  exportOrders: (token: string) =>
    fetchApi<string>('/orders/export', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  // Customers (dedicated customer management)
  createCustomer: (token: string, customerData: {
    name: string;
    phone: string;
    email?: string;
    address?: string;
    notes?: string;
  }) =>
    fetchApi<Customer>('/orders/customers', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify(customerData),
    }),

  getAllCustomers: (token: string) =>
    fetchApi<Customer[]>('/orders/customers/list', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getCustomer: (token: string, customerId: string) =>
    fetchApi<Customer>(`/orders/customers/${customerId}`, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  updateCustomer: (token: string, customerId: string, customerData: {
    name: string;
    phone: string;
    email?: string;
    address?: string;
    notes?: string;
  }) =>
    fetchApi<Customer>(`/orders/customers/${customerId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`
      },
      body: JSON.stringify(customerData),
    }),

  deleteCustomer: (token: string, customerId: string) =>
    fetchApi<void>(`/orders/customers/${customerId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
    }),

  // Analytics
  getStatusBreakdown: (token: string) =>
    fetchApi<any[]>('/orders/analytics/status', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getTopProducts: (token: string) =>
    fetchApi<any[]>('/orders/analytics/products', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getDailySales: (token: string) =>
    fetchApi<any[]>('/orders/analytics/daily', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getYearlyAnalytics: (token: string) =>
    fetchApi<any[]>('/orders/analytics/yearly', {
      headers: { Authorization: `Bearer ${token}` },
    }),
};

export default api;
