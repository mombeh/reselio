'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import api from '../../lib/api';
import { useAuth } from '../../lib/auth-context';
import Logo from '../../components/Logo';

// Email validation regex
const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  return emailRegex.test(email);
};

// Password strength checker
interface PasswordStrength {
  score: number;
  label: string;
  color: string;
}

const checkPasswordStrength = (password: string): PasswordStrength => {
  let score = 0;
  
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (/[a-z]/.test(password)) score++;
  if (/[A-Z]/.test(password)) score++;
  if (/\d/.test(password)) score++;
  if (/[@$!%*?&]/.test(password)) score++;

  if (score <= 2) return { score, label: 'Weak', color: 'bg-red-500' };
  if (score <= 4) return { score, label: 'Medium', color: 'bg-yellow-500' };
  return { score, label: 'Strong', color: 'bg-green-500' };
};

export default function RegisterPage() {
  const router = useRouter();
  const { login } = useAuth();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [emailError, setEmailError] = useState('');
  const [passwordStrength, setPasswordStrength] = useState<PasswordStrength>({ score: 0, label: '', color: '' });

  const handleEmailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const email = e.target.value;
    setFormData({ ...formData, email });
    
    if (email && !isValidEmail(email)) {
      setEmailError('Please enter a valid email address');
    } else {
      setEmailError('');
    }
  };

  const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const password = e.target.value;
    setFormData({ ...formData, password });
    setPasswordStrength(checkPasswordStrength(password));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Validate email
    if (!isValidEmail(formData.email)) {
      setError('Please enter a valid email address');
      return;
    }

    // Validate password strength
    if (passwordStrength.score < 4) {
      setError('Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers, and special characters');
      return;
    }

    // Additional minimum length check
    if (formData.password.length < 8) {
      setError('Password must be at least 8 characters');
      return;
    }

    setLoading(true);

    try {
      const result = await api.register(formData.email, formData.password, formData.name);
      
      if (result.error) {
        setError(result.error);
      } else if (result.data) {
        const user = result.data.user || {
          id: '',
          email: formData.email,
          name: formData.name,
        };
        login(result.data.access_token, user);
        router.push('/auth/login');
      }
    } catch (err) {
      setError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = () => {
    window.location.href = 'http://localhost:4000/auth/google';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-pink-50 to-teal-50 flex flex-col">
      <header className="p-3">
        <Link href="/">
          <Logo size="sm" />
        </Link>
      </header>

      <div className="flex-1 flex items-center justify-center px-4 py-8">
        <div className="w-full max-w-md">
          <div className="bg-white rounded-2xl shadow-lg p-8">
            <div className="text-center mb-6">
              <h1 className="text-2xl font-bold text-gray-900">Create Account</h1>
              <p className="text-gray-500 text-sm mt-1">Start managing your business</p>
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
                  Your Name
                </label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-4 py-3 text-base rounded-lg border border-gray-300 focus:border-rose-400 focus:outline-none"
                  placeholder="Enter your name"
                  style={{ color: '#111' }}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Phone / Email
                </label>
                <input
                  type="text"
                  required
                  value={formData.email}
                  onChange={handleEmailChange}
                  className={`w-full px-4 py-3 text-base rounded-lg border focus:outline-none ${
                    emailError ? 'border-red-500 focus:border-red-500' : 'border-gray-300 focus:border-rose-400'
                  }`}
                  placeholder="e.g., 237612345678 or email@example.com"
                  style={{ color: '#111' }}
                />
                {emailError && (
                  <p className="text-red-500 text-xs mt-1">{emailError}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Password
                </label>
                <input
                  type="password"
                  required
                  value={formData.password}
                  onChange={handlePasswordChange}
                  className="w-full px-4 py-3 text-base rounded-lg border border-gray-300 focus:border-rose-400 focus:outline-none"
                  placeholder="At least 8 characters"
                  style={{ color: '#111' }}
                />
                {formData.password && (
                  <div className="mt-2">
                    <div className="flex items-center gap-2 mb-1">
                      <div className="flex-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                        <div
                          className={`h-full ${passwordStrength.color} transition-all duration-300`}
                          style={{ width: `${(passwordStrength.score / 6) * 100}%` }}
                        />
                      </div>
                      <span className={`text-xs font-medium ${
                        passwordStrength.label === 'Weak' ? 'text-red-500' :
                        passwordStrength.label === 'Medium' ? 'text-yellow-500' : 'text-green-500'
                      }`}>
                        {passwordStrength.label}
                      </span>
                    </div>
                    <p className="text-xs text-gray-500">
                      Must have uppercase, lowercase, number, and special character (@$!%*?&)
                    </p>
                  </div>
                )}
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-gradient-to-r from-rose-500 to-pink-500 text-white py-3 rounded-lg font-semibold text-base hover:opacity-90 disabled:opacity-50"
              >
                {loading ? 'Creating...' : 'Create Account'}
              </button>
            </form>

            <div className="mt-5 text-center">
              <p className="text-gray-500 text-sm">
                Have an account?{' '}
                <Link href="/auth/login" className="text-rose-500 font-semibold hover:underline">
                  Sign in
                </Link>
              </p>
            </div>
          </div>

          <p className="text-center text-gray-400 text-sm mt-4">
            Free: up to 20 orders/month
          </p>
        </div>
      </div>
    </div>
  );
}
