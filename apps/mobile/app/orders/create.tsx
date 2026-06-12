import { useState } from "react";
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

import {
  User,
  Phone,
  ShoppingBag,
  Ruler,
  Palette,
  CircleDollarSign,
  Tag,
  Wallet,
  ClipboardList,
  ChevronDown,
} from "lucide-react-native";

import { ThemedText } from "@/components/themed-text";
import { useColorScheme } from "@/hooks/use-color-scheme";
import { Colors, Fonts } from "@/constants/theme";
import { useAuth } from "@/contexts/AuthContext";
import { ordersApi, OrderStatus } from "@/services/api";

const STATUS_OPTIONS: OrderStatus[] = [
  "Waiting for Supplier",
  "Supplier Shipped",
  "Received",
  "Sent to Customer",
  "Delivered",
];

export default function CreateOrderScreen() {
  const colorScheme: "light" | "dark" =
    useColorScheme() === "dark" ? "dark" : "light";
  const colors = Colors[colorScheme];
  const isDark = colorScheme === "dark";
  const router = useRouter();
  const { token } = useAuth();

  const [customerName, setCustomerName] = useState("");
  const [phone, setPhone] = useState("");
  const [productName, setProductName] = useState("");
  const [size, setSize] = useState("");
  const [color, setColor] = useState("");
  const [costPrice, setCostPrice] = useState("");
  const [sellingPrice, setSellingPrice] = useState("");
  const [advancePaid, setAdvancePaid] = useState("0");
  const [status, setStatus] = useState<OrderStatus>("Waiting for Supplier");
  const [showStatusPicker, setShowStatusPicker] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleCreateOrder = async () => {
    if (!customerName.trim() || !phone.trim() || !productName.trim()) {
      Alert.alert("Missing fields", "Customer name, phone, and product are required.");
      return;
    }
    if (!costPrice.trim() || !sellingPrice.trim()) {
      Alert.alert("Missing price", "Please enter cost price and selling price.");
      return;
    }
    const cost = parseFloat(costPrice);
    const selling = parseFloat(sellingPrice);
    const advance = parseFloat(advancePaid) || 0;
    if (isNaN(cost) || isNaN(selling)) {
      Alert.alert("Invalid price", "Please enter valid numeric values for prices.");
      return;
    }
    if (selling < cost) {
      Alert.alert(
        "Low selling price",
        "Selling price is lower than cost price. This order will show a loss.",
      );
    }

    setLoading(true);
    try {
      const body = {
        customerName: customerName.trim(),
        phone: phone.trim(),
        productName: productName.trim(),
        size: size.trim() || undefined,
        color: color.trim() || undefined,
        costPrice: cost,
        sellingPrice: selling,
        advancePaid: advance,
        status,
      };
      await ordersApi.create(token!, body);
      router.back();
    } catch (error: any) {
      Alert.alert(
        "Failed to create order",
        error?.message ?? "Something went wrong.",
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === "ios" ? "padding" : "height"}
    >
      <ScrollView
        contentContainerStyle={[
          styles.container,
          { backgroundColor: colors.background },
        ]}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        {/* HERO */}
        <LinearGradient
          colors={isDark ? ["#081C24", "#0A7EA4"] : ["#0A7EA4", "#13B5EA"]}
          style={styles.hero}
        >
          <View style={styles.logoCircle}>
            <ClipboardList size={28} color="#fff" />
          </View>

          <ThemedText style={styles.brand}>New Order</ThemedText>
          <ThemedText style={styles.heroSubtitle}>
            Capture order details, pricing, and delivery status.
          </ThemedText>
        </LinearGradient>

        {/* FORM */}
        <View
          style={[
            styles.card,
            { backgroundColor: isDark ? "#11181C" : "#fff" },
          ]}
        >
          {/* Customer Name */}
          <ThemedText style={styles.label}>Customer Name</ThemedText>
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
              value={customerName}
              onChangeText={setCustomerName}
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

          {/* Product Name */}
          <ThemedText style={styles.label}>Product Name</ThemedText>
          <View
            style={[
              styles.inputContainer,
              { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
            ]}
          >
            <ShoppingBag size={18} color={isDark ? "#94A3B8" : "#64748B"} />
            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="e.g. Air Jordan 1 High"
              placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
              value={productName}
              onChangeText={setProductName}
            />
          </View>

          {/* Size & Color row */}
          <View style={styles.row}>
            <View style={{ flex: 1, marginRight: 8 }}>
              <ThemedText style={styles.label}>Size (optional)</ThemedText>
              <View
                style={[
                  styles.inputContainer,
                  { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
                ]}
              >
                <Ruler size={18} color={isDark ? "#94A3B8" : "#64748B"} />
                <TextInput
                  style={[styles.input, { color: colors.text }]}
                  placeholder="42"
                  placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
                  value={size}
                  onChangeText={setSize}
                />
              </View>
            </View>

            <View style={{ flex: 1, marginLeft: 8 }}>
              <ThemedText style={styles.label}>Color (optional)</ThemedText>
              <View
                style={[
                  styles.inputContainer,
                  { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
                ]}
              >
                <Palette size={18} color={isDark ? "#94A3B8" : "#64748B"} />
                <TextInput
                  style={[styles.input, { color: colors.text }]}
                  placeholder="Red"
                  placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
                  value={color}
                  onChangeText={setColor}
                />
              </View>
            </View>
          </View>

          {/* Cost Price & Selling Price */}
          <View style={styles.row}>
            <View style={{ flex: 1, marginRight: 8 }}>
              <ThemedText style={styles.label}>Cost Price (FCFA)</ThemedText>
              <View
                style={[
                  styles.inputContainer,
                  { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
                ]}
              >
                <CircleDollarSign size={18} color={isDark ? "#94A3B8" : "#64748B"} />
                <TextInput
                  style={[styles.input, { color: colors.text }]}
                  placeholder="0"
                  placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
                  keyboardType="numeric"
                  value={costPrice}
                  onChangeText={setCostPrice}
                />
              </View>
            </View>

            <View style={{ flex: 1, marginLeft: 8 }}>
              <ThemedText style={styles.label}>Selling Price (FCFA)</ThemedText>
              <View
                style={[
                  styles.inputContainer,
                  { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
                ]}
              >
                <Tag size={18} color={isDark ? "#94A3B8" : "#64748B"} />
                <TextInput
                  style={[styles.input, { color: colors.text }]}
                  placeholder="0"
                  placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
                  keyboardType="numeric"
                  value={sellingPrice}
                  onChangeText={setSellingPrice}
                />
              </View>
            </View>
          </View>

          {/* Advance Paid */}
          <ThemedText style={styles.label}>Advance Paid (FCFA)</ThemedText>
          <View
            style={[
              styles.inputContainer,
              { borderColor: isDark ? "#2C343A" : "#DDE3EA" },
            ]}
          >
            <Wallet size={18} color={isDark ? "#94A3B8" : "#64748B"} />
            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="0"
              placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
              keyboardType="numeric"
              value={advancePaid}
              onChangeText={setAdvancePaid}
            />
          </View>

          {/* Status Picker */}
          <ThemedText style={styles.label}>Status</ThemedText>
          <TouchableOpacity
            activeOpacity={0.8}
            onPress={() => setShowStatusPicker((prev) => !prev)}
            style={[
              styles.inputContainer,
              { borderColor: isDark ? "#2C343A" : "#DDE3EA", justifyContent: "space-between" },
            ]}
          >
            <View style={{ flexDirection: "row", alignItems: "center", gap: 10 }}>
              <ClipboardList size={18} color={isDark ? "#94A3B8" : "#64748B"} />
              <ThemedText style={{ color: colors.text, fontSize: 15 }}>
                {status}
              </ThemedText>
            </View>
            <ChevronDown
              size={18}
              color={isDark ? "#94A3B8" : "#64748B"}
              style={{ transform: [{ rotate: showStatusPicker ? "180deg" : "0deg" }] }}
            />
          </TouchableOpacity>

          {showStatusPicker && (
            <View
              style={[
                styles.pickerList,
                { backgroundColor: isDark ? "#1A2329" : "#F8FAFC", borderColor: isDark ? "#2C343A" : "#DDE3EA" },
              ]}
            >
              {STATUS_OPTIONS.map((opt) => (
                <TouchableOpacity
                  key={opt}
                  activeOpacity={0.7}
                  onPress={() => {
                    setStatus(opt);
                    setShowStatusPicker(false);
                  }}
                  style={[
                    styles.pickerItem,
                    { borderBottomColor: isDark ? "#2C343A" : "#E2E8F0" },
                  ]}
                >
                  <ThemedText
                    style={{
                      color: status === opt ? colors.tint : colors.text,
                      fontWeight: status === opt ? "700" : "400",
                    }}
                  >
                    {opt}
                  </ThemedText>
                </TouchableOpacity>
              ))}
            </View>
          )}

          {/* Submit */}
          <TouchableOpacity
            activeOpacity={0.9}
            onPress={handleCreateOrder}
            disabled={loading}
            style={{ marginTop: 24 }}
          >
            <LinearGradient
              colors={["#0A7EA4", "#13B5EA"]}
              style={styles.button}
            >
              {loading ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <ThemedText style={styles.buttonText}>Create Order</ThemedText>
              )}
            </LinearGradient>
          </TouchableOpacity>
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
    paddingBottom: 40,
    paddingHorizontal: 28,
    alignItems: "center",
    borderBottomLeftRadius: 40,
    borderBottomRightRadius: 40,
    overflow: "hidden",
  },
  logoCircle: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: "rgba(255,255,255,0.15)",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 16,
  },
  brand: {
    color: "#fff",
    fontSize: 30,
    fontFamily: Fonts.rounded,
    fontWeight: "800",
    marginBottom: 10,
  },
  heroSubtitle: {
    color: "rgba(255,255,255,0.85)",
    textAlign: "center",
    marginTop: 8,
    fontSize: 15,
    lineHeight: 24,
    maxWidth: 340,
  },
  card: {
    marginHorizontal: 22,
    marginTop: -40,
    borderRadius: 28,
    padding: 24,
    gap: 4,
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 20,
    elevation: 6,
  },
  label: {
    marginTop: 14,
    marginBottom: 6,
    fontSize: 14,
    fontWeight: "700",
    opacity: 0.75,
  },
  row: {
    flexDirection: "row",
    alignItems: "flex-start",
  },
  inputContainer: {
    height: 56,
    borderWidth: 1.2,
    borderRadius: 16,
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
  pickerList: {
    marginTop: 6,
    borderRadius: 14,
    borderWidth: 1,
    overflow: "hidden",
  },
  pickerItem: {
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
  },
  button: {
    height: 56,
    borderRadius: 18,
    justifyContent: "center",
    alignItems: "center",
    marginTop: 10,
  },
  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "800",
  },
});
