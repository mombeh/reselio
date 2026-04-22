'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '../../lib/api';
import { useAuth } from '../../lib/auth-context';
import Logo from '../../components/Logo';

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuth();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const result = await api.login(formData.email, formData.password);
      
      if (result.error) {
        setError(result.error);
      } else if (result.data) {
        const user = result.data.user || {
          id: '',
          email: formData.email,
          name: 'User',
        };
        login(result.data.access_token, user);
        router.push('/dashboard');
      } else {
        setError('Login failed. Please try again.');
      }
    } catch (err) {
      setError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = () => {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://reselio.onrender.com';
    console.log('Google login clicked, redirecting to ' + apiUrl + '/auth/google');
    window.location.href = apiUrl + '/auth/google';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-pink-50 to-teal-50 flex flex-col">
      <header className="p-3">
        <Logo size="sm" />
      </header>

      <div className="flex-1 flex items-center justify-center px-4 py-8">
        <div className="w-full max-w-md">
          <div className="bg-white rounded-2xl shadow-lg p-8">
            <div className="text-center mb-6">
              <h1 className="text-2xl font-bold text-gray-900">Welcome Back</h1>
              <p className="text-gray-500 text-sm mt-1">Sign in to continue</p>
            </div>

            <button
              type="button"
              onClick={handleGoogleLogin}
              className="w-full bg-white border border-gray-300 text-gray-700 py-3 rounded-lg font-medium text-base hover:bg-gray-50 flex items-center justify-center gap-2 mb-5"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
              Google
            </button>

            <div className="relative mb-4">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-200"></div>
              </div>
              <div className="relative flex justify-center text-xs">
                <span className="px-2 bg-white text-gray-400">or</span>
              </div>
            </div>

            {error && (
              <div className="bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm mb-4">
                {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Phone / Email
                </label>
                <input
                  type="text"
                  required
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-3 text-base rounded-lg border border-gray-300 focus:border-rose-400 focus:outline-none"
                  placeholder="Enter phone or email"
                  style={{ color: '#111' }}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Password
                </label>
                <input
                  type="password"
                  required
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  className="w-full px-4 py-3 text-base rounded-lg border border-gray-300 focus:border-rose-400 focus:outline-none"
                  placeholder="Password"
                  style={{ color: '#111' }}
                />
              </div>

              <div className="flex justify-end">
                <Link href="/auth/forgot-password" className="text-sm text-rose-500 hover:underline">
                  Forgot?
                </Link>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-gradient-to-r from-rose-500 to-pink-500 text-white py-3 rounded-lg font-semibold text-base hover:opacity-90 disabled:opacity-50"
              >
                {loading ? 'Signing in...' : 'Dashboard'}
              </button>
            </form>

            <div className="mt-5 text-center">
              <p className="text-gray-500 text-sm">
                No account?{' '}
                <Link href="/auth/register" className="text-rose-500 font-semibold hover:underline">
                  Sign up
                </Link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
