import { useState } from 'react';
import { StyleSheet, View, TouchableOpacity, Alert, ScrollView, KeyboardAvoidingView, Platform, TextInput } from 'react-native';
import { Link, useRouter } from 'expo-router';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { Colors, Fonts } from '@/constants/theme';
import { authApi } from '@/services/api';
import { useAuth } from '@/contexts/AuthContext';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loggingIn, setLoggingIn] = useState(false);
  const colorScheme: 'light' | 'dark' = useColorScheme() === 'dark' ? 'dark' : 'light';
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
      const res = await authApi.login({ email: email.trim(), password });
      await setToken(res.access_token);
      router.replace('/(tabs)');
    } catch (error: any) {
      Alert.alert('Login failed', error.message ?? 'Please check your credentials and try again.');
    } finally {
      setLoggingIn(false);
    }
  };

  return (
    <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView contentContainerStyle={[styles.container, { backgroundColor: colors.background }]}
        keyboardShouldPersistTaps="handled">
        <ThemedView style={styles.header}>
          <ThemedText type="title" style={{ color: colors.tint }}>Reselio</ThemedText>
          <ThemedText style={{ fontSize: 14, opacity: 0.6, marginTop: 4 }}>Sign in to your account</ThemedText>
        </ThemedView>

        <ThemedView style={styles.form}>
          <ThemedText type="defaultSemiBold" style={styles.label}>Email</ThemedText>
          <View style={[styles.inputBox, { borderColor: isDark ? '#3A4046' : '#D0D7DE' }]}>
            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="you@example.com"
              placeholderTextColor={isDark ? '#687076' : '#A3AEB5'}
              multiline
              onChangeText={setEmail}
              value={email}
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
            />
          </View>

          <ThemedText type="defaultSemiBold" style={styles.label}>Password</ThemedText>
          <View style={[styles.inputBox, { borderColor: isDark ? '#3A4046' : '#D0D7DE' }]}>
            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="Enter your password"
              placeholderTextColor={isDark ? '#687076' : '#A3AEB5'}
              secureTextEntry
              multiline
              onChangeText={setPassword}
              value={password}
            />
          </View>

          <TouchableOpacity
            onPress={handleLogin}
            activeOpacity={0.85}
            disabled={loggingIn}
            style={[styles.submitBtn, { backgroundColor: colors.tint }]}
          >
            <ThemedText style={[styles.submitBtnText, { color: '#fff' }]}>
              {loggingIn ? 'Signing in…' : 'Sign In'}
            </ThemedText>
          </TouchableOpacity>
        </ThemedView>

        <ThemedView style={styles.footer}>
          <ThemedText style={{ fontSize: 13, opacity: 0.6 }}>
            Don&apos;t have an account?{' '}
          </ThemedText>
          <Link href="/register">
            <ThemedText style={[styles.linkText, { color: colors.tint }]}>Create one</ThemedText>
          </Link>
        </ThemedView>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingHorizontal: 26,
    paddingVertical: 44,
    gap: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 8,
  },
  form: {
    gap: 14,
  },
  label: {
    fontSize: 13,
    opacity: 0.7,
  },
  inputBox: {
    borderWidth: 1.2,
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 12,
    minHeight: 50,
    justifyContent: 'center',
  },
  input: {
    fontSize: 15,
    lineHeight: 22,
    fontFamily: Fonts.sans,
  },
  submitBtn: {
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 6,
  },
  submitBtnText: {
    fontSize: 16,
    fontWeight: '700',
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 10,
  },
  linkText: {
    fontSize: 13,
    fontWeight: '600',
  },
});
