'use client'

import { useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useAuth } from '../../lib/auth-context'

export default function AuthCallbackPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const { login } = useAuth()

  useEffect(() => {
    const token = searchParams.get('token')
    const email = searchParams.get('email')
    const name = searchParams.get('name')

    if (token && email) {
      // Create user object from URL parameters
      const user = {
        id: '',
        email: email,
        name: name || 'Google User'
      }

      // Use the auth context's login function
      login(token, user)

      // Redirect to dashboard
      router.push('/dashboard')
    } else {
      router.push('/auth/login')
    }
  }, [searchParams, router, login])

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <div className="w-16 h-16 border-4 border-green-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
        <p className="text-[var(--color-foreground)]">Authenticating...</p>
        <p className="text-sm text-[var(--color-text-dim)] mt-2">Please wait while we verify your account</p>
      </div>
    </div>
  )
}