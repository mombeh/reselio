import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { Stack, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import 'react-native-reanimated';

import { useColorScheme } from '@/hooks/use-color-scheme';
import { useAuth, AuthProvider } from '@/contexts/AuthContext';

export const unstable_settings = {
  anchor: '(tabs)',
};

export default function RootLayout() {
  const colorScheme = useColorScheme();

  if (typeof global !== 'undefined' && !global.__keepAwakeHandlerInstalled) {
    global.__keepAwakeHandlerInstalled = true;
    const handler = (event: PromiseRejectionEvent) => {
      const reason = event.reason;
      if (
        reason instanceof Error &&
        /Unable to activate keep awake/.test(reason.message)
      ) {
        event.preventDefault();
      }
    };
    if (typeof globalThis !== 'undefined') {
      globalThis.addEventListener?.('unhandledrejection', handler as any);
    }
  }

  return (
    <AuthProvider>
      <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
        <AuthGate />
        <StatusBar style="auto" />
      </ThemeProvider>
    </AuthProvider>
  );
}

function AuthGate() {
  const { token, isLoading } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;

    const inAuthGroup =
      segments[0] === 'landing' ||
      segments[0] === 'login' ||
      segments[0] === 'register';

    if (token && inAuthGroup) {
      void router.replace('/(tabs)');
    } else if (!token && segments[0] === '(tabs)') {
      void router.replace('/landing');
    }
  }, [token, isLoading, segments]);

  if (isLoading) return null;

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="landing" options={{ headerShown: false }} />
      <Stack.Screen name="login" options={{ headerShown: false }} />
      <Stack.Screen name="register" options={{ headerShown: false }} />
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen
        name="modal"
        options={{ presentation: 'modal', title: 'Details' }}
      />
    </Stack>
  );
}