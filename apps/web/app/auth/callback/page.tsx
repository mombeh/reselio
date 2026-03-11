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

        const user = await res.json()

        login(token, user)

        router.push('/dashboard')
      } catch (error) {
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