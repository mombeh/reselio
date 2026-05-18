import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { Stack, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import 'react-native-reanimated';

import { useColorScheme } from '@/hooks/use-color-scheme';
import { useAuth } from '@/contexts/AuthContext';

export const unstable_settings = {
  anchor: '(tabs)',
};

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <AuthGate />
      <StatusBar style="auto" />
    </ThemeProvider>
  );
}

function AuthGate() {
  const { token, isLoading } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;

    const inAuthGroup = segments[0] === 'landing' || segments[0] === 'login' || segments[0] === 'register';

    if (token && inAuthGroup) {
      // Already logged in — send them straight to dashboard
      void router.replace('/(tabs)');
    } else if (!token && segments[0] === '(tabs)') {
      // Not logged in — they should not be inside the tabs
      void router.replace('/landing');
    }
  }, [token, isLoading, segments]);

  if (isLoading) return null;

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="landing" options={{ headerShown: false }} />
      <Stack.Screen name="login" options={{ headerShown: false, title: 'Sign In' }} />
      <Stack.Screen name="register" options={{ headerShown: false, title: 'Create Account' }} />
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="modal" options={{ presentation: 'modal', title: 'Details' }} />
    </Stack>
  );
}
