import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import { Providers } from "../../providers";
import Sidebar from "./components/Sidebar";
import Header from "./components/Header";

const geistSans = localFont({
  src: "../../fonts/GeistVF.woff",
  variable: "--font-geist-sans",
});
const geistMono = localFont({
  src: "../../fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
});

export const metadata: Metadata = {
  title: "Dashboard - Reselio",
  description: "Manage your orders, customers, and business insights.",
};

export default function DashboardLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${geistSans.variable} ${geistMono.variable}`} suppressHydrationWarning>
        <Providers>
          <div className="min-h-screen bg-gray-50 flex">
            <Sidebar />
            <div className="flex-1 flex flex-col">
              <Header />
              <main className="max-w-6xl mx-auto px-4 py-8 w-full">
                {children}
              </main>
            </div>
          </div>
        </Providers>
      </body>
    </html>
  );
}
