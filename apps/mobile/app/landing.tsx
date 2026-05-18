import { StyleSheet, View, ScrollView, TouchableOpacity, Platform } from 'react-native';
import { useRouter } from 'expo-router';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { Colors, Fonts } from '@/constants/theme';

const features = [
  {
    icon: '📦',
    title: 'Track Every Order',
    description: 'Monitor stock flow from supplier to customer with clear status stages.',
  },
  {
    icon: '📊',
    title: 'Live Analytics',
    description: 'Revenue, profit, and delivery metrics updated in real time.',
  },
  {
    icon: '👥',
    title: 'Customer Profiles',
    description: "Keep every customer's history, spend, and balance at your fingertips.",
  },
  {
    icon: '📄',
    title: 'Export to CSV',
    description: 'Download your full order history for accounting or audits.',
  },
];

export default function LandingScreen() {
  const colorScheme: 'light' | 'dark' = useColorScheme() === 'dark' ? 'dark' : 'light';
  const colors = Colors[colorScheme];
  const isDark = colorScheme === 'dark';
  const router = useRouter();

  return (
    <ScrollView style={[styles.container, { backgroundColor: colors.background }]}>
      {/* ── Hero ── */}
      <ThemedView style={[styles.hero, { backgroundColor: isDark ? '#0C2D3F' : '#0A7EA4' }]}>
        <ThemedText style={styles.brandName}>Reselio</ThemedText>
        <ThemedText style={styles.tagline}>Manage your orders.</ThemedText>
        <ThemedText style={styles.tagline}>Grow your sales.</ThemedText>
      </ThemedView>

      {/* ── Features ── */}
      <ThemedView style={styles.featuresSection}>
        <ThemedText type="subtitle" style={styles.sectionTitle}>
          Everything you need to run your store
        </ThemedText>

        {features.map((feature, index) => (
          <ThemedView key={index} style={[styles.featureCard, { backgroundColor: isDark ? '#1E2A30' : '#F5FAFE' }]}>
            <ThemedText style={styles.featureIcon}>{feature.icon}</ThemedText>
            <View style={styles.featureBody}>
              <ThemedText type="defaultSemiBold" style={styles.featureTitle}>{feature.title}</ThemedText>
              <ThemedText style={styles.featureDescription}>{feature.description}</ThemedText>
            </View>
          </ThemedView>
        ))}
      </ThemedView>

      {/* ── CTA ── */}
      <ThemedView style={styles.ctaSection}>
        <TouchableOpacity
          onPress={() => router.push('/login')}
          activeOpacity={0.85}
          style={[styles.primaryBtn, { backgroundColor: isDark ? '#fff' : colors.tint }]}
        >
          <ThemedText style={[styles.primaryBtnText, { color: isDark ? '#000' : '#fff' }]}>
            Sign in to your account
          </ThemedText>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => router.push('/register')}
          activeOpacity={0.85}
          style={[styles.secondaryBtn, { borderColor: isDark ? '#9BA1A6' : '#687076' }]}
        >
          <ThemedText style={[styles.secondaryBtnText, { color: isDark ? '#ECEDEE' : '#11181C' }]}>
            Create a new account
          </ThemedText>
        </TouchableOpacity>
      </ThemedView>

      <ThemedView style={styles.footer}>
        <ThemedText style={{ fontSize: 12, textAlign: 'center', opacity: 0.5 }}>
          Reselio · Order management for modern retailers
        </ThemedText>
      </ThemedView>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  hero: {
    paddingTop: 72,
    paddingBottom: 52,
    paddingHorizontal: 28,
    borderBottomLeftRadius: 32,
    borderBottomRightRadius: 32,
  },
  brandName: {
    fontSize: 40,
    fontFamily: Fonts.rounded,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 6,
  },
  tagline: {
    fontSize: 22,
    fontFamily: Fonts.rounded,
    color: 'rgba(255,255,255,0.9)',
  },
  featuresSection: {
    paddingHorizontal: 22,
    marginTop: 32,
    gap: 14,
  },
  sectionTitle: {
    fontSize: 18,
    marginBottom: 6,
    textAlign: 'center',
  },
  featureCard: {
    flexDirection: 'row',
    padding: 16,
    borderRadius: 14,
    gap: 14,
    alignItems: 'center',
  },
  featureIcon: {
    fontSize: 32,
    lineHeight: 36,
  },
  featureBody: {
    flex: 1,
  },
  featureTitle: {
    fontSize: 16,
    marginBottom: 3,
  },
  featureDescription: {
    fontSize: 13,
    lineHeight: 20,
    opacity: 0.7,
  },
  ctaSection: {
    paddingHorizontal: 22,
    marginTop: 36,
    gap: 12,
  },
  primaryBtn: {
    paddingVertical: 15,
    borderRadius: 14,
    alignItems: 'center',
  },
  primaryBtnText: {
    fontSize: 16,
    fontWeight: '700',
  },
  secondaryBtn: {
    paddingVertical: 14,
    borderRadius: 14,
    alignItems: 'center',
    borderWidth: 1.5,
    backgroundColor: 'transparent',
  },
  secondaryBtnText: {
    fontSize: 16,
    fontWeight: '600',
  },
  footer: {
    marginTop: 40,
    marginBottom: 28,
  },
});
