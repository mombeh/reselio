'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '../lib/api';
import { useAuth } from '../lib/auth-context';

interface Stats {
  users: number;
  orders: number;
  pending: number;
  completed: number;
}

export default function LandingContent() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [apiStatus, setApiStatus] = useState<'checking' | 'online' | 'offline'>('checking');
  const { user, token } = useAuth();
  const isAuthenticated = !!token;

  useEffect(() => {
    async function fetchData() {
      const healthResult = await api.healthCheck();
      if (healthResult.data) {
        setApiStatus('online');
      } else {
        setApiStatus('offline');
      }

      try {
        const [usersResult, ordersResult] = await Promise.all([
          api.getUserCount(),
          api.getDashboardMetrics(),
        ]);

        if (usersResult.data || ordersResult.data) {
          setStats({
            users: usersResult.data?.count || 0,
            orders: ordersResult.data?.totalOrders || 0,
            pending: ordersResult.data?.pendingDeliveries || 0,
            completed: (ordersResult.data?.totalOrders || 0) - (ordersResult.data?.pendingDeliveries || 0),
          });
        }
      } catch (err) {
        console.error('Failed to fetch stats:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-b from-rose-50 via-white to-teal-50">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/90 backdrop-blur-md shadow-sm">
        <div className="max-w-6xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 bg-gradient-to-br from-rose-500 via-pink-500 to-teal-500 rounded-xl flex items-center justify-center">
                <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                </svg>
              </div>
              <span className="text-xl font-bold text-gray-800">Reselio</span>
            </div>
            
            <div className="flex items-center gap-3">
              {isAuthenticated ? (
                <Link href="/dashboard" className="bg-gradient-to-r from-rose-500 to-pink-500 text-white px-5 py-2.5 rounded-lg font-semibold hover:opacity-90 transition">
                  Dashboard
                </Link>
              ) : (
                <>
                  <Link href="/auth/login" className="text-gray-600 hover:text-gray-900 font-medium">
                    Sign In
                  </Link>
                  <Link href="/auth/register" className="bg-gradient-to-r from-rose-500 to-pink-500 text-white px-5 py-2.5 rounded-lg font-semibold hover:opacity-90 transition">
                    Start Free
                  </Link>
                </>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-4">
        <div className="max-w-5xl mx-auto text-center">
          <div className="inline-flex items-center gap-2 bg-rose-100 text-rose-700 px-4 py-2 rounded-full text-sm font-medium mb-6">
            <span>📱</span> Built for WhatsApp & Instagram Sellers
          </div>
          
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-6 leading-tight">
            Manage Your Online
            <span className="bg-gradient-to-r from-rose-500 via-pink-500 to-teal-500 bg-clip-text text-transparent"> Business </span>
            Easily
          </h1>
          
          <p className="text-lg md:text-xl text-gray-600 mb-10 max-w-2xl mx-auto">
            No more confusion with WhatsApp chats and handwritten notes. 
            Track orders, customers, payments, and profits all in one place.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a href="/auth/register" className="bg-gradient-to-r from-rose-500 to-pink-500 text-white px-8 py-4 rounded-xl font-bold text-lg hover:opacity-90 transition shadow-lg">
              Start Free Trial
            </a>
            <a href="/auth/login" className="bg-white text-gray-700 px-8 py-4 rounded-xl font-bold text-lg border-2 border-gray-200 hover:border-rose-300 transition">
              I Already Have Account
            </a>
          </div>

          {/* Trust badges */}
          <div className="mt-12 flex flex-wrap justify-center gap-6 text-sm text-gray-500">
            <div className="flex items-center gap-2">
              <svg className="w-5 h-5 text-teal-500" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
              </svg>
              No Card Required
            </div>
            <div className="flex items-center gap-2">
              <svg className="w-5 h-5 text-teal-500" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
              </svg>
              Works on Phone
            </div>
            <div className="flex items-center gap-2">
              <svg className="w-5 h-5 text-teal-500" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
              </svg>
              Free for Small Sellers
            </div>
          </div>
        </div>
      </section>

      {/* Dashboard Preview */}
      <section className="py-16 px-4">
        <div className="max-w-5xl mx-auto">
          <div className="bg-white rounded-3xl shadow-2xl p-4 md:p-8 border border-gray-100">
            <div className="flex items-center gap-2 mb-6">
              <div className="w-3 h-3 rounded-full bg-rose-400" />
              <div className="w-3 h-3 rounded-full bg-yellow-400" />
              <div className="w-3 h-3 rounded-full bg-teal-400" />
              <span className="ml-4 text-gray-400 text-sm">Your Business Dashboard</span>
            </div>
            
            {/* Stats Cards */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
              <div className="bg-gradient-to-br from-rose-50 to-rose-100 rounded-2xl p-5">
                <div className="text-3xl font-bold text-rose-600">
                  {loading ? '...' : stats?.orders || 0}
                </div>
                <div className="text-rose-700 text-sm font-medium">Total Orders</div>
              </div>
              <div className="bg-gradient-to-br from-teal-50 to-teal-100 rounded-2xl p-5">
                <div className="text-3xl font-bold text-teal-600">
                  {loading ? '...' : stats?.users || 0}
                </div>
                <div className="text-teal-700 text-sm font-medium">Customers</div>
              </div>
              <div className="bg-gradient-to-br from-amber-50 to-amber-100 rounded-2xl p-5">
                <div className="text-3xl font-bold text-amber-600">
                  {loading ? '...' : stats?.pending || 0}
                </div>
                <div className="text-amber-700 text-sm font-medium">Pending Delivery</div>
              </div>
              <div className="bg-gradient-to-br from-pink-50 to-pink-100 rounded-2xl p-5">
                <div className="text-3xl font-bold text-pink-600">
                  {loading ? '...' : stats?.completed || 0}
                </div>
                <div className="text-pink-700 text-sm font-medium">Delivered</div>
              </div>
            </div>

            {/* Recent Orders Preview */}
            <div className="bg-gray-50 rounded-2xl p-4">
              <h3 className="font-bold text-gray-800 mb-3">Recent Orders</h3>
              <div className="space-y-2">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="flex items-center justify-between bg-white p-3 rounded-xl">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-gradient-to-br from-rose-400 to-pink-500 rounded-full flex items-center justify-center text-white font-bold">
                        {String.fromCharCode(64 + i)}
                      </div>
                      <div>
                        <div className="font-medium text-gray-800">Customer {i}</div>
                        <div className="text-sm text-gray-500">Dress Size M • Pink</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="font-bold text-gray-800">CFA {5000 + i * 1000}</div>
                      <div className="text-xs text-teal-600 font-medium">Paid</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-20 px-4 bg-white">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl md:text-4xl font-bold text-center text-gray-900 mb-4">
            Everything You Need to
            <span className="bg-gradient-to-r from-rose-500 to-teal-500 bg-clip-text text-transparent"> Grow </span>
            Your Business
          </h2>
          <p className="text-gray-600 text-center mb-12 max-w-xl mx-auto">
            Simple tools designed specifically for WhatsApp and Instagram sellers
          </p>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Orders */}
            <div className="bg-gradient-to-br from-rose-50 to-white rounded-2xl p-6 border border-rose-100">
              <div className="w-14 h-14 bg-gradient-to-br from-rose-500 to-pink-500 rounded-2xl flex items-center justify-center mb-4">
                <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-2">Track Orders</h3>
              <p className="text-gray-600">
                Add orders with customer details, product info, size, color, and payment status. Never lose track again.
              </p>
            </div>

            {/* Customers */}
            <div className="bg-gradient-to-br from-pink-50 to-white rounded-2xl p-6 border border-pink-100">
              <div className="w-14 h-14 bg-gradient-to-br from-pink-500 to-rose-500 rounded-2xl flex items-center justify-center mb-4">
                <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-2">Know Your Customers</h3>
              <p className="text-gray-600">
                See who buys from you most. Track customer history and build loyalty with repeat buyers.
              </p>
            </div>

            {/* Money */}
            <div className="bg-gradient-to-br from-teal-50 to-white rounded-2xl p-6 border border-teal-100">
              <div className="w-14 h-14 bg-gradient-to-br from-teal-500 to-emerald-500 rounded-2xl flex items-center justify-center mb-4">
                <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-2">Track Your Profit</h3>
              <p className="text-gray-600">
                Enter cost price and selling price. We automatically calculate your profit. Know exactly how much you earn.
              </p>
            </div>

            {/* Delivery */}
            <div className="bg-gradient-to-br from-amber-50 to-white rounded-2xl p-6 border border-amber-100">
              <div className="w-14 h-14 bg-gradient-to-br from-amber-500 to-orange-500 rounded-2xl flex items-center justify-center mb-4">
                <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l3.414 3.414a1 1 0 01.293.707V16a1 1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 2 0 104 0m-4 0a2 2 0 114 0" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-2">Delivery Status</h3>
              <p className="text-gray-600">
                Update order status: Waiting → Shipped → Received → Sent → Delivered. Keep customers informed.
              </p>
            </div>

            {/* Balance */}
            <div className="bg-gradient-to-br from-purple-50 to-white rounded-2xl p-6 border border-purple-100">
              <div className="w-14 h-14 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl flex items-center justify-center mb-4">
                <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-2">Balance Tracking</h3>
              <p className="text-gray-600">
                Track advance payments and remaining balance. Know who still owes you money.
              </p>
            </div>

            {/* Simple */}
            <div className="bg-gradient-to-br from-rose-50 to-white rounded-2xl p-6 border border-rose-100">
              <div className="w-14 h-14 bg-gradient-to-br from-rose-400 to-teal-500 rounded-2xl flex items-center justify-center mb-4">
                <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-gray-900 mb-2">Works on Phone</h3>
              <p className="text-gray-600">
                No app to download. Just open in your browser. Perfect for small screens. Simple to use.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 px-4 bg-gradient-to-b from-rose-50 to-teal-50">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl md:text-4xl font-bold text-center text-gray-900 mb-12">
            How It <span className="text-rose-500">Works</span>
          </h2>
          
          <div className="space-y-6">
            <div className="flex items-start gap-4 bg-white p-6 rounded-2xl shadow-sm">
              <div className="w-12 h-12 bg-gradient-to-br from-rose-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
                1
              </div>
              <div>
                <h3 className="text-lg font-bold text-gray-900 mb-1">Create Free Account</h3>
                <p className="text-gray-600">Sign up with your phone number. No credit card needed.</p>
              </div>
            </div>
            
            <div className="flex items-start gap-4 bg-white p-6 rounded-2xl shadow-sm">
              <div className="w-12 h-12 bg-gradient-to-br from-pink-500 to-teal-500 rounded-full flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
                2
              </div>
              <div>
                <h3 className="text-lg font-bold text-gray-900 mb-1">Add Your First Order</h3>
                <p className="text-gray-600">Enter customer name, product details, and payment info.</p>
              </div>
            </div>
            
            <div className="flex items-start gap-4 bg-white p-6 rounded-2xl shadow-sm">
              <div className="w-12 h-12 bg-gradient-to-br from-teal-500 to-emerald-500 rounded-full flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
                3
              </div>
              <div>
                <h3 className="text-lg font-bold text-gray-900 mb-1">Track & Grow</h3>
                <p className="text-gray-600">Update delivery status, see your profit, and grow your business.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <div className="bg-gradient-to-r from-rose-500 via-pink-500 to-teal-500 rounded-3xl p-10 md:p-14">
            <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
              Ready to Organize Your Business?
            </h2>
            <p className="text-white/90 text-lg mb-8">
              Join hundreds of sellers who have stopped using WhatsApp to track orders. 
              Start managing your business the smart way.
            </p>
            <a href="/auth/register" className="inline-block bg-white text-gray-900 px-10 py-4 rounded-xl font-bold text-lg hover:bg-gray-100 transition shadow-lg">
              Start Free Now
            </a>
            <p className="text-white/70 text-sm mt-4">Free plan up to 20 orders per month</p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 py-10 px-4">
        <div className="max-w-5xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-to-br from-rose-500 via-pink-500 to-teal-500 rounded-lg flex items-center justify-center">
                <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                </svg>
              </div>
              <span className="text-white font-bold">Reselio</span>
            </div>
            <div className="flex gap-6 text-gray-400 text-sm">
              <a href="#" className="hover:text-white">Privacy</a>
              <a href="#" className="hover:text-white">Terms</a>
              <a href="#" className="hover:text-white">Contact</a>
            </div>
            <div className="text-gray-500 text-sm">
              © 2026 Reselio. Built for African Sellers.
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
