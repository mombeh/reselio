import { useEffect, useState } from "react";
import {
  View,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
} from "react-native";
import { Link } from "expo-router";

import { ThemedText } from "@/components/themed-text";
import { ThemedView } from "@/components/themed-view";
import { useColorScheme } from "@/hooks/use-color-scheme";
import { Colors } from "@/constants/theme";
import {
  ordersApi,
  DashboardMetrics,
  StatusBreakdown,
  Order,
} from "@/services/api";
import { useAuth } from "@/contexts/AuthContext";
import { router } from "expo-router";

function formatPct(val: number) {
  if (val === 0) return "0%";
  return `${Math.min(Math.round((val / 101) * 100), 99)}%`;
}

export default function HomeScreen() {
  const colorScheme: "light" | "dark" =
    useColorScheme() === "dark" ? "dark" : "light";
  const colors = Colors[colorScheme];
  const isDark = colorScheme === "dark";
  const { token, logout } = useAuth();
  const [recentOrders, setRecentOrders] = useState<Order[]>([]);

  const [dashboard, setDashboard] = useState<DashboardMetrics | null>(null);
  const [statusBreakdown, setStatusBreakdown] = useState<StatusBreakdown[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;

    let cancelled = false;

    async function load() {
      try {
        setLoading(true);
        setError(null);
        const recentOrdersRes = await ordersApi.getAll(token!, {
          page: 1,
          limit: 5,
        });
        setRecentOrders(recentOrdersRes.data);

        const [dashStatus, dashMetrics] = await Promise.allSettled([
          ordersApi.getDashboard(token!),
          ordersApi.getStatusBreakdown(token!),
        ]);

        if (cancelled) return;

        if (dashStatus.status === "fulfilled") {
          setDashboard(dashStatus.value);
        }
        if (dashMetrics.status === "fulfilled") {
          setStatusBreakdown(dashMetrics.value);
        }
      } catch (e: any) {
        if (!cancelled) setError(e.message ?? "Failed to load data");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    void load();
    return () => {
      cancelled = true;
    };
  }, [token]);

  if (!token) {
    return (
      <ThemedView
        style={[
          styles.container,
          styles.center,
          { backgroundColor: colors.background },
        ]}
      >
        <ThemedText type="title" style={{ color: colors.text, opacity: 0.5 }}>
          Reselio
        </ThemedText>
        <ThemedText style={{ fontSize: 14, opacity: 0.4, marginTop: 4 }}>
          Please sign in to view your dashboard.
        </ThemedText>
        <Link href="/login" asChild>
          <TouchableOpacity
            style={[styles.emptyBtn, { backgroundColor: colors.tint }]}
          >
            <ThemedText style={{ color: "#fff", fontWeight: "700" }}>
              Sign In
            </ThemedText>
          </TouchableOpacity>
        </Link>
      </ThemedView>
    );
  }

  if (loading) {
    return (
      <ThemedView
        style={[
          styles.container,
          styles.center,
          { backgroundColor: colors.background },
        ]}
      >
        <ActivityIndicator size="large" color={colors.tint} />
        <ThemedText style={{ marginTop: 12, opacity: 0.5 }}>
          Loading dashboard…
        </ThemedText>
      </ThemedView>
    );
  }

  if (error) {
    return (
      <ThemedView
        style={[
          styles.container,
          styles.center,
          { backgroundColor: colors.background },
        ]}
      >
        <ThemedText style={{ color: "#E74C3C", textAlign: "center" }}>
          {error}
        </ThemedText>
        <TouchableOpacity
          onPress={() => {
            setLoading(true);
            setError(null);
          }}
          style={[styles.emptyBtn, { backgroundColor: colors.tint }]}
        >
          <ThemedText
            style={{ color: "#fff", fontWeight: "600", fontSize: 14 }}
          >
            Retry
          </ThemedText>
        </TouchableOpacity>
      </ThemedView>
    );
  }

  const statCards = dashboard
    ? [
        {
          label: "Total Orders",
          value: String(dashboard.totalOrders),
          color: "#0A7EA4",
        },
        {
          label: "Total Revenue",
          value: `${dashboard.totalRevenue.toLocaleString()} FCFA`,
          color: "#27AE60",
        },
        {
          label: "Total Profit",
          value: `${dashboard.totalProfit.toLocaleString()} FCFA`,
          color: "#F0A500",
        },
        {
          label: "Pending Deliveries",
          value: String(dashboard.pendingDeliveries),
          color: "#E74C3C",
        },
        {
          label: "Outstanding Balances",
          value: `${dashboard.outstandingBalances.toLocaleString()} FCFA`,
          color: "#8E44AD",
        },
      ]
    : [];

  return (
    <ScrollView
      showsVerticalScrollIndicator={false}
      contentContainerStyle={[
        styles.container,
        { backgroundColor: colors.background },
      ]}
    >
      {/* Header */}
      <ThemedView style={styles.header}>
        <View>
          <ThemedText
            style={{
              fontSize: 28,
              fontWeight: "700",
            }}
          >
            Welcome Back
          </ThemedText>

          <ThemedText
            style={{
              opacity: 0.6,
              marginTop: 4,
            }}
          >
            Here's your business summary
          </ThemedText>
        </View>
        {/* <TouchableOpacity
          style={styles.logoutBtn}
          onPress={async () => {
            await logout();
          }}
        >
          <ThemedText style={styles.logoutBtnText}>Logout</ThemedText>
        </TouchableOpacity> */}
      </ThemedView>

      {/* Stats grid */}
      <View style={styles.statsGrid}>
        {statCards.map((card, i) => (
          <ThemedView
            key={i}
            style={[
              styles.statCard,
              {
                backgroundColor: isDark ? "#1E2A30" : "#F5FAFE",
                borderLeftColor: card.color,
              },
            ]}
          >
            <ThemedText style={[styles.statValue, { color: card.color }]}>
              {card.value}
            </ThemedText>
            <ThemedText style={[styles.statLabel, { opacity: 0.6 }]}>
              {card.label}
            </ThemedText>
          </ThemedView>
        ))}
      </View>

      {/* Status breakdown */}
      <ThemedView
        style={[
          styles.section,
          { backgroundColor: isDark ? "#1E2A30" : "#F5FAFE" },
        ]}
      >
        <ThemedView
          style={[
            styles.healthCard,
            {
              backgroundColor: isDark ? "#1E2A30" : "#F5FAFE",
            },
          ]}
        >
          <ThemedText style={styles.sectionTitle}>Business Health</ThemedText>
          <ThemedText style={{ opacity: 0.6, fontSize: 13 }}>
            Your business is doing great! Keep up the good work and continue
            providing excellent service to your customers.
          </ThemedText>
        </ThemedView>

        {statusBreakdown.length === 0 ? (
          <View style={styles.emptyState}>
            <ThemedText style={styles.emptyTitle}>No orders yet</ThemedText>

            <ThemedText style={styles.emptyDescription}>
              Create your first order to start tracking sales, profits and
              customer balances.
            </ThemedText>

            <TouchableOpacity
              style={[styles.emptyBtn, { backgroundColor: isDark ? "#1E2A30" : "#F5FAFE", borderWidth: 1, borderColor: colors.tint }]}
            >
              <ThemedText style={{ color: "#fff" }}>
                Create First Order
              </ThemedText>
            </TouchableOpacity>
          </View>
        ) : (
          statusBreakdown.map((s, i) => {
            const maxCount = Math.max(
              ...statusBreakdown.map((b) => b.count),
              1,
            );
            const pct = (s.count / maxCount) * 100;
            return (
              <ThemedView key={i} style={styles.statusRow}>
                <View style={{ flex: 1 }}>
                  <ThemedText style={styles.statusLabel}>{s._id}</ThemedText>
                  <View
                    style={[
                      styles.barBg,
                      { backgroundColor: isDark ? "#2E3B42" : "#C5D8E6" },
                    ]}
                  >
                    <View
                      style={[
                        styles.barFill,
                        { width: `${pct}%`, backgroundColor: colors.tint },
                      ]}
                    />
                  </View>
                </View>
                <ThemedText
                  style={[styles.statusCount, { color: colors.tint }]}
                >
                  {s.count} · ₦{s.totalRevenue.toLocaleString()}
                </ThemedText>
              </ThemedView>
            );
          })
        )}
      </ThemedView>

      <View style={styles.quickActions}>
        <TouchableOpacity
  style={[
    styles.actionCard,
    {
      backgroundColor: isDark ? "#1E2A30" : "#F5FAFE",
    },
  ]}
  onPress={() => router.push("/orders/create")}
>
  <ThemedText style={styles.actionText}>New Order</ThemedText>
</TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.actionCard,
            {
              backgroundColor: isDark ? "#1E2A30" : "#F5FAFE",
            },
          ]}
          onPress={() => router.push("/customers")}
        >
          <ThemedText style={styles.actionText}>Customers</ThemedText>
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.actionCard,
            {
              backgroundColor: isDark ? "#1E2A30" : "#F5FAFE",
            },
          ]}
          onPress={() => router.push("/analytics")}
        >
          <ThemedText style={styles.actionText}>Analytics</ThemedText>
        </TouchableOpacity>
      </View>

      <ThemedView
        style={[
          styles.section,
          {
            backgroundColor: isDark ? "#1E2A30" : "#F5FAFE",
          },
        ]}
      >
        <ThemedText style={styles.sectionTitle}>Recent Orders</ThemedText>

        {recentOrders.length === 0 ? (
          <ThemedText style={styles.emptyText}>
            No recent orders found.
          </ThemedText>
        ) : (
          recentOrders.map((order) => (
            <View key={order._id} style={styles.orderRow}>
              <View>
                <ThemedText style={styles.orderCustomer}>
                  {order.customerName}
                </ThemedText>

                <ThemedText style={styles.orderProduct}>
                  {order.productName}
                </ThemedText>
              </View>

              <ThemedText
                style={{
                  color: colors.tint,
                  fontWeight: "600",
                }}
              >
                {order.status}
              </ThemedText>
            </View>
          ))
        )}
      </ThemedView>

      {/* Footer hint */}
      <TouchableOpacity style={styles.footerLink}>
        <Link href="/explore">
          <ThemedText type="link">View all analytics →</ThemedText>
        </Link>
      </TouchableOpacity>

      <ThemedText
        style={{
          textAlign: "center",
          fontSize: 11,
          opacity: 0.3,
          marginBottom: 8,
        }}
      >
        Data is live from your server
      </ThemedText>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    paddingVertical: 18,
    paddingHorizontal: 16,
    gap: 18,
  },

  sectionTitle: {
    fontSize: 15,
  },

  healthCard: {
    padding: 12,
    borderRadius: 12,
    marginBottom: 8,
  },

  emptyState: {
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 24,
  },

  emptyTitle: {
    fontSize: 16,
    fontWeight: "600",
    marginBottom: 8,
  },

  emptyDescription: {
    fontSize: 13,
    opacity: 0.6,
    textAlign: "center",
    lineHeight: 20,
    marginBottom: 12,
  },

  emptyText: {
    fontSize: 13,
    opacity: 0.4,
  },

  orderRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: "#E5E7EB",
  },

  orderCustomer: {
    fontWeight: "600",
    fontSize: 14,
  },

  orderProduct: {
    fontSize: 12,
    opacity: 0.6,
  },

  quickActions: {
    flexDirection: "row",
    justifyContent: "space-between",
  },

  actionCard: {
    flex: 1,
    marginHorizontal: 4,
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: "center",
    backgroundColor: "#F5FAFE",
  },

  actionIcon: {
    fontSize: 22,
    marginBottom: 6,
  },

  actionText: {
    fontSize: 13,
    fontWeight: "600",
  },
  center: {
    justifyContent: "center",
    alignItems: "center",
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  logoutBtn: {
    backgroundColor: "#E74C3C",
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 8,
  },
  logoutBtnText: {
    color: "#fff",
    fontWeight: "600",
    fontSize: 13,
  },
  statsGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  statCard: {
    width: "48%",
    padding: 16,
    borderRadius: 14,
    borderLeftWidth: 3,
  },
  statValue: {
    fontSize: 22,
    fontWeight: "bold",
    marginBottom: 2,
  },
  statLabel: {
    fontSize: 12,
  },
  section: {
    padding: 16,
    borderRadius: 14,
    gap: 12,
  },

  statusRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  statusLabel: {
    fontSize: 12,
    marginBottom: 4,
    fontWeight: "500",
  },
  barBg: {
    height: 6,
    borderRadius: 3,
    overflow: "hidden",
  },
  barFill: {
    height: "100%",
    borderRadius: 3,
  },
  statusCount: {
    fontSize: 12,
    fontWeight: "600",
    minWidth: 120,
    textAlign: "right",
  },
  footerLink: {
    alignSelf: "center",
    marginTop: 6,
  },
  emptyBtn: {
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 12,
    marginTop: 16,
  },
});
