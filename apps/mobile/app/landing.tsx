import {
  StyleSheet,
  View,
  ScrollView,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import Animated, {
  FadeInDown,
  FadeInUp,
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withSequence,
  withTiming,
} from 'react-native-reanimated';
import {
  ShoppingBag,
  TrendingUp,
  Users,
  Truck,
  ArrowRight,
  Package,
} from 'lucide-react-native';
import { useEffect } from 'react';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { Colors, Fonts } from '@/constants/theme';

const { width } = Dimensions.get('window');

const features = [
  {
    icon: ShoppingBag,
    title: 'Track Every Order',
    description:
      'Manage customer orders from supplier to delivery without WhatsApp confusion.',
  },
  {
    icon: TrendingUp,
    title: 'Know Your Profit',
    description:
      'Automatically calculate profit, balances, and total revenue in real time.',
  },
  {
    icon: Users,
    title: 'Customer History',
    description:
      'See repeat buyers, order history, and outstanding balances instantly.',
  },
  {
    icon: Truck,
    title: 'Delivery Tracking',
    description:
      'Track every order stage from supplier shipment to customer delivery.',
  },
];

export default function LandingScreen() {
  const colorScheme: 'light' | 'dark' =
    useColorScheme() === 'dark' ? 'dark' : 'light';

  const colors = Colors[colorScheme];
  const isDark = colorScheme === 'dark';
  const router = useRouter();

  const floating = useSharedValue(0);

  useEffect(() => {
    floating.value = withRepeat(
      withSequence(
        withTiming(-12, { duration: 2000 }),
        withTiming(0, { duration: 2000 })
      ),
      -1,
      true
    );
  }, []);

  const animatedPhoneStyle = useAnimatedStyle(() => {
    return {
      transform: [{ translateY: floating.value }],
    };
  });

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: colors.background }]}
      showsVerticalScrollIndicator={false}
    >
      {/* HERO SECTION */}
      <LinearGradient
        colors={isDark ? ['#07141D', '#0A7EA4'] : ['#0A7EA4', '#11A8D8']}
        style={styles.hero}
      >
        {/* Logo */}
        <Animated.View entering={FadeInUp.duration(700)} style={styles.logoRow}>
          <View style={styles.logoBox}>
            <Package color="#fff" size={20} strokeWidth={2.5} />
          </View>

          <ThemedText style={styles.brandName}>Reselio</ThemedText>
        </Animated.View>

        {/* Headline */}
        <Animated.View entering={FadeInDown.duration(900)}>
          <ThemedText style={styles.headline}>
            Stop managing your business in WhatsApp chats.
          </ThemedText>

          <ThemedText style={styles.subHeadline}>
            Reselio helps social-commerce sellers track orders, profits,
            deliveries, and customers in one simple workspace.
          </ThemedText>
        </Animated.View>

        {/* CTA */}
        <Animated.View
          entering={FadeInDown.delay(200).duration(900)}
          style={styles.heroButtons}
        >
          <TouchableOpacity
            activeOpacity={0.9}
            style={styles.primaryBtn}
            onPress={() => router.push('/register')}
          >
            <ThemedText style={styles.primaryBtnText}>
              Start Free
            </ThemedText>

            <ArrowRight size={18} color="#fff" />
          </TouchableOpacity>

          <TouchableOpacity
            activeOpacity={0.9}
            style={styles.secondaryBtn}
            onPress={() => router.push('/login')}
          >
            <ThemedText style={styles.secondaryBtnText}>
              Sign In
            </ThemedText>
          </TouchableOpacity>
        </Animated.View>

        {/* PHONE MOCKUP */}
        <Animated.View
          style={[styles.phoneWrapper, animatedPhoneStyle]}
          entering={FadeInUp.delay(300).duration(1000)}
        >
          <View style={styles.phoneMockup}>
            <View style={styles.phoneHeader}>
              <View>
                <ThemedText style={styles.phoneTitle}>
                  Dashboard
                </ThemedText>

                <ThemedText style={styles.phoneSubtitle}>
                  Welcome back 👋
                </ThemedText>
              </View>

              <View style={styles.greenDot} />
            </View>

            <View style={styles.metricCard}>
              <ThemedText style={styles.metricLabel}>
                Total Revenue
              </ThemedText>

              <ThemedText style={styles.metricValue}>
                1,240,000 FCFA
              </ThemedText>
            </View>

            <View style={styles.smallCardsRow}>
              <View style={styles.smallCard}>
                <ThemedText style={styles.smallCardNumber}>42</ThemedText>
                <ThemedText style={styles.smallCardLabel}>
                  Orders
                </ThemedText>
              </View>

              <View style={styles.smallCard}>
                <ThemedText style={styles.smallCardNumber}>18</ThemedText>
                <ThemedText style={styles.smallCardLabel}>
                  Deliveries
                </ThemedText>
              </View>
            </View>
          </View>
        </Animated.View>
      </LinearGradient>

      {/* FEATURES */}
      <ThemedView style={styles.featuresSection}>
        <ThemedText style={styles.sectionBadge}>
          WHY RESELIO
        </ThemedText>

        <ThemedText style={styles.sectionTitle}>
          Everything a reseller needs to stay organized.
        </ThemedText>

        {features.map((feature, index) => {
          const Icon = feature.icon;

          return (
            <Animated.View
              entering={FadeInUp.delay(index * 120).duration(700)}
              key={feature.title}
            >
              <ThemedView
                style={[
                  styles.featureCard,
                  {
                    backgroundColor: isDark ? '#111C24' : '#FFFFFF',
                  },
                ]}
              >
                <View style={styles.iconContainer}>
                  <Icon color="#0A7EA4" size={24} strokeWidth={2.3} />
                </View>

                <View style={styles.featureContent}>
                  <ThemedText style={styles.featureTitle}>
                    {feature.title}
                  </ThemedText>

                  <ThemedText style={styles.featureDescription}>
                    {feature.description}
                  </ThemedText>
                </View>
              </ThemedView>
            </Animated.View>
          );
        })}
      </ThemedView>

      {/* FINAL CTA */}
      <LinearGradient
        colors={isDark ? ['#0E1A22', '#102C39'] : ['#F5FBFF', '#E7F7FF']}
        style={styles.bottomCTA}
      >
        <ThemedText style={styles.bottomTitle}>
          Built for WhatsApp & Instagram sellers.
        </ThemedText>

        <ThemedText style={styles.bottomDescription}>
          No spreadsheets. No notebooks. No confusing accounting software.
          Just simple business management.
        </ThemedText>

        <TouchableOpacity
          activeOpacity={0.9}
          style={[styles.primaryBtn, { marginTop: 18 }]}
          onPress={() => router.push('/register')}
        >
          <ThemedText style={styles.primaryBtnText}>
            Create Free Account
          </ThemedText>
        </TouchableOpacity>
      </LinearGradient>

      {/* FOOTER */}
      <ThemedView style={styles.footer}>
        <ThemedText style={styles.footerText}>
          Reselio · Business management for modern resellers
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
    paddingHorizontal: 24,
    paddingBottom: 60,
    borderBottomLeftRadius: 36,
    borderBottomRightRadius: 36,
  },

  logoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 28,
  },

  logoBox: {
    width: 42,
    height: 42,
    borderRadius: 14,
    backgroundColor: 'rgba(255,255,255,0.16)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },

  brandName: {
    fontSize: 28,
    color: '#fff',
    fontFamily: Fonts.rounded,
    fontWeight: '800',
  },

  headline: {
    fontSize: 38,
    lineHeight: 48,
    color: '#fff',
    fontWeight: '800',
    marginBottom: 16,
  },

  subHeadline: {
    fontSize: 16,
    lineHeight: 28,
    color: 'rgba(255,255,255,0.85)',
    maxWidth: width * 0.9,
  },

  heroButtons: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginTop: 30,
  },

  primaryBtn: {
    backgroundColor: '#11181C',
    paddingVertical: 15,
    paddingHorizontal: 22,
    borderRadius: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },

  primaryBtnText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 15,
  },

  secondaryBtn: {
    borderWidth: 1.4,
    borderColor: 'rgba(255,255,255,0.4)',
    paddingVertical: 15,
    paddingHorizontal: 22,
    borderRadius: 16,
  },

  secondaryBtnText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 15,
  },

  phoneWrapper: {
    alignItems: 'center',
    marginTop: 44,
  },

  phoneMockup: {
    width: width * 0.72,
    backgroundColor: '#fff',
    borderRadius: 34,
    padding: 20,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 18,
    shadowOffset: {
      width: 0,
      height: 10,
    },
    elevation: 10,
  },

  phoneHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 18,
  },

  phoneTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#11181C',
  },

  phoneSubtitle: {
    fontSize: 12,
    color: '#687076',
    marginTop: 4,
  },

  greenDot: {
    width: 12,
    height: 12,
    borderRadius: 999,
    backgroundColor: '#22C55E',
  },

  metricCard: {
    backgroundColor: '#0A7EA4',
    borderRadius: 22,
    padding: 18,
    marginBottom: 14,
  },

  metricLabel: {
    color: 'rgba(255,255,255,0.8)',
    fontSize: 13,
  },

  metricValue: {
    color: '#fff',
    fontSize: 24,
    fontWeight: '800',
    marginTop: 6,
  },

  smallCardsRow: {
    flexDirection: 'row',
    gap: 12,
  },

  smallCard: {
    flex: 1,
    backgroundColor: '#F4F7FA',
    borderRadius: 18,
    paddingVertical: 18,
    alignItems: 'center',
  },

  smallCardNumber: {
    fontSize: 22,
    fontWeight: '800',
    color: '#11181C',
  },

  smallCardLabel: {
    marginTop: 6,
    color: '#687076',
    fontSize: 12,
  },

  featuresSection: {
    paddingHorizontal: 24,
    marginTop: 40,
    gap: 16,
  },

  sectionBadge: {
    color: '#0A7EA4',
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 1,
  },

  sectionTitle: {
    fontSize: 28,
    lineHeight: 38,
    fontWeight: '800',
    marginBottom: 12,
  },

  featureCard: {
    borderRadius: 24,
    padding: 20,
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 16,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 12,
    shadowOffset: {
      width: 0,
      height: 6,
    },
    elevation: 2,
  },

  iconContainer: {
    width: 52,
    height: 52,
    borderRadius: 16,
    backgroundColor: '#E8F8FF',
    justifyContent: 'center',
    alignItems: 'center',
  },

  featureContent: {
    flex: 1,
  },

  featureTitle: {
    fontSize: 17,
    fontWeight: '700',
    marginBottom: 6,
  },

  featureDescription: {
    fontSize: 14,
    lineHeight: 24,
    opacity: 0.7,
  },

  bottomCTA: {
    marginHorizontal: 24,
    marginTop: 42,
    borderRadius: 28,
    padding: 26,
  },

  bottomTitle: {
    fontSize: 28,
    lineHeight: 38,
    fontWeight: '800',
    marginBottom: 12,
  },

  bottomDescription: {
    fontSize: 15,
    lineHeight: 26,
    opacity: 0.7,
  },

  footer: {
    paddingVertical: 30,
    alignItems: 'center',
  },

  footerText: {
    fontSize: 12,
    opacity: 0.5,
  },
});
