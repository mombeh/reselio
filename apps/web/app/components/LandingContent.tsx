'use client';

import { useEffect, useState } from 'react';
import { api } from '../lib/api';
import styles from './LandingContent.module.css';

interface Stats {
  users: number;
  orders: number;
  pending: number;
  completed: number;
}

export default function LandingContent() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [apiStatus, setApiStatus] = useState<'checking' | 'online' | 'offline'>('checking');

  useEffect(() => {
    async function fetchData() {
      // Check API health
      const healthResult = await api.healthCheck();
      if (healthResult.data) {
        setApiStatus('online');
      } else {
        setApiStatus('offline');
      }

      // Fetch stats
      try {
        const [usersResult, ordersResult] = await Promise.all([
          api.getUserCount(),
          api.getOrderStats(),
        ]);

        if (usersResult.data || ordersResult.data) {
          setStats({
            users: usersResult.data?.count || 0,
            orders: ordersResult.data?.total || 0,
            pending: ordersResult.data?.pending || 0,
            completed: ordersResult.data?.completed || 0,
          });
        }
      } catch (err) {
        console.error('Failed to fetch stats:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  return (
    <div className={styles.container}>
      {/* Hero Section */}
      <section className={styles.hero}>
        <div className={styles.heroContent}>
          <h1 className={styles.title}>Welcome to Reselio</h1>
          <p className={styles.subtitle}>
            A powerful platform for managing orders and users with ease
          </p>
          <div className={styles.heroCtas}>
            <a href="/auth/register" className={styles.primaryBtn}>
              Get Started
            </a>
            <a href="/auth/login" className={styles.secondaryBtn}>
              Sign In
            </a>
          </div>
        </div>
      </section>

      {/* API Status */}
      <section className={styles.statusSection}>
        <div className={styles.statusCard}>
          <div className={styles.statusIndicator}>
            <span
              className={`${styles.statusDot} ${
                apiStatus === 'online'
                  ? styles.online
                  : apiStatus === 'offline'
                  ? styles.offline
                  : styles.checking
              }`}
            />
            <span className={styles.statusText}>
              API Status: {apiStatus === 'checking' ? 'Checking...' : apiStatus}
            </span>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className={styles.statsSection}>
        <h2 className={styles.sectionTitle}>Platform Statistics</h2>
        {loading ? (
          <div className={styles.loading}>Loading statistics...</div>
        ) : error ? (
          <div className={styles.error}>{error}</div>
        ) : stats ? (
          <div className={styles.statsGrid}>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.users}</div>
              <div className={styles.statLabel}>Total Users</div>
            </div>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.orders}</div>
              <div className={styles.statLabel}>Total Orders</div>
            </div>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.pending}</div>
              <div className={styles.statLabel}>Pending Orders</div>
            </div>
            <div className={styles.statCard}>
              <div className={styles.statValue}>{stats.completed}</div>
              <div className={styles.statLabel}>Completed Orders</div>
            </div>
          </div>
        ) : (
          <div className={styles.noData}>No data available yet</div>
        )}
      </section>

      {/* Features Section */}
      <section className={styles.featuresSection}>
        <h2 className={styles.sectionTitle}>Features</h2>
        <div className={styles.featuresGrid}>
          <div className={styles.featureCard}>
            <h3>User Management</h3>
            <p>Create and manage user accounts with ease</p>
          </div>
          <div className={styles.featureCard}>
            <h3>Order Tracking</h3>
            <p>Track and manage orders in real-time</p>
          </div>
          <div className={styles.featureCard}>
            <h3>Secure Authentication</h3>
            <p>Google OAuth and JWT-based authentication</p>
          </div>
          <div className={styles.featureCard}>
            <h3>RESTful API</h3>
            <p>Modern API built with NestJS</p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className={styles.ctaSection}>
        <h2>Ready to get started?</h2>
        <p>Join thousands of users already using Reselio</p>
        <a href="/auth/register" className={styles.primaryBtn}>
          Create an Account
        </a>
      </section>
    </div>
  );
}
