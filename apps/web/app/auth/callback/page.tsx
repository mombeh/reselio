'use client'

import { useEffect, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '../../lib/auth-context'

function AuthCallbackContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const { login } = useAuth()

  useEffect(() => {
    const token = searchParams.get('token')

    if (!token) {
      console.error('No token in URL params')
      router.push('/auth/login')
      return
    }

    // Prevent multiple executions
    if ((router as any).callbackHandled) return;
    (router as any).callbackHandled = true;

    const fetchUser = async () => {
      try {
        const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';
        console.log('Callback: Fetching user from', `${apiUrl}/auth/me`);
        console.log('Callback: Token present:', !!token);
        
        const res = await fetch(`${apiUrl}/auth/me`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        console.log('Callback: Response status:', res.status);

        if (!res.ok) {
          console.error('Failed to fetch user:', res.status, res.statusText)
          const errorText = await res.text();
          console.error('Error response:', errorText);
          router.push('/auth/login')
          return
        }

        const user = await res.json()
        console.log('User fetched successfully:', user)

        // Handle different response formats
        const userId = user.userId || user.id || user.sub || user._id;
        const userEmail = user.email;
        const userName = user.name || user.displayName || 'User';

        if (!userId || !userEmail) {
          console.error('Invalid user data:', user);
          router.push('/auth/login')
          return
        }

        const formattedUser = {
          id: userId,
          email: userEmail,
          name: userName,
        }

        console.log('Calling login with:', { token: token ? 'present' : 'missing', user: formattedUser });
        
        // Store token and user in localStorage directly as backup
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(formattedUser));
        
        // Also call the login function
        login(token, formattedUser)

        console.log('Redirecting to dashboard');
        router.push('/dashboard')
      } catch (error) {
        console.error('Error in callback:', error)
        router.push('/auth/login')
      }
    }

    fetchUser()
  }, [searchParams, router, login])

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <div className="w-16 h-16 border-4 border-green-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
        <p>Authenticating...</p>
      </div>
    </div>
  )
}

export default function AuthCallbackPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-green-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p>Loading...</p>
        </div>
      </div>
    }>
      <AuthCallbackContent />
    </Suspense>
  )
}
