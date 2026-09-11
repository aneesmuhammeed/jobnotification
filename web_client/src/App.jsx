import React, { useEffect, useState, Suspense, lazy } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate, Link } from 'react-router-dom'
import { supabase } from './lib/supabase'
import { LogOut, Bell, Settings } from 'lucide-react'
import { requestNotificationPermission, listenForForegroundMessages } from './lib/firebase'

// Lazy loaded pages for code splitting
const Auth = lazy(() => import('./pages/Auth'))
const JobBoard = lazy(() => import('./pages/JobBoard'))
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'))

// ProtectedRoute component
const ProtectedRoute = ({ session, children, requireAdmin, isAdmin }) => {
  if (!session) return <Navigate to="/auth" />
  if (requireAdmin && !isAdmin) return <Navigate to="/" />
  return children
}

// Layout Component
const Layout = ({ children, session, onSignOut }) => {
  const [showSettings, setShowSettings] = useState(false)
  const [reminderSettings, setReminderSettings] = useState({
    daily_reminder_enabled: true,
    reminder_time_utc: '12:30:00'
  })
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    const fetchSettings = async () => {
      const { data } = await supabase
        .from('profiles')
        .select('daily_reminder_enabled, reminder_time_utc')
        .eq('id', session.user.id)
        .single()
      
      if (data) {
        setReminderSettings({
          daily_reminder_enabled: data.daily_reminder_enabled,
          reminder_time_utc: data.reminder_time_utc
        })
      }
    }

    if (session?.user?.id) {
      fetchSettings()
    }
  }, [session?.user?.id])

  const handleSaveSettings = async () => {
    setSaving(true)
    const { error } = await supabase
      .from('profiles')
      .update({
        daily_reminder_enabled: reminderSettings.daily_reminder_enabled,
        reminder_time_utc: reminderSettings.reminder_time_utc
      })
      .eq('id', session.user.id)
    
    setSaving(false)
    if (error) {
      alert("Error saving settings: " + error.message)
    } else {
      alert("Settings saved successfully!")
      setShowSettings(false)
    }
  }

  const enablePush = async () => {
    const token = await requestNotificationPermission()
    if (token) {
      alert("Notifications enabled!")
      listenForForegroundMessages()
    }
  }

  // Convert UTC time from db to local time for input (rough conversion for input type="time")
  const getLocalTimeFromUtc = (utcTimeStr) => {
    if (!utcTimeStr) return '12:30'
    const date = new Date()
    const [hours, minutes] = utcTimeStr.split(':')
    date.setUTCHours(parseInt(hours, 10))
    date.setUTCMinutes(parseInt(minutes, 10))
    const localHours = date.getHours().toString().padStart(2, '0')
    const localMinutes = date.getMinutes().toString().padStart(2, '0')
    return `${localHours}:${localMinutes}`
  }

  // Convert local time from input to UTC for db
  const getUtcTimeFromLocal = (localTimeStr) => {
    if (!localTimeStr) return '12:30:00'
    const date = new Date()
    const [hours, minutes] = localTimeStr.split(':')
    date.setHours(parseInt(hours, 10))
    date.setMinutes(parseInt(minutes, 10))
    const utcHours = date.getUTCHours().toString().padStart(2, '0')
    const utcMinutes = date.getUTCMinutes().toString().padStart(2, '0')
    return `${utcHours}:${utcMinutes}:00`
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <nav className="navbar">
        <div className="container flex-between">
          <Link to="/" className="text-gradient" style={{ fontSize: '1.5rem', fontWeight: 700, textDecoration: 'none' }}>
            JobNoti
          </Link>
          <div className="nav-links">
            {session ? (
              <>
                <Link to="/" className="nav-link">Jobs</Link>
                <button onClick={enablePush} className="btn btn-outline" style={{ padding: '0.4rem 0.8rem' }} title="Enable Notifications">
                  <Bell size={16} />
                </button>
                <button onClick={() => setShowSettings(true)} className="btn btn-outline" style={{ padding: '0.4rem 0.8rem' }} title="Settings">
                  <Settings size={16} />
                </button>
                <button onClick={onSignOut} className="btn btn-outline" style={{ padding: '0.4rem 0.8rem' }}>
                  <LogOut size={16} /> Sign Out
                </button>
              </>
            ) : (
              <Link to="/auth" className="btn btn-primary">Sign In</Link>
            )}
          </div>
        </div>
      </nav>
      <main className="container" style={{ flex: 1, padding: '2rem 1.5rem' }}>
        {children}
      </main>

      {/* Settings Modal */}
      {showSettings && (
        <div className="modal-overlay" onClick={() => setShowSettings(false)}>
          <div className="glass-panel modal-content" style={{ maxWidth: '500px' }} onClick={e => e.stopPropagation()}>
            <button onClick={() => setShowSettings(false)} style={{ 
              position: 'absolute', top: '1rem', right: '1rem', background: 'none', 
              border: 'none', fontSize: '2rem', cursor: 'pointer', color: 'var(--text-secondary)' 
            }}>
              &times;
            </button>
            <h2 className="heading-2">Settings</h2>
            
            <div className="form-group" style={{ marginTop: '2rem' }}>
              <label className="form-label" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '1rem' }}>
                <input 
                  type="checkbox" 
                  checked={reminderSettings.daily_reminder_enabled}
                  onChange={(e) => setReminderSettings({...reminderSettings, daily_reminder_enabled: e.target.checked})}
                  style={{ width: '1.2rem', height: '1.2rem' }}
                />
                Enable Daily Application Reminder
              </label>
            </div>

            {reminderSettings.daily_reminder_enabled && (
              <div className="form-group" style={{ marginTop: '1.5rem', paddingLeft: '1.7rem' }}>
                <label className="form-label">Reminder Time</label>
                <input 
                  type="time" 
                  className="form-input" 
                  value={getLocalTimeFromUtc(reminderSettings.reminder_time_utc)}
                  onChange={(e) => setReminderSettings({...reminderSettings, reminder_time_utc: getUtcTimeFromLocal(e.target.value)})}
                  style={{ maxWidth: '200px' }}
                />
                <p className="text-muted" style={{ fontSize: '0.8rem', marginTop: '0.5rem' }}>
                  You will receive a reminder at this time every day.
                </p>
              </div>
            )}

            <div style={{ marginTop: '2.5rem', display: 'flex', justifyContent: 'flex-end', gap: '1rem' }}>
              <button onClick={() => setShowSettings(false)} className="btn btn-outline">Cancel</button>
              <button onClick={handleSaveSettings} className="btn btn-primary" disabled={saving}>
                {saving ? 'Saving...' : 'Save Changes'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function App() {
  const [session, setSession] = useState(null)
  const [isAdmin, setIsAdmin] = useState(false)
  const [loading, setLoading] = useState(true)

  const checkAdminStatus = async (userId) => {
    if (!userId) {
      setIsAdmin(false)
      setLoading(false)
      return
    }
    const { data } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .single()
    
    setIsAdmin(data?.role === 'admin')
    setLoading(false)
  }

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      checkAdminStatus(session?.user?.id)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
      checkAdminStatus(session?.user?.id)
    })

    return () => subscription.unsubscribe()
  }, [])

  const handleSignOut = async () => {
    await supabase.auth.signOut()
  }

  if (loading) {
    return <div className="flex-center" style={{ height: '100vh' }}>Loading...</div>
  }

  return (
    <Router>
      <Layout session={session} onSignOut={handleSignOut}>
        <Suspense fallback={<div className="flex-center" style={{ minHeight: '50vh' }}>Loading Page...</div>}>
          <Routes>
            <Route 
              path="/" 
              element={
                <ProtectedRoute session={session}>
                  <JobBoard isAdmin={isAdmin} />
                </ProtectedRoute>
              } 
            />

            <Route 
              path="/admin" 
              element={
                <ProtectedRoute session={session} requireAdmin={true} isAdmin={isAdmin}>
                  <AdminDashboard />
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/auth" 
              element={!session ? <Auth /> : <Navigate to="/" />} 
            />
            <Route 
              path="*" 
              element={<Navigate to="/" />} 
            />
          </Routes>
        </Suspense>
      </Layout>
    </Router>
  )
}

export default App

