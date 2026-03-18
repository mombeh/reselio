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
      router.push('/auth/login')
      return
    }

    const fetchUser = async () => {
      try {
        const res = await fetch('http://localhost:4000/auth/me', {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })

        if (!res.ok) {
          console.error('Failed to fetch user:', res.status, res.statusText)
          router.push('/auth/login')
          return
        }

        const user = await res.json()
        console.log('User fetched successfully:', user)

        const formattedUser = {
          id: user.userId || user.id,
          email: user.email,
          name: user.name || 'User',
        }

        login(token, formattedUser)

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
