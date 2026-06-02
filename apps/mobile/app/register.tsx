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

import { Link, useRouter } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";

import {
  User,
  Mail,
  Lock,
  Eye,
  EyeOff,
  ShoppingBag,
  Sparkles,
  CheckCircle2,
} from "lucide-react-native";

import { ThemedText } from "@/components/themed-text";
import { useColorScheme } from "@/hooks/use-color-scheme";
import { Colors, Fonts } from "@/constants/theme";
import { authApi } from "@/services/api";
import { useAuth } from "@/contexts/AuthContext";

export default function RegisterScreen() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");

  const colorScheme: "light" | "dark" =
    useColorScheme() === "dark" ? "dark" : "light";

  const colors = Colors[colorScheme];
  const isDark = colorScheme === "dark";

  const router = useRouter();
  const { login: setToken } = useAuth();

  const handleRegister = async () => {
    if (!name.trim() || !email.trim() || !password.trim()) {
      Alert.alert("Missing fields", "Please fill in all fields.");
      return;
    }

    setLoading(true);

    try {
      console.log("Sending registration request...");

      const res = await authApi.register({
        name: name.trim(),
        email: email.trim(),
        password,
      });

      setSuccessMessage(
        "Account created successfully! Redirecting to login...",
      );

      setTimeout(() => {
        router.replace({
          pathname: "/login",
          params: {
            email: email.trim(),
          },
        });
      }, 2000);
    } catch (error: any) {
      console.error("REGISTER ERROR:", error);

      Alert.alert(
        "Registration failed",
        error?.message || JSON.stringify(error),
      );
    } finally {
      console.log("Finished request");
      setLoading(false);
    }
  };

  // const handleRegister = async () => {
  //   if (!name.trim() || !email.trim() || !password.trim()) {
  //     Alert.alert('Missing fields', 'Please fill in all fields.');
  //     return;
  //   }

  //   if (password.length < 8) {
  //     Alert.alert(
  //       'Weak password',
  //       'Password must contain at least 8 characters.',
  //     );
  //     return;
  //   }

  //   setLoading(true);

  //   try {
  //     const res = await authApi.register({
  //       name: name.trim(),
  //       email: email.trim(),
  //       password,
  //     });

  //     await setToken(res.access_token);

  //     router.replace('/(tabs)');
  //   } catch (error: any) {
  //     Alert.alert(
  //       'Registration failed',
  //       error.message ?? 'Something went wrong.',
  //     );
  //   } finally {
  //     setLoading(false);
  //   }
  // };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === "ios" ? "padding" : "height"}
    >
      <ScrollView
        contentContainerStyle={[
          styles.container,
          {
            backgroundColor: colors.background,
          },
        ]}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        {/* HERO */}
        <LinearGradient
          colors={isDark ? ["#081C24", "#0A7EA4"] : ["#0A7EA4", "#13B5EA"]}
          style={styles.hero}
        >
          {/* FLOATING SHAPES */}
          <View style={styles.circleOne} />
          <View style={styles.circleTwo} />

          {/* LOGO */}
          <View style={styles.logoContainer}>
            <ShoppingBag size={28} color="#fff" />
          </View>

          <ThemedText style={styles.brand}>Reselio</ThemedText>

          <View style={styles.badge}>
            <Sparkles size={14} color="#fff" />
            <ThemedText style={styles.badgeText}>
              Built for modern resellers
            </ThemedText>
          </View>

          <ThemedText style={styles.heroTitle}>
            Start growing your business
          </ThemedText>

          <ThemedText style={styles.heroSubtitle}>
            Track orders, manage customers, monitor profits and organize your
            WhatsApp business effortlessly.
          </ThemedText>
        </LinearGradient>

        {/* CARD */}
        <View
          style={[
            styles.card,
            {
              backgroundColor: isDark ? "#11181C" : "#fff",
            },
          ]}
        >
          {/* FEATURES */}
          <View style={styles.featureRow}>
            <CheckCircle2 size={16} color="#13B5EA" />
            <ThemedText style={styles.featureText}>
              Track orders professionally
            </ThemedText>
          </View>

          <View style={styles.featureRow}>
            <CheckCircle2 size={16} color="#13B5EA" />
            <ThemedText style={styles.featureText}>
              Monitor profits instantly
            </ThemedText>
          </View>

          <View style={styles.featureRow}>
            <CheckCircle2 size={16} color="#13B5EA" />
            <ThemedText style={styles.featureText}>
              Manage repeat customers easily
            </ThemedText>
          </View>

          {/* NAME */}
          <ThemedText style={styles.label}>Full Name</ThemedText>

          <View
            style={[
              styles.inputContainer,
              {
                borderColor: isDark ? "#2C343A" : "#DDE3EA",
              },
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

          {/* EMAIL */}
          <ThemedText style={styles.label}>Email Address</ThemedText>

          <View
            style={[
              styles.inputContainer,
              {
                borderColor: isDark ? "#2C343A" : "#DDE3EA",
              },
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

          {/* PASSWORD */}
          <ThemedText style={styles.label}>Password</ThemedText>

          <View
            style={[
              styles.inputContainer,
              {
                borderColor: isDark ? "#2C343A" : "#DDE3EA",
              },
            ]}
          >
            <Lock size={18} color={isDark ? "#94A3B8" : "#64748B"} />

            <TextInput
              style={[styles.input, { color: colors.text }]}
              placeholder="Minimum 8 characters"
              placeholderTextColor={isDark ? "#687076" : "#94A3B8"}
              secureTextEntry={!showPassword}
              value={password}
              onChangeText={setPassword}
            />

            <TouchableOpacity
              activeOpacity={0.7}
              onPress={() => setShowPassword(!showPassword)}
            >
              {showPassword ? (
                <EyeOff size={20} color="#94A3B8" />
              ) : (
                <Eye size={20} color="#94A3B8" />
              )}
            </TouchableOpacity>
          </View>

          {/* PASSWORD HINT */}
          <ThemedText style={styles.passwordHint}>
            Use at least 8 characters for better security.
          </ThemedText>

          {/* BUTTON */}
          <TouchableOpacity
            activeOpacity={0.9}
            onPress={handleRegister}
            disabled={loading}
          >
            <LinearGradient
              colors={["#0A7EA4", "#13B5EA"]}
              style={styles.button}
            >
              {successMessage ? (
                <View style={styles.successContainer}>
                  <CheckCircle2 size={18} color="#22C55E" />
                  <ThemedText style={styles.successText}>
                    {successMessage}
                  </ThemedText>
                </View>
              ) : null}
              {loading ? (
                <ActivityIndicator color="#fff" />
              ) : (
                <ThemedText style={styles.buttonText}>
                  Create Account
                </ThemedText>
              )}
            </LinearGradient>
          </TouchableOpacity>

          {/* TERMS */}
          <ThemedText style={styles.terms}>
            By creating an account, you agree to our Terms and Privacy Policy.
          </ThemedText>

          {/* FOOTER */}
          <View style={styles.footer}>
            <ThemedText style={{ opacity: 0.6 }}>
              Already have an account?
            </ThemedText>

            <Link href="/login">
              <ThemedText
                style={{
                  color: colors.tint,
                  fontWeight: "700",
                }}
              >
                {" "}
                Sign In
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
    paddingBottom: 130,
    paddingHorizontal: 28,
    alignItems: "center",
    borderBottomLeftRadius: 40,
    borderBottomRightRadius: 40,
    overflow: "hidden",
  },

  successContainer: {
  flexDirection: 'row',
  alignItems: 'center',
  gap: 8,
  backgroundColor: 'rgba(34,197,94,0.08)',
  borderWidth: 1,
  borderColor: 'rgba(34,197,94,0.25)',
  borderRadius: 12,
  padding: 12,
  marginTop: 16,
},

successText: {
  color: '#22C55E',
  fontWeight: '600',
  flex: 1,
},

  circleOne: {
    position: "absolute",
    width: 220,
    height: 220,
    borderRadius: 999,
    backgroundColor: "rgba(255,255,255,0.06)",
    top: -40,
    right: -60,
  },

  circleTwo: {
    position: "absolute",
    width: 160,
    height: 160,
    borderRadius: 999,
    backgroundColor: "rgba(255,255,255,0.04)",
    bottom: -20,
    left: -40,
  },

  logoContainer: {
    width: 68,
    height: 68,
    borderRadius: 34,
    backgroundColor: "rgba(255,255,255,0.14)",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 18,
  },

  brand: {
    fontSize: 34,
    fontFamily: Fonts.rounded,
    fontWeight: "800",
    color: "#fff",
    marginBottom: 14,
  },

  badge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 999,
    backgroundColor: "rgba(255,255,255,0.14)",
    marginBottom: 20,
  },

  badgeText: {
    color: "#fff",
    fontSize: 12,
    fontWeight: "700",
  },

  heroTitle: {
    fontSize: 30,
    fontWeight: "800",
    color: "#fff",
    textAlign: "center",
    lineHeight: 38,
  },

  heroSubtitle: {
    marginTop: 12,
    textAlign: "center",
    color: "rgba(255,255,255,0.86)",
    fontSize: 15,
    lineHeight: 24,
    maxWidth: 320,
  },

  card: {
    marginHorizontal: 22,
    marginTop: -70,
    borderRadius: 28,
    padding: 24,
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 20,
    elevation: 6,
  },

  featureRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginBottom: 10,
  },

  featureText: {
    fontSize: 13,
    opacity: 0.75,
  },

  label: {
    marginTop: 16,
    marginBottom: 8,
    fontSize: 14,
    fontWeight: "700",
    opacity: 0.75,
  },

  inputContainer: {
    height: 58,
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

  passwordHint: {
    marginTop: 8,
    fontSize: 12,
    opacity: 0.55,
  },

  button: {
    height: 58,
    borderRadius: 18,
    justifyContent: "center",
    alignItems: "center",
    marginTop: 24,
  },

  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "800",
  },

  terms: {
    marginTop: 16,
    textAlign: "center",
    fontSize: 12,
    lineHeight: 18,
    opacity: 0.55,
  },

  footer: {
    flexDirection: "row",
    justifyContent: "center",
    marginTop: 24,
  },
});
