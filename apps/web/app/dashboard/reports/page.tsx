'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '../../lib/auth-context';
import api from '../../lib/api';
import Logo from '../../components/Logo';

interface MonthlyData {
  _id: { year: number; month: number };
  totalRevenue: number;
  totalProfit: number;
  totalOrders: number;
}

interface StatusData {
  _id: string;
  count: number;
  totalRevenue: number;
  totalProfit: number;
}

interface ProductData {
  _id: string;
  totalOrders: number;
  totalRevenue: number;
  totalProfit: number;
}

interface DailyData {
  _id: string;
  totalOrders: number;
  totalRevenue: number;
  totalProfit: number;
}

interface YearlyData {
  _id: number;
  totalRevenue: number;
  totalProfit: number;
  totalOrders: number;
}

const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

export default function ReportsPage() {
  const router = useRouter();
  const { user, token, logout, isLoading: authLoading } = useAuth();
  const [activeTab, setActiveTab] = useState<'overview' | 'monthly' | 'products' | 'daily'>('overview');
  const [monthlyData, setMonthlyData] = useState<MonthlyData[]>([]);
  const [statusData, setStatusData] = useState<StatusData[]>([]);
  const [productData, setProductData] = useState<ProductData[]>([]);
  const [dailyData, setDailyData] = useState<DailyData[]>([]);
  const [yearlyData, setYearlyData] = useState<YearlyData[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!authLoading && !token) {
      router.push('/auth/login');
    }
  }, [authLoading, token, router]);

  useEffect(() => {
    async function fetchAnalytics() {
      if (!token) return;

      setLoading(true);
      
      const [monthlyResult, statusResult, productsResult, dailyResult, yearlyResult] = await Promise.all([
        api.getMonthlyAnalytics(token),
        api.getStatusBreakdown(token),
        api.getTopProducts(token),
        api.getDailySales(token),
        api.getYearlyAnalytics(token),
      ]);

      if (monthlyResult.data) setMonthlyData(monthlyResult.data);
      if (statusResult.data) setStatusData(statusResult.data);
      if (productsResult.data) setProductData(productsResult.data);
      if (dailyResult.data) setDailyData(dailyResult.data);
      if (yearlyResult.data) setYearlyData(yearlyResult.data);

      setLoading(false);
    }

    fetchAnalytics();
  }, [token]);

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  const [dropdownOpen, setDropdownOpen] = useState(false);

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

  const getMonthName = (month: number) => MONTH_NAMES[month - 1] || '';

  const totalRevenue = monthlyData.reduce((sum, m) => sum + m.totalRevenue, 0);
  const totalProfit = monthlyData.reduce((sum, m) => sum + m.totalProfit, 0);
  const totalOrders = monthlyData.reduce((sum, m) => sum + m.totalOrders, 0);

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
            <div className="flex items-center gap-4">
              <Link href="/">
                <Logo size="md" />
              </Link>
              <button
                onClick={() => router.push('/dashboard')}
                className="text-gray-600 hover:text-gray-900"
              >
                ← Back to Dashboard
              </button>
            </div>
            <div className="flex items-center gap-4">
              {/* User Dropdown */}
              <div className="relative">
                <button
                  onClick={() => setDropdownOpen(!dropdownOpen)}
                  className="flex items-center gap-2 text-gray-700 hover:text-gray-900 font-medium"
                >
                  {user?.name || 'User'}
                  <svg
                    className={`w-4 h-4 transition-transform ${dropdownOpen ? 'rotate-180' : ''}`}
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>
                {dropdownOpen && (
                  <div className="absolute right-0 mt-2 w-40 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50">
                    <button
                      onClick={handleLogout}
                      className="w-full text-left px-4 py-2 text-gray-700 hover:bg-gray-100"
                    >
                      Sign Out
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-8">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Reports & Analytics</h1>

        {/* Tabs */}
        <div className="flex gap-2 mb-6 border-b border-gray-200">
          {[
            { id: 'overview', label: 'Overview' },
            { id: 'monthly', label: 'Monthly' },
            { id: 'products', label: 'Top Products' },
            { id: 'daily', label: 'Daily Sales' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`px-4 py-2 font-medium transition ${
                activeTab === tab.id
                  ? 'text-rose-500 border-b-2 border-rose-500'
                  : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {loading ? (
          <div className="flex justify-center py-12">
            <div className="w-8 h-8 border-4 border-rose-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : (
          <>
            {/* Overview Tab */}
            {activeTab === 'overview' && (
              <div className="space-y-6">
                {/* Summary Cards */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div className="bg-white rounded-2xl p-6 shadow-sm">
                    <div className="text-sm text-gray-500 mb-1">Total Revenue</div>
                    <div className="text-3xl font-bold text-teal-500">CFA {totalRevenue.toLocaleString()}</div>
                  </div>
                  <div className="bg-white rounded-2xl p-6 shadow-sm">
                    <div className="text-sm text-gray-500 mb-1">Total Profit</div>
                    <div className="text-3xl font-bold text-green-500">CFA {totalProfit.toLocaleString()}</div>
                  </div>
                  <div className="bg-white rounded-2xl p-6 shadow-sm">
                    <div className="text-sm text-gray-500 mb-1">Total Orders</div>
                    <div className="text-3xl font-bold text-rose-500">{totalOrders}</div>
                  </div>
                </div>

                {/* Status Breakdown */}
                <div className="bg-white rounded-2xl p-6 shadow-sm">
                  <h2 className="font-bold text-gray-900 mb-4">Orders by Status</h2>
                  <div className="space-y-3">
                    {statusData.map((status) => (
                      <div key={status._id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div className="flex items-center gap-3">
                          <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(status._id)}`}>
                            {status._id}
                          </span>
                          <span className="text-gray-600">{status.count} orders</span>
                        </div>
                        <div className="text-right">
                          <div className="font-bold text-gray-900">CFA {status.totalRevenue.toLocaleString()}</div>
                          <div className="text-xs text-gray-500">Profit: CFA {status.totalProfit.toLocaleString()}</div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Yearly Summary */}
                <div className="bg-white rounded-2xl p-6 shadow-sm">
                  <h2 className="font-bold text-gray-900 mb-4">Yearly Performance</h2>
                  <div className="overflow-x-auto">
                    <table className="w-full">
                      <thead>
                        <tr className="border-b border-gray-200">
                          <th className="text-left py-3 px-4 text-gray-600 font-medium">Year</th>
                          <th className="text-right py-3 px-4 text-gray-600 font-medium">Orders</th>
                          <th className="text-right py-3 px-4 text-gray-600 font-medium">Revenue</th>
                          <th className="text-right py-3 px-4 text-gray-600 font-medium">Profit</th>
                        </tr>
                      </thead>
                      <tbody>
                        {yearlyData.map((year) => (
                          <tr key={year._id} className="border-b border-gray-100">
                            <td className="py-3 px-4 font-medium text-gray-900">{year._id}</td>
                            <td className="text-right py-3 px-4 text-gray-900">{year.totalOrders}</td>
                            <td className="text-right py-3 px-4 font-bold text-teal-600">CFA {year.totalRevenue.toLocaleString()}</td>
                            <td className="text-right py-3 px-4 font-bold text-green-600">CFA {year.totalProfit.toLocaleString()}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            )}

            {/* Monthly Tab */}
            {activeTab === 'monthly' && (
              <div className="bg-white rounded-2xl p-6 shadow-sm">
                <h2 className="font-bold text-gray-900 mb-4">Monthly Performance</h2>
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-200">
                        <th className="text-left py-3 px-4 text-gray-600 font-medium">Month</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Orders</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Revenue</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Profit</th>
                      </tr>
                    </thead>
                    <tbody>
                      {monthlyData.map((month) => (
                        <tr key={`${month._id.year}-${month._id.month}`} className="border-b border-gray-100">
                          <td className="py-3 px-4 font-medium text-gray-900">
                            {getMonthName(month._id.month)} {month._id.year}
                          </td>
                          <td className="text-right py-3 px-4 text-gray-900">{month.totalOrders}</td>
                          <td className="text-right py-3 px-4 font-bold text-teal-600">CFA {month.totalRevenue.toLocaleString()}</td>
                          <td className="text-right py-3 px-4 font-bold text-green-600">CFA {month.totalProfit.toLocaleString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* Products Tab */}
            {activeTab === 'products' && (
              <div className="bg-white rounded-2xl p-6 shadow-sm">
                <h2 className="font-bold text-gray-900 mb-4">Top Selling Products</h2>
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-200">
                        <th className="text-left py-3 px-4 text-gray-600 font-medium">Product</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Orders</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Revenue</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Profit</th>
                      </tr>
                    </thead>
                    <tbody>
                      {productData.map((product) => (
                        <tr key={product._id} className="border-b border-gray-100">
                          <td className="py-3 px-4 font-medium text-gray-900">{product._id}</td>
                          <td className="text-right py-3 px-4 text-gray-900">{product.totalOrders}</td>
                          <td className="text-right py-3 px-4 font-bold text-teal-600">CFA {product.totalRevenue.toLocaleString()}</td>
                          <td className="text-right py-3 px-4 font-bold text-green-600">CFA {product.totalProfit.toLocaleString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* Daily Tab */}
            {activeTab === 'daily' && (
              <div className="bg-white rounded-2xl p-6 shadow-sm">
                <h2 className="font-bold text-gray-900 mb-4">Daily Sales (Last 30 Days)</h2>
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-200">
                        <th className="text-left py-3 px-4 text-gray-600 font-medium">Date</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Orders</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Revenue</th>
                        <th className="text-right py-3 px-4 text-gray-600 font-medium">Profit</th>
                      </tr>
                    </thead>
                    <tbody>
                      {dailyData.map((day) => (
                        <tr key={day._id} className="border-b border-gray-100">
                          <td className="py-3 px-4 font-medium text-gray-900">{day._id}</td>
                          <td className="text-right py-3 px-4 text-gray-900">{day.totalOrders}</td>
                          <td className="text-right py-3 px-4 font-bold text-teal-600">CFA {day.totalRevenue.toLocaleString()}</td>
                          <td className="text-right py-3 px-4 font-bold text-green-600">CFA {day.totalProfit.toLocaleString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
