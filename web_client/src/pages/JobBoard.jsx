import React, { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { Briefcase, Calendar, Link as LinkIcon, Building, Search, UploadCloud, CheckCircle } from 'lucide-react'

export default function JobBoard({ isAdmin }) {
  const [jobs, setJobs] = useState([])
  const [loading, setLoading] = useState(true)
  const [applying, setApplying] = useState(null)
  const [userApplications, setUserApplications] = useState(new Set())
  const [selectedJob, setSelectedJob] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')

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

  const handleFileUploadAndApply = async (e, job) => {
    const file = e.target.files[0]
    if (!file) return

    setApplying(job.id)

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
        const documentPath = data.result.document.file_id
        const { data: { session } } = await supabase.auth.getSession()
        
        const { error } = await supabase.from('applications').insert([
          {
            user_id: session.user.id,
            job_id: job.id,
            document_name: file.name,
            document_path: documentPath
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
      } else {
        alert("Failed to upload resume to Telegram")
      }
    } catch (err) {
      alert("Error: " + err.message)
    } finally {
      setApplying(null)
    }
  }

  const filteredJobs = jobs.filter(job => 
    job.job_title.toLowerCase().includes(searchQuery.toLowerCase()) || 
    job.company_name.toLowerCase().includes(searchQuery.toLowerCase())
  )

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

      <div style={{ marginBottom: '2rem', position: 'relative' }}>
        <div style={{ position: 'absolute', top: '50%', transform: 'translateY(-50%)', left: '1rem', color: 'var(--text-secondary)' }}>
          <Search size={20} />
        </div>
        <input 
          type="text" 
          placeholder="Search by job title or company..." 
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="form-input"
          style={{ paddingLeft: '3rem', fontSize: '1rem', borderRadius: '12px', border: '1px solid var(--glass-border)', boxShadow: 'var(--shadow-sm)' }}
        />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1.5rem' }}>
        {filteredJobs.map(job => (
          <div 
            key={job.id} 
            className="glass-panel" 
            style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', cursor: 'pointer', transition: 'all 0.2s ease', border: '1px solid transparent' }}
            onClick={() => setSelectedJob(job)}
            onMouseOver={(e) => e.currentTarget.style.borderColor = 'var(--primary-color)'}
            onMouseOut={(e) => e.currentTarget.style.borderColor = 'transparent'}
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
                <button className="btn" style={{ width: '100%', backgroundColor: '#f0fdf4', color: '#166534', border: '1px solid #bbf7d0', cursor: 'default' }} disabled>
                  <CheckCircle size={16} style={{ marginRight: '0.5rem', display: 'inline' }} /> Applied
                </button>
              ) : (
                <button 
                  onClick={() => setSelectedJob(job)} 
                  className="btn btn-outline" 
                  style={{ width: '100%', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '0.5rem' }}
                >
                  View & Apply <Briefcase size={16} />
                </button>
              )}
            </div>
          </div>
        ))}
        {filteredJobs.length === 0 && (
          <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '3rem', color: 'var(--text-secondary)', background: 'var(--glass-bg)', borderRadius: '16px' }}>
            <Search size={48} style={{ margin: '0 auto 1rem', opacity: 0.2 }} />
            <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>No jobs found</h3>
            <p>Try adjusting your search query.</p>
          </div>
        )}
      </div>

      {selectedJob && (
        <div className="modal-overlay" onClick={() => setSelectedJob(null)}>
          <div className="glass-panel modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: '600px', width: '100%', maxHeight: '90vh', overflowY: 'auto' }}>
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

            <div style={{ borderTop: '1px solid var(--glass-border)', paddingTop: '2rem', textAlign: 'center' }}>
              {userApplications.has(selectedJob.id) ? (
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '1rem', backgroundColor: '#ecfdf5', borderRadius: '8px', border: '1px solid #a7f3d0', justifyContent: 'center' }}>
                  <CheckCircle size={24} color="#059669" />
                  <div style={{ textAlign: 'left' }}>
                    <div style={{ fontWeight: 600, color: '#065f46' }}>Application Submitted</div>
                    <div style={{ fontSize: '0.875rem', color: '#10b981' }}>Check "My Applications" for updates</div>
                  </div>
                </div>
              ) : (
                <div>
                  <h4 style={{ marginBottom: '1rem', fontSize: '1.1rem', fontWeight: 600 }}>Apply Now</h4>
                  <p style={{ color: 'var(--text-secondary)', marginBottom: '1.5rem', fontSize: '0.9rem' }}>
                    Please upload your resume to proceed with the application. Supported formats: PDF, DOC, DOCX.
                  </p>
                  
                  <input 
                    type="file" 
                    id="resume-upload" 
                    style={{ display: 'none' }}
                    onChange={(e) => handleFileUploadAndApply(e, selectedJob)}
                    accept=".pdf,.doc,.docx"
                    disabled={applying === selectedJob.id}
                  />
                  <label 
                    htmlFor="resume-upload" 
                    className="btn btn-primary"
                    style={{ 
                      width: '100%', 
                      fontSize: '1.1rem', 
                      padding: '1rem',
                      display: 'flex',
                      justifyContent: 'center',
                      alignItems: 'center',
                      gap: '0.75rem',
                      cursor: applying === selectedJob.id ? 'not-allowed' : 'pointer',
                      opacity: applying === selectedJob.id ? 0.7 : 1
                    }}
                  >
                    {applying === selectedJob.id ? 'Uploading & Applying...' : 'Upload Resume & Apply'} 
                    <UploadCloud size={20} />
                  </label>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
