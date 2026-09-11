import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function MyApplications() {
  const [applications, setApplications] = useState([])
  const [loading, setLoading] = useState(true)
  const [uploading, setUploading] = useState(null)
  const [selectedApp, setSelectedApp] = useState(null)

  useEffect(() => {
    fetchApplications()
  }, [])

  const fetchApplications = async () => {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session?.user) return

    // Since we don't have a direct view, we'll fetch apps then fetch jobs
    const { data: apps } = await supabase
      .from('applications')
      .select('*')
      .eq('user_id', session.user.id)
      .order('applied_at', { ascending: false })

    if (apps && apps.length > 0) {
      const jobIds = apps.map(app => app.job_id)
      const { data: jobs } = await supabase
        .from('jobs')
        .select('*')
        .in('id', jobIds)
      
      const jobsMap = jobs.reduce((acc, job) => {
        acc[job.id] = job
        return acc
      }, {})

      const merged = apps.map(app => ({
        ...app,
        job: jobsMap[app.job_id]
      }))
      setApplications(merged)
    }
    setLoading(false)
  }

  const handleFileUpload = async (e, applicationId) => {
    const file = e.target.files[0]
    if (!file) return

    setUploading(applicationId)

    try {
      // Upload to Telegram as requested
      const botToken = '8107955995:AAGoc6EAjGRsWbXqDqAsdwX25hXd_zttw08'
      const chatId = '-1003741865575'
      
      const formData = new FormData()
      formData.append('chat_id', chatId)
      formData.append('document', file)

      const response = await fetch(`https://api.telegram.org/bot${botToken}/sendDocument`, {
        method: 'POST',
        body: formData,
      })

      const data = await response.json()
      
      if (data.ok) {
        // Save metadata to Supabase
        const documentPath = data.result.document.file_id
        await supabase
          .from('applications')
          .update({
            document_name: file.name,
            document_path: documentPath
          })
          .eq('id', applicationId)
        
        // Refresh local state
        setApplications(apps => apps.map(app => {
          if (app.id === applicationId) {
            const updatedApp = { ...app, document_name: file.name, document_path: documentPath }
            if (selectedApp?.id === applicationId) setSelectedApp(updatedApp)
            return updatedApp
          }
          return app
        }))
        alert("Resume uploaded successfully!")
      } else {
        alert("Failed to upload to Telegram")
      }
    } catch (err) {
      alert("Error: " + err.message)
    } finally {
      setUploading(null)
    }
  }

  if (loading) return <div>Loading...</div>

  return (
    <div className="animate-fade-in">
      <h1 className="heading-1">My Applications</h1>
      
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
        {applications.map(app => (
          <div 
            key={app.id} 
            className="glass-panel" 
            style={{ padding: '1.5rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}
            onClick={() => setSelectedApp(app)}
          >
            <div>
              <h2 className="heading-2" style={{ fontSize: '1.25rem', marginBottom: '0.25rem' }}>
                {app.job?.job_title}
              </h2>
              <div className="text-muted" style={{ marginBottom: '0.5rem' }}>{app.job?.company_name}</div>
              <div style={{ fontSize: '0.875rem' }}>
                Applied on: {new Date(app.applied_at).toLocaleDateString()}
              </div>
              
              {app.document_name ? (
                <div style={{ marginTop: '0.5rem', fontSize: '0.875rem', color: 'var(--primary-color)' }}>
                  📄 {app.document_name} uploaded
                </div>
              ) : (
                <div style={{ marginTop: '0.5rem', fontSize: '0.875rem', color: '#dc2626' }}>
                  No resume attached
                </div>
              )}
            </div>
            
            <div onClick={e => e.stopPropagation()}>
              <input 
                type="file" 
                id={`file-${app.id}`} 
                style={{ display: 'none' }}
                onChange={(e) => handleFileUpload(e, app.id)}
                accept=".pdf,.doc,.docx"
              />
              <label 
                htmlFor={`file-${app.id}`} 
                className={`btn ${app.document_name ? 'btn-outline' : 'btn-primary'}`}
                style={{ cursor: uploading === app.id ? 'not-allowed' : 'pointer', display: 'inline-block' }}
              >
                {uploading === app.id ? 'Uploading...' : (app.document_name ? 'Update Resume' : 'Attach Resume')}
              </label>
            </div>
          </div>
        ))}

        {applications.length === 0 && (
          <div className="text-center text-muted" style={{ padding: '3rem' }}>
            You haven't applied to any jobs yet.
          </div>
        )}
      </div>

      {selectedApp && (
        <div className="modal-overlay" onClick={() => setSelectedApp(null)}>
          <div className="glass-panel modal-content" onClick={e => e.stopPropagation()}>
            <button onClick={() => setSelectedApp(null)} style={{ 
              position: 'absolute', top: '1rem', right: '1rem', background: 'none', 
              border: 'none', fontSize: '2rem', cursor: 'pointer', color: 'var(--text-secondary)' 
            }}>
              &times;
            </button>
            
            <h1 className="heading-1" style={{ marginBottom: '0.5rem', fontSize: '2rem' }}>{selectedApp.job?.job_title}</h1>
            <h3 style={{ color: 'var(--primary-color)', marginBottom: '2rem', fontSize: '1.25rem', fontWeight: 600 }}>{selectedApp.job?.company_name}</h3>
            
            <div style={{ marginBottom: '2rem' }}>
              <h4 style={{ marginBottom: '0.5rem', fontSize: '1.1rem', fontWeight: 600 }}>Job Description</h4>
              <p style={{ marginTop: '0.5rem', whiteSpace: 'pre-wrap', lineHeight: 1.6, color: 'var(--text-secondary)' }}>
                {selectedApp.job?.description}
              </p>
            </div>
            
            <div className="modal-grid" style={{ marginBottom: '2.5rem' }}>
              <div>
                <strong style={{ display: 'block', marginBottom: '0.25rem', color: 'var(--text-secondary)' }}>Applied On</strong>
                <div style={{ fontWeight: 500 }}>{new Date(selectedApp.applied_at).toLocaleDateString()}</div>
              </div>
              <div>
                <strong style={{ display: 'block', marginBottom: '0.25rem', color: 'var(--text-secondary)' }}>Deadline</strong>
                <div style={{ fontWeight: 500 }}>{new Date(selectedApp.job?.last_date).toLocaleDateString()}</div>
              </div>
              <div style={{ gridColumn: '1 / -1' }}>
                <strong style={{ display: 'block', marginBottom: '0.25rem', color: 'var(--text-secondary)' }}>Application Links</strong>
                {selectedApp.job?.application_urls && selectedApp.job?.application_urls.length > 0 ? (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                    {selectedApp.job?.application_urls.map((url, idx) => (
                      <a key={idx} href={url} target="_blank" rel="noopener noreferrer" style={{ color: 'var(--primary-color)', wordBreak: 'break-all' }}>
                        {url}
                      </a>
                    ))}
                  </div>
                ) : selectedApp.job?.application_url ? (
                  <a href={selectedApp.job?.application_url} target="_blank" rel="noopener noreferrer" style={{ color: 'var(--primary-color)', wordBreak: 'break-all' }}>
                    {selectedApp.job?.application_url}
                  </a>
                ) : (
                  <span className="text-muted">No link provided</span>
                )}
              </div>
            </div>

            <div style={{ borderTop: '1px solid var(--glass-border)', paddingTop: '2rem' }}>
              <h3 style={{ marginBottom: '1rem', fontSize: '1.25rem', fontWeight: 600 }}>Uploaded Resume</h3>
              {selectedApp.document_name ? (
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1.5rem', padding: '1.25rem', backgroundColor: '#eff6ff', borderRadius: '12px', border: '1px solid #bfdbfe', flexWrap: 'wrap' }}>
                  <span style={{ fontSize: '1.5rem' }}>📄</span>
                  <div>
                    <div style={{ fontWeight: 600, color: '#1e40af', wordBreak: 'break-all' }}>{selectedApp.document_name}</div>
                    <div style={{ fontSize: '0.875rem', color: '#2563eb' }}>Successfully uploaded</div>
                  </div>
                </div>
              ) : (
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1.5rem', padding: '1.25rem', backgroundColor: '#fef2f2', borderRadius: '12px', border: '1px solid #fecaca', flexWrap: 'wrap' }}>
                  <span style={{ fontSize: '1.5rem' }}>⚠️</span>
                  <div>
                    <div style={{ fontWeight: 600, color: '#991b1b' }}>No resume attached</div>
                    <div style={{ fontSize: '0.875rem', color: '#dc2626' }}>Please upload your resume to complete the application</div>
                  </div>
                </div>
              )}
              
              <div>
                <input 
                  type="file" 
                  id={`file-modal-${selectedApp.id}`} 
                  style={{ display: 'none' }}
                  onChange={(e) => handleFileUpload(e, selectedApp.id)}
                  accept=".pdf,.doc,.docx"
                />
                <label 
                  htmlFor={`file-modal-${selectedApp.id}`} 
                  className={`btn ${selectedApp.document_name ? 'btn-outline' : 'btn-primary'}`}
                  style={{ cursor: uploading === selectedApp.id ? 'not-allowed' : 'pointer', display: 'inline-block', width: '100%', textAlign: 'center' }}
                >
                  {uploading === selectedApp.id ? 'Uploading...' : (selectedApp.document_name ? 'Update Resume' : 'Upload Resume Now')}
                </label>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
