'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '../lib/auth-context';
import api from '../lib/api';
import Logo from '../components/Logo';

interface Order {
  _id: string;
  customerName: string;
  productName: string;
  status: string;
  total: number;
}

export default function DashboardPage() {
  const router = useRouter();
  const { user, token, logout, isLoading } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);
  const [stats, setStats] = useState({ total: 0, revenue: 0, pending: 0 });
  const [loadingOrders, setLoadingOrders] = useState(true);

  useEffect(() => {
    if (!isLoading && !token) {
      router.push('/auth/login');
    }
  }, [isLoading, token, router]);

  useEffect(() => {
    async function fetchOrders() {
      if (!token) {
        console.log('No token available, skipping orders fetch')
        return
      }
      
      const result = await api.getOrders(token);
      console.log('Orders API result:', result)
      
      if (result.data && Array.isArray(result.data)) {
        setOrders(result.data);
        
        // Calculate stats
        const total = result.data.length;
        const revenue = result.data.reduce((sum: number, o: any) => sum + (o.total || 0), 0);
        const pending = result.data.filter((o: any) => o.status === 'pending' || o.status === 'sent').length;
        
        setStats({ total, revenue, pending });
      } else {
        console.error('Failed to fetch orders:', result.error || 'Unknown error', result);
      }
      setLoadingOrders(false);
    }
    
    fetchOrders();
  }, [token]);

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="w-8 h-8 border-4 border-rose-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!token) {
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Logo size="md" />
            <div className="flex items-center gap-4">
              <span className="text-gray-600">Welcome, {user?.name || 'User'}</span>
              <button
                onClick={handleLogout}
                className="text-gray-600 hover:text-gray-900"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 py-8">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Dashboard</h1>
        
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-rose-500">{stats.total}</div>
            <div className="text-gray-600">Total Orders</div>
          </div>
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-teal-500">₦{stats.revenue.toLocaleString()}</div>
            <div className="text-gray-600">Total Revenue</div>
          </div>
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-amber-500">{stats.pending}</div>
            <div className="text-gray-600">Pending Delivery</div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <button className="bg-gradient-to-r from-rose-500 to-pink-500 text-white p-4 rounded-xl font-semibold">
            + New Order
          </button>
          <button className="bg-white text-gray-700 p-4 rounded-xl font-semibold border-2 border-gray-200">
            Add Customer
          </button>
          <button className="bg-white text-gray-700 p-4 rounded-xl font-semibold border-2 border-gray-200">
            View Reports
          </button>
          <button className="bg-white text-gray-700 p-4 rounded-xl font-semibold border-2 border-gray-200">
            Settings
          </button>
        </div>

        {/* Recent Orders */}
        <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
          <div className="p-4 border-b border-gray-100">
            <h2 className="font-bold text-gray-900">Recent Orders</h2>
          </div>
          
          {loadingOrders ? (
            <div className="p-8 text-center">
              <div className="w-8 h-8 border-4 border-rose-500 border-t-transparent rounded-full animate-spin mx-auto" />
            </div>
          ) : orders.length === 0 ? (
            <div className="p-8 text-center text-gray-500">
              No orders yet. Add your first order to get started!
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {orders.slice(0, 10).map((order) => (
                <div key={order._id} className="p-4 flex items-center justify-between hover:bg-gray-50">
                  <div>
                    <div className="font-medium text-gray-900">{order.customerName}</div>
                    <div className="text-sm text-gray-500">{order.productName}</div>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-gray-900">₦{order.total?.toLocaleString() || 0}</div>
                    <div className={`text-xs px-2 py-1 rounded-full ${
                      order.status === 'delivered' ? 'bg-teal-100 text-teal-700' :
                      order.status === 'pending' ? 'bg-amber-100 text-amber-700' :
                      'bg-gray-100 text-gray-700'
                    }`}>
                      {order.status || 'pending'}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
