'use client';

import { useState } from 'react';
import Link from 'next/link';
import Logo from '../../components/Logo';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    setTimeout(() => {
      setSubmitted(true);
      setLoading(false);
    }, 1000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-pink-50 to-teal-50 flex flex-col">
      <header className="p-3">
        <Link href="/">
          <Logo size="sm" />
        </Link>
      </header>

      <div className="flex-1 flex items-center justify-center px-3 py-4">
        <div className="w-full max-w-sm">
          <div className="bg-white rounded-2xl shadow-lg p-5">
            {!submitted ? (
              <>
                <div className="text-center mb-5">
                  <div className="w-10 h-10 bg-rose-100 rounded-full flex items-center justify-center mx-auto mb-3">
                    <svg className="w-5 h-5 text-rose-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
                    </svg>
                  </div>
                  <h1 className="text-lg font-bold text-gray-900">Forgot Password?</h1>
                  <p className="text-gray-500 text-xs mt-1">Enter your phone/email to reset</p>
                </div>

                <form onSubmit={handleSubmit} className="space-y-3">
                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">
                      Phone / Email
                    </label>
                    <input
                      type="text"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full px-3 py-2 text-sm rounded-lg border border-gray-300 focus:border-rose-400 focus:outline-none"
                      placeholder="e.g., 237612345678"
                      style={{ color: '#111' }}
                    />
                  </div>

                  <button
                    type="submit"
                    disabled={loading}
                    className="w-full bg-gradient-to-r from-rose-500 to-pink-500 text-white py-2 rounded-lg font-semibold text-sm hover:opacity-90 disabled:opacity-50"
                  >
                    {loading ? 'Sending...' : 'Send Reset Link'}
                  </button>
                </form>
              </>
            ) : (
              <div className="text-center py-2">
                <div className="w-10 h-10 bg-teal-100 rounded-full flex items-center justify-center mx-auto mb-3">
                  <svg className="w-5 h-5 text-teal-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                <h1 className="text-lg font-bold text-gray-900 mb-2">Check Your Phone</h1>
                <p className="text-gray-500 text-xs mb-4">
                  Reset link sent to <span className="font-semibold">{email}</span>
                </p>
                <button 
                  onClick={() => setSubmitted(false)}
                  className="text-rose-500 text-xs hover:underline"
                >
                  Try again
                </button>
              </div>
            )}

            <div className="mt-4 text-center">
              <p className="text-gray-500 text-xs">
                Remember password?{' '}
                <Link href="/auth/login" className="text-rose-500 font-semibold hover:underline">
                  Sign in
                </Link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
