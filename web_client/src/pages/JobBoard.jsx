import React, { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { Briefcase, Calendar, Link as LinkIcon, Building } from 'lucide-react'

export default function JobBoard({ isAdmin }) {
  const [jobs, setJobs] = useState([])
  const [loading, setLoading] = useState(true)
  const [applying, setApplying] = useState(null)
  const [userApplications, setUserApplications] = useState(new Set())
  const [selectedJob, setSelectedJob] = useState(null)

  useEffect(() => {
    fetchJobs()
    fetchUserApplications()
  }, [])

  const fetchJobs = async () => {
    const { data, error } = await supabase
      .from('jobs')
      .select('*')
      .eq('is_active', true)
      .order('created_at', { ascending: false })
    
    if (data) setJobs(data)
    setLoading(false)
  }

  const fetchUserApplications = async () => {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session?.user) return

    const { data } = await supabase
      .from('applications')
      .select('job_id')
      .eq('user_id', session.user.id)
    
    if (data) {
      setUserApplications(new Set(data.map(app => app.job_id)))
    }
  }

  const handleApply = async (job) => {
    // For MVP, applying just means creating a record in the applications table
    // (Without telegram upload for this simple action, unless specified otherwise)
    setApplying(job.id)
    const { data: { session } } = await supabase.auth.getSession()
    
    const { error } = await supabase.from('applications').insert([
      {
        user_id: session.user.id,
        job_id: job.id,
      }
    ])
    
    if (!error) {
      setUserApplications(prev => new Set(prev).add(job.id))
      // Open the primary URL
      const primaryUrl = (job.application_urls && job.application_urls.length > 0) 
        ? job.application_urls[0] 
        : job.application_url
      if (primaryUrl) {
        window.open(primaryUrl, '_blank')
      }
    } else {
      alert("Error applying: " + error.message)
    }
    setApplying(null)
  }

  if (loading) return <div>Loading jobs...</div>

  return (
    <div className="animate-fade-in">
      <div className="flex-between" style={{ marginBottom: '2rem' }}>
        <h1 className="heading-1">Latest Jobs</h1>
        {isAdmin && (
          <a href="/admin" className="btn btn-outline">
            Manage Jobs
          </a>
        )}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1.5rem' }}>
        {jobs.map(job => (
          <div 
            key={job.id} 
            className="glass-panel" 
            style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', cursor: 'pointer' }}
            onClick={() => setSelectedJob(job)}
          >
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
                <Building size={18} className="text-muted" />
                <span style={{ fontWeight: 600, color: 'var(--primary-color)' }}>{job.company_name}</span>
              </div>
              <h2 className="heading-2" style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>{job.job_title}</h2>
              <p className="text-muted" style={{ marginBottom: '1rem', fontSize: '0.875rem', display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                {job.description}
              </p>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
                <Calendar size={16} />
                <span>Deadline: {new Date(job.last_date).toLocaleDateString()}</span>
              </div>
            </div>
            
            <div style={{ marginTop: '1.5rem', paddingTop: '1.5rem', borderTop: '1px solid var(--glass-border)' }} onClick={e => e.stopPropagation()}>
              {userApplications.has(job.id) ? (
                <button className="btn" style={{ width: '100%', backgroundColor: '#10b981', color: 'white' }} disabled>
                  Applied
                </button>
              ) : (
                <button 
                  onClick={() => handleApply(job)} 
                  className="btn btn-primary" 
                  style={{ width: '100%' }}
                  disabled={applying === job.id}
                >
                  {applying === job.id ? 'Applying...' : 'Apply Now'} <LinkIcon size={16} />
                </button>
              )}
            </div>
          </div>
        ))}
        {jobs.length === 0 && (
          <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '3rem', color: 'var(--text-secondary)' }}>
            No jobs found.
          </div>
        )}
      </div>

      {selectedJob && (
        <div className="modal-overlay" onClick={() => setSelectedJob(null)}>
          <div className="glass-panel modal-content" onClick={e => e.stopPropagation()}>
            <button onClick={() => setSelectedJob(null)} style={{ 
              position: 'absolute', top: '1rem', right: '1rem', background: 'none', 
              border: 'none', fontSize: '2rem', cursor: 'pointer', color: 'var(--text-secondary)' 
            }}>
              &times;
            </button>
            
            <h1 className="heading-1" style={{ marginBottom: '0.5rem', fontSize: '2rem' }}>{selectedJob.job_title}</h1>
            <h3 style={{ color: 'var(--primary-color)', marginBottom: '2rem', fontSize: '1.25rem', fontWeight: 600 }}>{selectedJob.company_name}</h3>
            
            <div style={{ marginBottom: '2rem' }}>
              <h4 style={{ marginBottom: '0.5rem', fontSize: '1.1rem', fontWeight: 600 }}>Job Description</h4>
              <p style={{ marginTop: '0.5rem', whiteSpace: 'pre-wrap', lineHeight: 1.6, color: 'var(--text-secondary)' }}>
                {selectedJob.description}
              </p>
            </div>
            
            <div className="modal-grid" style={{ marginBottom: '2.5rem' }}>
              <div>
                <strong style={{ display: 'block', marginBottom: '0.25rem', color: 'var(--text-secondary)' }}>Deadline</strong>
                <div style={{ fontWeight: 500 }}>{new Date(selectedJob.last_date).toLocaleDateString()}</div>
              </div>
              <div style={{ gridColumn: '1 / -1' }}>
                <strong style={{ display: 'block', marginBottom: '0.25rem', color: 'var(--text-secondary)' }}>Application Links</strong>
                {selectedJob.application_urls && selectedJob.application_urls.length > 0 ? (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                    {selectedJob.application_urls.map((url, idx) => (
                      <a key={idx} href={url} target="_blank" rel="noopener noreferrer" style={{ color: 'var(--primary-color)', wordBreak: 'break-all', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                        <LinkIcon size={14} /> {url}
                      </a>
                    ))}
                  </div>
                ) : selectedJob.application_url ? (
                  <a href={selectedJob.application_url} target="_blank" rel="noopener noreferrer" style={{ color: 'var(--primary-color)', wordBreak: 'break-all', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                    <LinkIcon size={14} /> {selectedJob.application_url}
                  </a>
                ) : (
                  <span className="text-muted">No link provided</span>
                )}
              </div>
            </div>

            <div style={{ borderTop: '1px solid var(--glass-border)', paddingTop: '2rem' }}>
              {userApplications.has(selectedJob.id) ? (
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '1rem', backgroundColor: '#ecfdf5', borderRadius: '8px', border: '1px solid #a7f3d0', flexWrap: 'wrap' }}>
                  <span style={{ fontSize: '1.5rem' }}>✅</span>
                  <div>
                    <div style={{ fontWeight: 600, color: '#065f46' }}>You have applied for this job</div>
                    <div style={{ fontSize: '0.875rem', color: '#10b981' }}>Check "My Applications" to view or update your resume</div>
                  </div>
                </div>
              ) : (
                <button 
                  onClick={() => handleApply(selectedJob)} 
                  className="btn btn-primary" 
                  style={{ width: '100%', fontSize: '1.1rem', padding: '1rem' }}
                  disabled={applying === selectedJob.id}
                >
                  {applying === selectedJob.id ? 'Applying...' : 'Apply Now'} <LinkIcon size={20} />
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
