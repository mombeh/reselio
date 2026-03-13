const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';

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
  total: number;
  pending: number;
  completed: number;
}

interface AuthResponse {
  access_token: string;
  user?: {
    id: string;
    email: string;
    name: string;
  };
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
    fetchApi<any[]>('/orders', {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    }),

  getOrderStats: async (token?: string): Promise<ApiResponse<OrderStatsResponse>> => {
    const result = await fetchApi<any[]>('/orders', {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    });
    
    if (result.data && !result.error) {
      const orders = result.data;
      const total = orders.length;
      const pending = orders.filter((o: any) => o.status === 'pending').length;
      const completed = orders.filter((o: any) => o.status === 'completed').length;
      return { data: { total, pending, completed } };
    }
    if (result.error) {
      return { error: result.error };
    }
    return { data: { total: 0, pending: 0, completed: 0 } };
  },
};

export default api;
