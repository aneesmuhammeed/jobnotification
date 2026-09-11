import React, { useState } from 'react'
import { supabase } from '../lib/supabase'

export default function Auth() {
  const [loading, setLoading] = useState(false)
  const [isLogin, setIsLogin] = useState(true)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [fullName, setFullName] = useState('')
  const [errorMsg, setErrorMsg] = useState('')

  const handleAuth = async (e) => {
    e.preventDefault()
    setLoading(true)
    setErrorMsg('')

    if (isLogin) {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })
      if (error) setErrorMsg(error.message)
    } else {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
      })
      
      if (error) {
        setErrorMsg(error.message)
      } else if (data.user) {
        // Create profile
        const { error: profileError } = await supabase.from('profiles').insert([
          {
            id: data.user.id,
            full_name: fullName,
            role: 'user', // Default role
          }
        ])
        if (profileError) {
          setErrorMsg(profileError.message)
        } else {
          // Success, user is logged in
        }
      }
    }
    setLoading(false)
  }

  return (
    <div className="flex-center" style={{ minHeight: '80vh' }}>
      <div className="glass-panel" style={{ padding: '2rem', width: '100%', maxWidth: '400px' }}>
        <h1 className="heading-2 text-center" style={{ marginBottom: '1.5rem' }}>
          {isLogin ? 'Welcome Back' : 'Create Account'}
        </h1>
        {errorMsg && (
          <div style={{ backgroundColor: 'rgba(239, 68, 68, 0.1)', color: '#fca5a5', padding: '1rem', borderRadius: '12px', border: '1px solid rgba(239, 68, 68, 0.3)', marginBottom: '1.5rem', fontSize: '0.875rem' }}>
            {errorMsg}
          </div>
        )}
        <form onSubmit={handleAuth}>
          {!isLogin && (
            <div className="form-group">
              <label className="form-label">Full Name</label>
              <input
                type="text"
                className="form-input"
                placeholder="John Doe"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                required={!isLogin}
              />
            </div>
          )}
          <div className="form-group">
            <label className="form-label">Email</label>
            <input
              type="email"
              className="form-input"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label className="form-label">Password</label>
            <input
              type="password"
              className="form-input"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="btn btn-primary" style={{ width: '100%', marginTop: '0.5rem' }} disabled={loading}>
            {loading ? 'Processing...' : (isLogin ? 'Sign In' : 'Sign Up')}
          </button>
        </form>
        <div style={{ marginTop: '1.5rem', textAlign: 'center', fontSize: '0.875rem' }}>
          <span className="text-muted">
            {isLogin ? "Don't have an account? " : "Already have an account? "}
          </span>
          <button 
            type="button" 
            onClick={() => setIsLogin(!isLogin)} 
            style={{ background: 'none', border: 'none', color: 'var(--primary-color)', cursor: 'pointer', fontWeight: 500 }}
          >
            {isLogin ? 'Sign Up' : 'Sign In'}
          </button>
        </div>
      </div>
    </div>
  )
}
