import { StyleSheet, View, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { Colors, Fonts } from '@/constants/theme';

const features = [
  {
    icon: '📦',
    title: 'Track every customer order',
    description:
      'Follow orders from supplier to delivery without losing details in WhatsApp chats.',
  },
  {
    icon: '💰',
    title: 'Know your real profit',
    description:
      'Automatically calculate balances, revenue, and profit for every sale.',
  },
  {
    icon: '🚚',
    title: 'Manage deliveries easily',
    description:
      'Track delivery progress and know exactly which orders are pending.',
  },
  {
    icon: '👥',
    title: 'Build customer loyalty',
    description:
      'Keep customer history, repeat orders, and payment records in one place.',
  },
];

export default function LandingScreen() {
  const colorScheme: 'light' | 'dark' =
    useColorScheme() === 'dark' ? 'dark' : 'light';

  const colors = Colors[colorScheme];
  const isDark = colorScheme === 'dark';
  const router = useRouter();

  return (
    <ScrollView
      showsVerticalScrollIndicator={false}
      style={[styles.container, { backgroundColor: colors.background }]}
    >
      {/* HERO */}
      <ThemedView
        style={[
          styles.hero,
          {
            backgroundColor: isDark ? '#0C2D3F' : '#0A7EA4',
          },
        ]}
      >
        <View style={styles.heroTop}>
          <View style={styles.logoCircle}>
            <ThemedText style={styles.logoText}>R</ThemedText>
          </View>

          <ThemedText style={styles.brandName}>Reselio</ThemedText>
        </View>

        <ThemedText style={styles.heroTitle}>
          Track orders, profits, and deliveries in one place.
        </ThemedText>

        <ThemedText style={styles.heroDescription}>
          Built for WhatsApp and Instagram sellers who want to run their
          business in a simpler and more organized way.
        </ThemedText>

        {/* MINI STATS */}
        <View style={styles.statsContainer}>
          <View
            style={[
              styles.statCard,
              { backgroundColor: 'rgba(255,255,255,0.12)' },
            ]}
          >
            <ThemedText style={styles.statNumber}>24</ThemedText>
            <ThemedText style={styles.statLabel}>Orders</ThemedText>
          </View>

          <View
            style={[
              styles.statCard,
              { backgroundColor: 'rgba(255,255,255,0.12)' },
            ]}
          >
            <ThemedText style={styles.statNumber}>120K</ThemedText>
            <ThemedText style={styles.statLabel}>Profit</ThemedText>
          </View>

          <View
            style={[
              styles.statCard,
              { backgroundColor: 'rgba(255,255,255,0.12)' },
            ]}
          >
            <ThemedText style={styles.statNumber}>5</ThemedText>
            <ThemedText style={styles.statLabel}>Pending</ThemedText>
          </View>
        </View>
      </ThemedView>

      {/* PAIN POINT */}
      <ThemedView style={styles.problemSection}>
        <ThemedText style={styles.problemTitle}>
          Still managing orders inside WhatsApp chats?
        </ThemedText>

        <ThemedText style={styles.problemText}>
          Reselio helps you organize customer orders, balances, deliveries,
          and profits without notebooks or spreadsheets.
        </ThemedText>
      </ThemedView>

      {/* FEATURES */}
      <ThemedView style={styles.featuresSection}>
        <ThemedText type="subtitle" style={styles.sectionTitle}>
          Everything you need to manage your reseller business
        </ThemedText>

        {features.map((feature, index) => (
          <ThemedView
            key={index}
            style={[
              styles.featureCard,
              {
                backgroundColor: isDark ? '#182229' : '#F5FAFE',
              },
            ]}
          >
            <ThemedText style={styles.featureIcon}>
              {feature.icon}
            </ThemedText>

            <View style={styles.featureBody}>
              <ThemedText
                type="defaultSemiBold"
                style={styles.featureTitle}
              >
                {feature.title}
              </ThemedText>

              <ThemedText style={styles.featureDescription}>
                {feature.description}
              </ThemedText>
            </View>
          </ThemedView>
        ))}
      </ThemedView>

      {/* CTA */}
      <ThemedView style={styles.ctaSection}>
        <TouchableOpacity
          onPress={() => router.push('/register')}
          activeOpacity={0.9}
          style={[
            styles.primaryBtn,
            {
              backgroundColor: colors.tint,
            },
          ]}
        >
          <ThemedText style={styles.primaryBtnText}>
            Start organizing your business
          </ThemedText>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => router.push('/login')}
          activeOpacity={0.85}
          style={[
            styles.secondaryBtn,
            {
              borderColor: isDark ? '#3A4046' : '#D0D7DE',
            },
          ]}
        >
          <ThemedText
            style={[
              styles.secondaryBtnText,
              {
                color: colors.text,
              },
            ]}
          >
            I already have an account
          </ThemedText>
        </TouchableOpacity>
      </ThemedView>

      {/* FOOTER */}
      <ThemedView style={styles.footer}>
        <ThemedText style={styles.footerText}>
          Built for modern WhatsApp & Instagram resellers.
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
    paddingTop: 78,
    paddingBottom: 44,
    paddingHorizontal: 24,
    borderBottomLeftRadius: 34,
    borderBottomRightRadius: 34,
  },

  heroTop: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 28,
  },

  logoCircle: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },

  logoText: {
    fontSize: 20,
    fontWeight: '800',
    color: '#0A7EA4',
  },

  brandName: {
    fontSize: 28,
    fontFamily: Fonts.rounded,
    fontWeight: '700',
    color: '#fff',
  },

  heroTitle: {
    fontSize: 34,
    lineHeight: 42,
    color: '#fff',
    fontWeight: '800',
    marginBottom: 16,
  },

  heroDescription: {
    fontSize: 16,
    lineHeight: 26,
    color: 'rgba(255,255,255,0.88)',
  },

  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 32,
    gap: 10,
  },

  statCard: {
    flex: 1,
    paddingVertical: 18,
    borderRadius: 18,
    alignItems: 'center',
  },

  statNumber: {
    fontSize: 20,
    fontWeight: '800',
    color: '#fff',
    marginBottom: 4,
  },

  statLabel: {
    fontSize: 13,
    color: 'rgba(255,255,255,0.8)',
  },

  problemSection: {
    paddingHorizontal: 24,
    marginTop: 34,
  },

  problemTitle: {
    fontSize: 24,
    lineHeight: 34,
    fontWeight: '700',
    marginBottom: 12,
    textAlign: 'center',
  },

  problemText: {
    fontSize: 15,
    lineHeight: 26,
    opacity: 0.7,
    textAlign: 'center',
  },

  featuresSection: {
    paddingHorizontal: 22,
    marginTop: 36,
    gap: 16,
  },

  sectionTitle: {
    textAlign: 'center',
    fontSize: 18,
    marginBottom: 10,
  },

  featureCard: {
    flexDirection: 'row',
    padding: 18,
    borderRadius: 18,
    gap: 14,
    alignItems: 'flex-start',
  },

  featureIcon: {
    fontSize: 28,
    marginTop: 2,
  },

  featureBody: {
    flex: 1,
  },

  featureTitle: {
    fontSize: 16,
    marginBottom: 6,
  },

  featureDescription: {
    fontSize: 14,
    lineHeight: 22,
    opacity: 0.72,
  },

  ctaSection: {
    paddingHorizontal: 22,
    marginTop: 42,
    gap: 14,
  },

  primaryBtn: {
    paddingVertical: 18,
    borderRadius: 16,
    alignItems: 'center',
  },

  primaryBtnText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },

  secondaryBtn: {
    paddingVertical: 17,
    borderRadius: 16,
    alignItems: 'center',
    borderWidth: 1.2,
  },

  secondaryBtnText: {
    fontSize: 15,
    fontWeight: '600',
  },

  footer: {
    marginTop: 44,
    marginBottom: 34,
    paddingHorizontal: 24,
  },

  footerText: {
    fontSize: 13,
    textAlign: 'center',
    opacity: 0.45,
  },
});