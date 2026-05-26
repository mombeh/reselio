import { useState } from 'react';
import {
  StyleSheet,
  View,
  TouchableOpacity,
  Alert,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  TextInput,
} from 'react-native';

import { Link, useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { Mail, Lock, ShoppingBag } from 'lucide-react-native';

import { ThemedText } from '@/components/themed-text';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { Colors, Fonts } from '@/constants/theme';
import { authApi } from '@/services/api';
import { useAuth } from '@/contexts/AuthContext';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loggingIn, setLoggingIn] = useState(false);

  const colorScheme: 'light' | 'dark' =
    useColorScheme() === 'dark' ? 'dark' : 'light';

  const colors = Colors[colorScheme];
  const isDark = colorScheme === 'dark';

  const router = useRouter();
  const { login: setToken } = useAuth();

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) {
      Alert.alert('Missing fields', 'Please fill in both email and password.');
      return;
    }

    setLoggingIn(true);

    try {
      const res = await authApi.login({
        email: email.trim(),
        password,
      });

      await setToken(res.access_token);

      router.replace('/(tabs)');
    } catch (error: any) {
      Alert.alert(
        'Login failed',
        error.message ?? 'Please check your credentials and try again.',
      );
    } finally {
      setLoggingIn(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        contentContainerStyle={[
          styles.container,
          { backgroundColor: colors.background },
        ]}
        keyboardShouldPersistTaps="handled"
      >
        {/* HERO */}
        <LinearGradient
          colors={isDark ? ['#081C24', '#0A7EA4'] : ['#0A7EA4', '#13B5EA']}
          style={styles.hero}
        >
          <View style={styles.logoCircle}>
            <ShoppingBag size={28} color="#fff" />
          </View>

          <ThemedText style={styles.brand}>Reselio</ThemedText>

          <ThemedText style={styles.heroTitle}>
            Welcome back 👋
          </ThemedText>

          <ThemedText style={styles.heroSubtitle}>
            Manage your orders, profits, customers and deliveries in one place.
          </ThemedText>
        </LinearGradient>

        {/* FORM CARD */}
        <View
          style={[
            styles.card,
            {
              backgroundColor: isDark ? '#11181C' : '#fff',
            },
          ]}
        >
          {/* EMAIL */}
          <ThemedText style={styles.label}>Email Address</ThemedText>

          <View
            style={[
              styles.inputContainer,
              {
                borderColor: isDark ? '#2C343A' : '#DDE3EA',
              },
            ]}
          >
            <Mail size={18} color={isDark ? '#94A3B8' : '#64748B'} />

            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="you@example.com"
              placeholderTextColor={isDark ? '#687076' : '#94A3B8'}
              autoCapitalize="none"
              keyboardType="email-address"
              value={email}
              onChangeText={setEmail}
            />
          </View>

          {/* PASSWORD */}
          <ThemedText style={styles.label}>Password</ThemedText>

          <View
            style={[
              styles.inputContainer,
              {
                borderColor: isDark ? '#2C343A' : '#DDE3EA',
              },
            ]}
          >
            <Lock size={18} color={isDark ? '#94A3B8' : '#64748B'} />

            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="Enter your password"
              placeholderTextColor={isDark ? '#687076' : '#94A3B8'}
              secureTextEntry
              value={password}
              onChangeText={setPassword}
            />
          </View>

          {/* BUTTON */}
          <TouchableOpacity
            onPress={handleLogin}
            disabled={loggingIn}
            activeOpacity={0.9}
          >
            <LinearGradient
              colors={['#0A7EA4', '#13B5EA']}
              style={styles.button}
            >
              <ThemedText style={styles.buttonText}>
                {loggingIn ? 'Signing In...' : 'Sign In'}
              </ThemedText>
            </LinearGradient>
          </TouchableOpacity>

          {/* FOOTER */}
          <View style={styles.footer}>
            <ThemedText style={{ opacity: 0.6 }}>
              Don&apos;t have an account?
            </ThemedText>

            <Link href="/register">
              <ThemedText style={{ color: colors.tint, fontWeight: '700' }}>
                {' '}
                Create one
              </ThemedText>
            </Link>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
  },

  hero: {
    paddingTop: 90,
    paddingBottom: 120,
    paddingHorizontal: 28,
    alignItems: 'center',
    borderBottomLeftRadius: 40,
    borderBottomRightRadius: 40,
  },

  logoCircle: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(255,255,255,0.15)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 18,
  },

  brand: {
    color: '#fff',
    fontSize: 32,
    fontFamily: Fonts.rounded,
    fontWeight: '800',
    marginBottom: 10,
  },

  heroTitle: {
    color: '#fff',
    fontSize: 28,
    fontWeight: '800',
    textAlign: 'center',
  },

  heroSubtitle: {
    color: 'rgba(255,255,255,0.85)',
    textAlign: 'center',
    marginTop: 10,
    fontSize: 15,
    lineHeight: 24,
    maxWidth: 300,
  },

  card: {
    marginHorizontal: 22,
    marginTop: -60,
    borderRadius: 28,
    padding: 24,
    gap: 14,
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowRadius: 18,
    elevation: 5,
  },

  label: {
    fontSize: 14,
    fontWeight: '600',
    opacity: 0.75,
  },

  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1.2,
    borderRadius: 16,
    paddingHorizontal: 14,
    height: 56,
    gap: 10,
  },

  input: {
    flex: 1,
    fontSize: 15,
    fontFamily: Fonts.sans,
  },

  button: {
    height: 56,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 10,
  },

  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '800',
  },

  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 12,
  },
});