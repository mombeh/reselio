// @ts-nocheck
// @ts-noreport TS2307 — runtime dep declared in apps/mobile/package.json
import React, { createContext, useContext, useEffect, useState } from 'react';

const TOKEN_KEY = '@reselio_auth_token';

interface AuthContextType {
  token: string | null;
  isLoading: boolean;
  login: (token: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType>({
  token: null,
  isLoading: true,
  login: async () => { },
  logout: async () => { },
  isAuthenticated: false,
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const AsyncStorage = (await import('@react-native-async-storage/async-storage')).default;
        const stored = await AsyncStorage.getItem(TOKEN_KEY);
        if (!cancelled && stored) setToken(stored);
      } catch {
        // storage not available
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }

    void load();
    return () => {
      cancelled = true;
    };
  }, []);

  const login = async (newToken: string) => {
    setToken(newToken);
    try {
      const AsyncStorage = (await import('@react-native-async-storage/async-storage')).default;
      await AsyncStorage.setItem(TOKEN_KEY, newToken);
    } catch { /* ignore */ }
  };

  const logout = async () => {
    setToken(null);
    try {
      const AsyncStorage = (await import('@react-native-async-storage/async-storage')).default;
      await AsyncStorage.deleteItem(TOKEN_KEY);
    } catch { /* ignore */ }
  };

  return (
    <AuthContext.Provider value={{ token, isLoading, login, logout, isAuthenticated: !!token }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
