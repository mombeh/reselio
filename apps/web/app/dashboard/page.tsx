'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../lib/auth-context';
import api from '../lib/api';
import Logo from '../components/Logo';

// Order status values from backend
const ORDER_STATUSES = [
  'Waiting for Supplier',
  'Supplier Shipped',
  'Received',
  'Sent to Customer',
  'Delivered',
];

interface Order {
  _id: string;
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
}

interface DashboardMetrics {
  totalOrders: number;
  totalRevenue: number;
  totalProfit: number;
  pendingDeliveries: number;
  outstandingBalances: number;
}

interface Customer {
  _id: string;
  customerName: string;
  phone: string;
  totalOrders: number;
  totalSpent: number;
  totalOutstandingBalance: number;
  deliveredOrders: number;
}

export default function DashboardPage() {
  const router = useRouter();
  const { user, token, logout, isLoading: authLoading } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);
  const [metrics, setMetrics] = useState<DashboardMetrics>({
    totalOrders: 0,
    totalRevenue: 0,
    totalProfit: 0,
    pendingDeliveries: 0,
    outstandingBalances: 0,
  });
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loadingOrders, setLoadingOrders] = useState(true);
  const [showNewOrderModal, setShowNewOrderModal] = useState(false);

  // New order form state
  const [newOrder, setNewOrder] = useState({
    customerName: '',
    phone: '',
    productName: '',
    size: '',
    color: '',
    costPrice: 0,
    sellingPrice: 0,
    advancePaid: 0,
  });
  const [submittingOrder, setSubmittingOrder] = useState(false);

  useEffect(() => {
    if (!authLoading && !token) {
      router.push('/auth/login');
    }
  }, [authLoading, token, router]);

  useEffect(() => {
    async function fetchData() {
      if (!token) {
        console.log('No token available, skipping data fetch');
        return;
      }

      // Fetch dashboard metrics
      const metricsResult = await api.getDashboardMetrics(token);
      if (metricsResult.data && !metricsResult.error) {
        setMetrics(metricsResult.data);
      }

      // Fetch orders (paginated)
      const ordersResult = await api.getOrders(token);
      if (ordersResult.data && !ordersResult.error) {
        setOrders(ordersResult.data.data || []);
      }

      // Fetch customers
      const customersResult = await api.getCustomers(token);
      if (customersResult.data && !customersResult.error) {
        setCustomers(customersResult.data);
      }

      setLoadingOrders(false);
    }

    fetchData();
  }, [token]);

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  const handleCreateOrder = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!token) return;

    // Validate required fields
    if (!newOrder.customerName || !newOrder.phone || !newOrder.productName) {
      alert('Please fill in all required fields');
      return;
    }

    if (newOrder.costPrice <= 0 || newOrder.sellingPrice <= 0) {
      alert('Please enter valid cost and selling prices');
      return;
    }

    setSubmittingOrder(true);
    
    const orderPayload = {
      customerName: newOrder.customerName,
      phone: newOrder.phone,
      productName: newOrder.productName,
      size: newOrder.size || undefined,
      color: newOrder.color || undefined,
      costPrice: Number(newOrder.costPrice),
      sellingPrice: Number(newOrder.sellingPrice),
      advancePaid: Number(newOrder.advancePaid) || 0,
    };
    
    console.log('Creating order with payload:', orderPayload);
    
    const result = await api.createOrder(token, orderPayload);

    if (result.data && !result.error) {
      // Refresh orders
      const ordersResult = await api.getOrders(token);
      if (ordersResult.data && !ordersResult.error) {
        setOrders(ordersResult.data.data || []);
      }
      // Refresh metrics
      const metricsResult = await api.getDashboardMetrics(token);
      if (metricsResult.data && !metricsResult.error) {
        setMetrics(metricsResult.data);
      }
      setShowNewOrderModal(false);
      setNewOrder({
        customerName: '',
        phone: '',
        productName: '',
        size: '',
        color: '',
        costPrice: 0,
        sellingPrice: 0,
        advancePaid: 0,
      });
    } else {
      alert(result.error || 'Failed to create order');
    }
    setSubmittingOrder(false);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Delivered':
        return 'bg-teal-100 text-teal-700';
      case 'Sent to Customer':
        return 'bg-blue-100 text-blue-700';
      case 'Received':
        return 'bg-purple-100 text-purple-700';
      case 'Supplier Shipped':
        return 'bg-amber-100 text-amber-700';
      case 'Waiting for Supplier':
      default:
        return 'bg-gray-100 text-gray-700';
    }
  };

  if (authLoading) {
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
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-rose-500">{metrics.totalOrders}</div>
            <div className="text-gray-600">Total Orders</div>
          </div>
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-teal-500">₦{metrics.totalRevenue.toLocaleString()}</div>
            <div className="text-gray-600">Total Revenue</div>
          </div>
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-green-500">₦{metrics.totalProfit.toLocaleString()}</div>
            <div className="text-gray-600">Total Profit</div>
          </div>
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-amber-500">{metrics.pendingDeliveries}</div>
            <div className="text-gray-600">Pending Delivery</div>
          </div>
          <div className="bg-white rounded-2xl p-6 shadow-sm">
            <div className="text-3xl font-bold text-red-500">₦{metrics.outstandingBalances.toLocaleString()}</div>
            <div className="text-gray-600">Outstanding Balance</div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <button
            onClick={() => setShowNewOrderModal(true)}
            className="bg-gradient-to-r from-rose-500 to-pink-500 text-white p-4 rounded-xl font-semibold hover:from-rose-600 hover:to-pink-600 transition"
          >
            + New Order
          </button>
          <button className="bg-white text-gray-700 p-4 rounded-xl font-semibold border-2 border-gray-200 hover:border-gray-300 transition">
            Add Customer
          </button>
          <button className="bg-white text-gray-700 p-4 rounded-xl font-semibold border-2 border-gray-200 hover:border-gray-300 transition">
            View Reports
          </button>
          <button className="bg-white text-gray-700 p-4 rounded-xl font-semibold border-2 border-gray-200 hover:border-gray-300 transition">
            Settings
          </button>
        </div>

        {/* Recent Orders */}
        <div className="bg-white rounded-2xl shadow-sm overflow-hidden mb-8">
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
                    {order.size && <div className="text-xs text-gray-400">Size: {order.size} {order.color ? `/ ${order.color}` : ''}</div>}
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-gray-900">₦{order.sellingPrice?.toLocaleString() || 0}</div>
                    <div className={`text-xs px-2 py-1 rounded-full ${getStatusColor(order.status)}`}>
                      {order.status || 'Waiting for Supplier'}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Customers Section */}
        <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
          <div className="p-4 border-b border-gray-100">
            <h2 className="font-bold text-gray-900">Top Customers</h2>
          </div>

          {loadingOrders ? (
            <div className="p-8 text-center">
              <div className="w-8 h-8 border-4 border-rose-500 border-t-transparent rounded-full animate-spin mx-auto" />
            </div>
          ) : customers.length === 0 ? (
            <div className="p-8 text-center text-gray-500">
              No customers yet.
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {customers.slice(0, 5).map((customer) => (
                <div key={customer._id} className="p-4 flex items-center justify-between hover:bg-gray-50">
                  <div>
                    <div className="font-medium text-gray-900">{customer.customerName}</div>
                    <div className="text-sm text-gray-500">{customer.phone}</div>
                  </div>
                  <div className="text-right">
                    <div className="font-bold text-gray-900">₦{customer.totalSpent?.toLocaleString() || 0}</div>
                    <div className="text-xs text-gray-500">{customer.totalOrders} orders</div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>

      {/* New Order Modal */}
      {showNewOrderModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl p-6 w-full max-w-md max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold text-gray-900">Create New Order</h2>
              <button
                onClick={() => setShowNewOrderModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreateOrder} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Customer Name *
                </label>
                <input
                  type="text"
                  required
                  value={newOrder.customerName}
                  onChange={(e) => setNewOrder({ ...newOrder, customerName: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                  placeholder="Enter customer name"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Phone Number *
                </label>
                <input
                  type="tel"
                  required
                  value={newOrder.phone}
                  onChange={(e) => setNewOrder({ ...newOrder, phone: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                  placeholder="Enter phone number"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Product Name *
                </label>
                <input
                  type="text"
                  required
                  value={newOrder.productName}
                  onChange={(e) => setNewOrder({ ...newOrder, productName: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                  placeholder="Enter product name"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Size
                  </label>
                  <input
                    type="text"
                    value={newOrder.size}
                    onChange={(e) => setNewOrder({ ...newOrder, size: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                    placeholder="e.g., M, L, XL"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Color
                  </label>
                  <input
                    type="text"
                    value={newOrder.color}
                    onChange={(e) => setNewOrder({ ...newOrder, color: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                    placeholder="e.g., Red, Blue"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cost Price *
                  </label>
                  <input
                    type="number"
                    required
                    min="0"
                    value={newOrder.costPrice}
                    onChange={(e) => setNewOrder({ ...newOrder, costPrice: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                    placeholder="0"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Selling Price *
                  </label>
                  <input
                    type="number"
                    required
                    min="0"
                    value={newOrder.sellingPrice}
                    onChange={(e) => setNewOrder({ ...newOrder, sellingPrice: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                    placeholder="0"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Advance Paid
                </label>
                <input
                  type="number"
                  min="0"
                  value={newOrder.advancePaid}
                  onChange={(e) => setNewOrder({ ...newOrder, advancePaid: Number(e.target.value) })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-rose-500 focus:border-transparent"
                  placeholder="0"
                />
              </div>

              {/* Profit Preview */}
              {newOrder.sellingPrice > 0 && newOrder.costPrice > 0 && (
                <div className="bg-gray-50 p-3 rounded-lg">
                  <div className="text-sm text-gray-600">
                    Profit: <span className="font-bold text-green-600">₦{(newOrder.sellingPrice - newOrder.costPrice).toLocaleString()}</span>
                  </div>
                  {newOrder.advancePaid > 0 && (
                    <div className="text-sm text-gray-600">
                      Balance: <span className="font-bold text-amber-600">₦((newOrder.sellingPrice - newOrder.advancePaid)).toLocaleString()</span>
                    </div>
                  )}
                </div>
              )}

              <button
                type="submit"
                disabled={submittingOrder}
                className="w-full bg-gradient-to-r from-rose-500 to-pink-500 text-white py-2 px-4 rounded-lg font-semibold hover:from-rose-600 hover:to-pink-600 transition disabled:opacity-50"
              >
                {submittingOrder ? 'Creating...' : 'Create Order'}
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
