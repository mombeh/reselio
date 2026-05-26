import { useEffect, useState } from 'react';
import { View, ScrollView, Platform, Image } from 'react-native';
import { StyleSheet } from 'react-native';

import { Collapsible } from '@/components/ui/collapsible';
import { ExternalLink } from '@/components/external-link';
import ParallaxScrollView from '@/components/parallax-scroll-view';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { IconSymbol } from '@/components/ui/icon-symbol';
import { Colors, Fonts } from '@/constants/theme';
import { ordersApi, MonthlyPoint, TopProduct } from '@/services/api';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { useAuth } from '@/contexts/AuthContext';

type ChartRow = { month: string; revenue: number; orders: number };

function RevenueBar({
  data,
  color,
  isDark,
}: {
  data: ChartRow[];
  color: string;
  isDark: boolean;
}) {
  const max = Math.max(...data.map((d: ChartRow) => d.revenue), 1);
  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.barScroll}>
      {data.map((d, i) => (
        <ThemedView
          key={i}
          style={[
            styles.barCol,
            { backgroundColor: isDark ? '#1E2A30' : '#F5FAFE', borderBottomColor: color },
          ]}
        >
          <ThemedText style={styles.barLabel}>{d.month}</ThemedText>
          <View style={[styles.barOuter, { backgroundColor: isDark ? '#2E3B42' : '#C5D8E6' }]}>
            <View style={[styles.barInner, { height: `${(d.revenue / max) * 100}%`, backgroundColor: color }]} />
          </View>
          <ThemedText style={[styles.barRevenue, { color }]}>
            ₦{(d.revenue / 1000).toFixed(0)}k
          </ThemedText>
          <ThemedText style={[styles.barOrders, { opacity: 0.5 }]}>{d.orders} orders</ThemedText>
        </ThemedView>
      ))}
    </ScrollView>
  );
}

export default function TabTwoScreen() {
  const scheme: 'light' | 'dark' = useColorScheme() === 'dark' ? 'dark' : 'light';
  const isDark = scheme === 'dark';
  const colors = Colors[scheme];
  const tintColor = colors.tint;
  const { token } = useAuth();

  const [monthly, setMonthly] = useState<MonthlyPoint[]>([]);
  const [topProducts, setTopProducts] = useState<TopProduct[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;
    setLoading(true);
    setError(null);

    void Promise.allSettled([ordersApi.getMonthlyAnalytics(token), ordersApi.getTopProducts(token)])
      .then((results) => {
        if (results[0].status === 'fulfilled') setMonthly(results[0].value);
        else if (results[1].status === 'fulfilled') setTopProducts(results[1].value);
      })
      .catch((e: any) => setError(e.message ?? 'Failed to load'))
      .finally(() => setLoading(false));
  }, [token]);

  const monthlyChart: ChartRow[] = monthly.map((m) => ({
    month: `${m._id.month.toString().padStart(2, '0')}/${m._id.year.toString().slice(-2)}`,
    revenue: m.totalRevenue,
    orders: m.totalOrders,
  }));

  if (!token) {
    return (
      <ThemedView style={styles.signedOut}>
        <ThemedText type="title" style={{ color: colors.tint, marginBottom: 8 }}>Analytics</ThemedText>
        <ThemedText style={{ textAlign: 'center', opacity: 0.6 }}>
          Sign in to view monthly revenue, top products, and order trends.
        </ThemedText>
      </ThemedView>
    );
  }

  return (
    <ParallaxScrollView
      headerBackgroundColor={{ light: '#8ECAE6', dark: '#1C3A4A' }}
      headerImage={
        <IconSymbol
          size={310}
          color="#4A90B8"
          name="chart.line.uptrend.xyaxis"
          style={styles.headerImage}
        />
      }>
      <ThemedView style={styles.titleContainer}>
        <ThemedText type="title" style={{ fontFamily: Fonts.rounded }}>
          Analytics
        </ThemedText>
      </ThemedView>

      {error ? (
        <ThemedView style={styles.errorBox}>
          <ThemedText style={{ color: '#E74C3C' }}>{error}</ThemedText>
        </ThemedView>
      ) : null}

      {/* Monthly revenue chart */}
      <ThemedView style={[styles.chartSection, { backgroundColor: isDark ? '#1E2A30' : '#F5FAFE' }]}>
        <ThemedText type="defaultSemiBold" style={styles.sectionHeading}>
          Monthly Revenue
        </ThemedText>
        {loading ? (
          <ThemedText style={{ opacity: 0.5 }}>Loading…</ThemedText>
        ) : (
          <RevenueBar data={monthlyChart} color={colors.tint} isDark={isDark} />
        )}
      </ThemedView>

      {/* Top products */}
      <ThemedView style={[styles.section, { backgroundColor: isDark ? '#1E2A30' : '#F5FAFE' }]}>
        <ThemedText type="defaultSemiBold" style={styles.sectionHeading}>
          Top Products by Revenue
        </ThemedText>
        {topProducts.length === 0 ? (
          <ThemedText style={{ opacity: 0.4 }}>No product data yet.</ThemedText>
        ) : (
          topProducts.map((p, i) => (
            <ThemedView key={i} style={[styles.productRow, { borderBottomColor: isDark ? '#2E3B42' : '#C5D8E6' }]}>
              <ThemedView style={{ flex: 1 }}>
                <ThemedText style={styles.productName}>{p._id}</ThemedText>
                <ThemedText style={[styles.productMeta, { opacity: 0.5 }]}>
                  {p.totalOrders} orders
                </ThemedText>
              </ThemedView>
              <ThemedText style={[styles.productRevenue, { color: colors.tint }]}>
                ₦{p.totalRevenue.toLocaleString()}
              </ThemedText>
            </ThemedView>
          ))
        )}
      </ThemedView>

      <Collapsible title="How are metrics calculated?">
        <ThemedText>
          Revenue, profit, and order counts are aggregated server-side from your order data using MongoDB aggregation pipelines. Results are refreshed on every page load.
        </ThemedText>
      </Collapsible>
      <Collapsible title="Export your data">
        <ThemedText>
          Tap on the export option in your dashboard to download all orders as a CSV file — perfect for accounting or audits.
        </ThemedText>
        <ExternalLink href="https://expo.dev">
          <ThemedText type="link">Learn more</ThemedText>
        </ExternalLink>
      </Collapsible>
    </ParallaxScrollView>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    alignItems: 'center',
    gap: 8,
    marginVertical: 8,
  },
  headerImage: {
    color: '#808080',
    bottom: -90,
    left: -35,
    position: 'absolute',
  },
  signedOut: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  errorBox: {
    padding: 12,
    borderRadius: 10,
    backgroundColor: 'rgba(231,76,60,0.1)',
  },
  sectionHeading: {
    fontSize: 15,
    marginBottom: 12,
  },
  chartSection: {
    padding: 16,
    borderRadius: 14,
    gap: 8,
  },
  barScroll: {
    paddingVertical: 8,
    gap: 10,
  },
  barCol: {
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 10,
    borderRadius: 10,
    minWidth: 58,
    gap: 4,
    borderBottomWidth: 3,
  },
  barLabel: {
    fontSize: 11,
    fontWeight: '600',
    opacity: 0.7,
  },
  barOuter: {
    width: 22,
    height: 100,
    borderRadius: 6,
    overflow: 'hidden',
    justifyContent: 'flex-end',
  },
  barInner: {
    width: '100%',
    borderRadius: 4,
  },
  barRevenue: {
    fontSize: 10,
    fontWeight: '700',
  },
  barOrders: {
    fontSize: 10,
  },
  section: {
    marginTop: 16,
    padding: 16,
    borderRadius: 14,
    gap: 2,
  },
  productRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  productName: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 2,
  },
  productMeta: {
    fontSize: 12,
  },
  productRevenue: {
    fontSize: 14,
    fontWeight: '700',
    minWidth: 90,
    textAlign: 'right',
  },
});
