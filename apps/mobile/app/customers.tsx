import { useCallback, useEffect, useState } from "react";
import {
  StyleSheet,
  View,
  TouchableOpacity,
  Alert,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  TextInput,
  ActivityIndicator,
} from "react-native";
import { useRouter } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";

import { User, Phone, Mail, MapPin, ClipboardList, Plus, Search, Wallet } from "lucide-react-native";

import { ThemedText } from "@/components/themed-text";
import { ThemedView } from "@/components/themed-view";
import { useColorScheme } from "@/hooks/use-color-scheme";
import { Colors, Fonts } from "@/constants/theme";
import { useAuth } from "@/contexts/AuthContext";
import { customersApi, CustomerSummary } from "@/services/api";

export default function CustomersScreen() {
  const colorScheme: "light" | "dark" =
    useColorScheme() === "dark" ? "dark" : "light";
  const colors = Colors[colorScheme];
  const isDark = colorScheme === "dark";
  const { token } = useAuth();
  const router = useRouter();

  const [customers, setCustomers] = useState<CustomerSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [showAddForm, setShowAddForm] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [address, setAddress] = useState("");
  const [notes, setNotes] = useState("");

  const loadCustomers = useCallback(async () => {
    if (!token) return;
    try {
      setLoading(true);
      setError(null);
      const data = await customersApi.getSummary(token);
      setCustomers(data ?? []);
    } catch (e: any) {
      setError(e.message ?? "Failed to load customers");
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    void loadCustomers();
  }, [loadCustomers]);

  const handleCreate = async () => {
    if (!name.trim() || !phone.trim()) {
      Alert.alert("Missing fields", "Name and phone are required.");
      return;
    }

    setSubmitting(true);
    try {
      await customersApi.create(token!, {
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim() || undefined,
        address: address.trim() || undefined,
        notes: notes.trim() || undefined,
      });

      setName("");
      setPhone("");
      setEmail("");
      setAddress("");
      setNotes("");
      setShowAddForm(false);
      await loadCustomers();
    } catch (e: any) {
      Alert.alert(
        "Failed to create customer",
        e?.message ?? "Something went wrong.",
      );
    } finally {
      setSubmitting(false);
    }
  };

  const filtered = customers.filter((c) => {
    const q = search.trim().toLowerCase();
    if (!q) return true;
    return (
      c.customerName.toLowerCase().includes(q) ||
      c.phone.toLowerCase().includes(q)
    );
  });

  const renderEmpty = () => (
    <View style={styles.emptyState}>
      <ThemedText style={styles.emptyTitle}>No customers yet</ThemedText>
      <ThemedText style={styles.emptyDescription}>
        Add your first customer to start tracking orders and balances per buyer.
      </ThemedText>
      <TouchableOpacity
        onPress={() => setShowAddForm(true)}
        style={[
          styles.emptyBtn,
          {
            backgroundColor: isDark ? "#1E2A30" : "#F5FAFE",
            borderWidth: 1,
            borderColor: colors.tint,
          },
        ]}
      >
        <ThemedText style={{ color: colors.tint }}>Add First Customer</ThemedText>
      </TouchableOpacity>
    </View>
  );

  const renderAddForm = () => (
    <KeyboardAvoidingView
      style={{ width: "100%" }}
      behavior={Platform.OS === "ios" ? "padding" : "height"}
    >
      <ScrollView
        contentContainerStyle={[
          styles.formCard,
          { backgroundColor: isDark ? "#11181C" : "#fff" },
        ]}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <ThemedText type="default" style={styles.formTitle}>
          New Customer
        </ThemedText>

        {/* Name */}
        <ThemedText style={styles.label}>Name</ThemedText>
        <View
          style={[
            styles.inputContainer,
            { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
          ]}
        >
          <User size={18} color={isDark ? "#94A3B8" : "#64748B"} />
          <TextInput
            style={[styles.input, { color: colors.text }]}
            placeholder="Jane Doe"
            placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
            value={name}
            onChangeText={setName}
          />
        </View>

        {/* Phone */}
        <ThemedText style={styles.label}>Phone</ThemedText>
        <View
          style={[
            styles.inputContainer,
            { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
          ]}
        >
          <Phone size={18} color={isDark ? "#94A3B8" : "#64748B"} />
          <TextInput
            style={[styles.input, { color: colors.text }]}
            placeholder="+237 6XX XXX XXX"
            placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
            keyboardType="phone-pad"
            value={phone}
            onChangeText={setPhone}
          />
        </View>

        {/* Email */}
        <ThemedText style={styles.label}>Email (optional)</ThemedText>
        <View
          style={[
            styles.inputContainer,
            { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
          ]}
        >
          <Mail size={18} color={isDark ? "#94A3B8" : "#64748B"} />
          <TextInput
            style={[styles.input, { color: colors.text }]}
            placeholder="you@example.com"
            placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
            autoCapitalize="none"
            keyboardType="email-address"
            value={email}
            onChangeText={setEmail}
          />
        </View>

        {/* Address */}
        <ThemedText style={styles.label}>Address (optional)</ThemedText>
        <View
          style={[
            styles.inputContainer,
            { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
          ]}
        >
          <MapPin size={18} color={isDark ? "#94A3B8" : "#64748B"} />
          <TextInput
            style={[styles.input, { color: colors.text }]}
            placeholder="Douala, Bonaberi"
            placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
            value={address}
            onChangeText={setAddress}
          />
        </View>

        {/* Notes */}
        <ThemedText style={styles.label}>Notes (optional)</ThemedText>
        <View
          style={[
            styles.inputContainer,
            { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
          ]}
        >
          <ClipboardList size={18} color={isDark ? "#94A3B8" : "#64748B"} />
          <TextInput
            style={[styles.input, { color: colors.text }]}
            placeholder="Preferred sizes, payment habits..."
            placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
            value={notes}
            onChangeText={setNotes}
          />
        </View>

        {/* Actions */}
        <View style={styles.formActions}>
          <TouchableOpacity
            onPress={() => setShowAddForm(false)}
            style={[
              styles.secondaryButton,
              { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
            ]}
          >
            <ThemedText style={{ color: colors.text }}>Cancel</ThemedText>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={handleCreate}
            disabled={submitting}
            style={styles.primaryButton}
          >
            <LinearGradient
              colors={["#0A7EA4", "#13B5EA"]}
              style={styles.primaryButtonInner}
            >
              {submitting ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <ThemedText style={styles.primaryButtonText}>
                  Save Customer
                </ThemedText>
              )}
            </LinearGradient>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );

  return (
    <ScrollView
      contentContainerStyle={[
        styles.container,
        { backgroundColor: colors.background },
      ]}
      keyboardShouldPersistTaps="handled"
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <ThemedView style={styles.header}>
        <View>
          <ThemedText style={styles.headerTitle}>Customers</ThemedText>
          <ThemedText style={{ opacity: 0.6, fontSize: 13 }}>
            Buyers, balances and repeat orders
          </ThemedText>
        </View>
        <TouchableOpacity
          onPress={() => setShowAddForm((v) => !v)}
          style={[styles.fab, { backgroundColor: colors.tint }]}
        >
          <Plus size={20} color="#fff" />
        </TouchableOpacity>
      </ThemedView>

      {/* Search */}
      <View
        style={[
          styles.searchContainer,
          { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
        ]}
      >
        <Search size={18} color={isDark ? "#94A3B8" : "#64748B"} />
        <TextInput
          style={[styles.searchInput, { color: colors.text }]}
          placeholder="Search by name or phone"
          placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
          value={search}
          onChangeText={setSearch}
        />
      </View>

      {showAddForm && renderAddForm()}

      {loading ? (
        <View style={styles.center}>
          <ActivityIndicator size="large" color={colors.tint} />
        </View>
      ) : error ? (
        <View style={styles.center}>
          <ThemedText style={{ color: "#E74C3C", marginBottom: 12 }}>
            {error}
          </ThemedText>
          <TouchableOpacity
            onPress={() => loadCustomers()}
            style={[styles.retryBtn, { backgroundColor: colors.tint }]}
          >
            <ThemedText style={{ color: "#fff", fontWeight: "600" }}>
              Retry
            </ThemedText>
          </TouchableOpacity>
        </View>
      ) : filtered.length === 0 ? (
        renderEmpty()
      ) : (
        <View style={styles.list}>
          {filtered.map((customer) => (
            <View
              key={customer._id}
              style={[
                styles.card,
                { backgroundColor: isDark ? "#1E2A30" : "#F5FAFE" },
              ]}
            >
              <View style={styles.cardHeader}>
                <View>
                  <ThemedText style={styles.customerName}>
                    {customer.customerName}
                  </ThemedText>
                  {customer.phone ? (
                    <View style={styles.metaRow}>
                      <Phone size={14} color={isDark ? "#94A3B8" : "#64748B"} />
                      <ThemedText style={styles.metaText}>
                        {customer.phone}
                      </ThemedText>
                    </View>
                  ) : null}
                </View>
              </View>

              <View style={styles.statsRow}>
                <View style={styles.statPill}>
                  <ClipboardList
                    size={14}
                    color={isDark ? "#94A3B8" : "#64748B"}
                  />
                  <ThemedText style={styles.statPillText}>
                    {customer.totalOrders} orders
                  </ThemedText>
                </View>
                <View style={styles.statPill}>
                  <ThemedText
                    style={[
                      styles.statPillText,
                      { color: "#27AE60", fontWeight: "600" },
                    ]}
                  >
                    FCFA {customer.totalSpent.toLocaleString()}
                  </ThemedText>
                </View>
                {customer.totalOutstandingBalance ? (
                  <View style={styles.statPill}>
                    <Wallet
                      size={14}
                      color={isDark ? "#94A3B8" : "#64748B"}
                    />
                    <ThemedText
                      style={[
                        styles.statPillText,
                        { color: "#E74C3C", fontWeight: "600" },
                      ]}
                    >
                      Due FCFA{" "}
                      {customer.totalOutstandingBalance.toLocaleString()}
                    </ThemedText>
                  </View>
                ) : null}
              </View>
            </View>
          ))}
        </View>
      )}

      <ThemedText
        style={{
          textAlign: "center",
          fontSize: 11,
          opacity: 0.35,
          marginTop: 10,
          marginBottom: 8,
        }}
      >
        Customers are synced from your orders
      </ThemedText>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    paddingVertical: 18,
    paddingHorizontal: 16,
    gap: 16,
    
  },
  center: {
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 40,
    gap: 12,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: "700",
  },
  fab: {
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
  },
  searchContainer: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    paddingHorizontal: 14,
    height: 52,
    borderWidth: 1.2,
    borderRadius: 16,
  },
  searchInput: {
    flex: 1,
    fontSize: 15,
    fontFamily: Fonts.sans,
  },
  list: {
    gap: 10,
  },
  card: {
    padding: 16,
    borderRadius: 16,
    gap: 10,
  },
  cardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
  },
  customerName: {
    fontSize: 16,
    fontWeight: "700",
  },
  metaRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginTop: 4,
  },
  metaText: {
    fontSize: 13,
    opacity: 0.7,
  },
  statsRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  statPill: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: "rgba(255,255,255,0.08)",
  },
  statPillText: {
    fontSize: 12,
    fontWeight: "600",
  },
  emptyState: {
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 40,
    gap: 12,
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: "600",
    marginBottom: 4,
  },
  emptyDescription: {
    fontSize: 13,
    opacity: 0.6,
    textAlign: "center",
    lineHeight: 20,
    marginHorizontal: 24,
    marginBottom: 12,
  },
  emptyBtn: {
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 12,
  },
  formCard: {
    padding: 20,
    borderRadius: 20,
    gap: 4,
    marginBottom: 12,
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 20,
    elevation: 6,
  },
  formTitle: {
    fontSize: 18,
    fontWeight: "700",
    marginBottom: 8,
  },
  label: {
    marginTop: 12,
    marginBottom: 6,
    fontSize: 14,
    fontWeight: "700",
    opacity: 0.75,
  },
  inputContainer: {
    height: 54,
    borderWidth: 1.2,
    borderRadius: 14,
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 14,
    gap: 10,
  },
  input: {
    flex: 1,
    fontSize: 15,
    fontFamily: Fonts.sans,
  },
  formActions: {
    flexDirection: "row",
    justifyContent: "flex-end",
    gap: 10,
    marginTop: 14,
  },
  secondaryButton: {
    paddingHorizontal: 18,
    paddingVertical: 12,
    borderRadius: 14,
    borderWidth: 1.2,
    alignItems: "center",
    justifyContent: "center",
  },
  primaryButton: {
    borderRadius: 18,
    overflow: "hidden",
  },
  primaryButtonInner: {
    height: 48,
    paddingHorizontal: 18,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
  },
  primaryButtonText: {
    color: "#fff",
    fontSize: 15,
    fontWeight: "800",
  },
  retryBtn: {
    paddingHorizontal: 18,
    paddingVertical: 10,
    borderRadius: 12,
  },
});
