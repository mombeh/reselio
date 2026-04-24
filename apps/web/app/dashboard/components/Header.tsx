'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../lib/auth-context';
import Logo from '../components/Logo';

export default function Header() {
  const router = useRouter();
  const { user, logout } = useAuth();
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  return (
    <header className="bg-white shadow-sm">
      <div className="max-w-6xl mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <Logo size="md" />
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
    </header>
  );
}
