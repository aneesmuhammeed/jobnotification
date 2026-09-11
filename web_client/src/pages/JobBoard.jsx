import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { Briefcase, Calendar, Link as LinkIcon, Building, Search, UploadCloud, DownloadCloud, CheckCircle } from 'lucide-react'

export default function JobBoard({ isAdmin }) {
  const [jobs, setJobs] = useState([])
  const [loading, setLoading] = useState(true)
  const [applying, setApplying] = useState(null)
  const [downloadingId, setDownloadingId] = useState(null)
  const [applicationsMap, setApplicationsMap] = useState({})
  const [selectedJob, setSelectedJob] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [activeTab, setActiveTab] = useState('pending') // 'pending' or 'applied'

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
      .select('*')
      .eq('user_id', session.user.id)
    
    if (data) {
      const appMap = {}
      data.forEach(app => {
        appMap[app.job_id] = app
      })
      setApplicationsMap(appMap)
    }
  }

  const handleFileUploadAndApply = async (e, job) => {
    const file = e.target.files[0]
    if (!file) return

    setApplying(job.id)

    try {
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
          setApplicationsMap(prev => ({
            ...prev,
            [job.id]: {
              job_id: job.id,
              document_name: file.name,
              document_path: documentPath
            }
          }))
          const primaryUrl = (job.application_urls && job.application_urls.length > 0) 
            ? job.application_urls[0] 
            : null
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

  const handleApplyWithoutResume = async (job) => {
    setApplying(job.id)
    try {
      const { data: { session } } = await supabase.auth.getSession()
      
      const { error } = await supabase.from('applications').insert([
        {
          user_id: session.user.id,
          job_id: job.id,
        }
      ])
      
      if (!error) {
        setApplicationsMap(prev => ({
          ...prev,
          [job.id]: {
            job_id: job.id,
          }
        }))
        const primaryUrl = (job.application_urls && job.application_urls.length > 0) 
          ? job.application_urls[0] 
          : null
        if (primaryUrl) {
          window.open(primaryUrl, '_blank')
        }
      } else {
        alert("Error applying: " + error.message)
      }
    } catch (err) {
      alert("Error: " + err.message)
    } finally {
      setApplying(null)
    }
  }

  const handleDownloadResume = async (application) => {
    if (!application?.document_path) return
    setDownloadingId(application.job_id)
    try {
      const botToken = '8107955995:AAGoc6EAjGRsWbXqDqAsdwX25hXd_zttw08'
      const response = await fetch(`https://api.telegram.org/bot${botToken}/getFile?file_id=${application.document_path}`)
      const data = await response.json()
      
      if (data.ok) {
        const filePath = data.result.file_path
        const downloadUrl = `https://api.telegram.org/file/bot${botToken}/${filePath}`
        
        // Attempt to open in a new tab first
        const newWindow = window.open(downloadUrl, '_blank')
        
        // On iOS Safari, async window.open is often blocked by the popup blocker.
        // If it was blocked, newWindow will be null, so we fallback to redirecting the current tab.
        if (!newWindow || newWindow.closed || typeof newWindow.closed === 'undefined') {
          window.location.href = downloadUrl
        }
      } else {
        alert("Failed to get file from Telegram")
      }
    } catch (err) {
      alert("Error downloading resume: " + err.message)
    } finally {
      setDownloadingId(null)
    }
  }

  const visibleJobs = jobs.filter(job => {
    const matchesSearch = job.job_title.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          job.company_name.toLowerCase().includes(searchQuery.toLowerCase())
    if (!matchesSearch) return false

    const hasApplied = !!applicationsMap[job.id]
    if (activeTab === 'pending') return !hasApplied
    return hasApplied
  })

  if (loading) return <div>Loading jobs...</div>

  return (
    <div className="animate-fade-in">
      <div className="flex-between" style={{ marginBottom: '2rem' }}>
        <h1 className="heading-1">Job Board</h1>
        {isAdmin && (
          <Link to="/admin" className="btn btn-outline">
            Manage Jobs
          </Link>
        )}
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: '1rem', marginBottom: '2rem', borderBottom: '1px solid var(--glass-border)', paddingBottom: '0.5rem' }}>
        <button 
          onClick={() => setActiveTab('pending')}
          style={{
            background: 'none', border: 'none', padding: '0.5rem 1rem', fontSize: '1rem', fontWeight: 600, cursor: 'pointer',
            color: activeTab === 'pending' ? 'var(--primary-color)' : 'var(--text-secondary)',
            borderBottom: activeTab === 'pending' ? '2px solid var(--primary-color)' : '2px solid transparent',
            transition: 'var(--transition)'
          }}
        >
          Apply Pending
        </button>
        <button 
          onClick={() => setActiveTab('applied')}
          style={{
            background: 'none', border: 'none', padding: '0.5rem 1rem', fontSize: '1rem', fontWeight: 600, cursor: 'pointer',
            color: activeTab === 'applied' ? 'var(--primary-color)' : 'var(--text-secondary)',
            borderBottom: activeTab === 'applied' ? '2px solid var(--primary-color)' : '2px solid transparent',
            transition: 'var(--transition)'
          }}
        >
          Applied Jobs
        </button>
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
          style={{ paddingLeft: '3rem', fontSize: '1rem', borderRadius: '12px' }}
        />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1.5rem' }}>
        {visibleJobs.map(job => (
          <div 
            key={job.id} 
            className="glass-panel" 
            style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', cursor: 'pointer', transition: 'all 0.2s ease' }}
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
              {activeTab === 'applied' ? (
                <button 
                  onClick={() => handleDownloadResume(applicationsMap[job.id])}
                  className="btn" 
                  style={{ width: '100%', backgroundColor: '#eff6ff', color: '#1d4ed8', border: '1px solid #bfdbfe', display: 'flex', justifyContent: 'center', alignItems: 'center' }} 
                  disabled={!applicationsMap[job.id]?.document_path || downloadingId === job.id}
                >
                  {downloadingId === job.id ? (
                    <span className="spinner spinner-primary" style={{ marginRight: '0.5rem' }}></span>
                  ) : (
                    <DownloadCloud size={16} style={{ marginRight: '0.5rem' }} /> 
                  )}
                  {applicationsMap[job.id]?.document_path ? (downloadingId === job.id ? 'Downloading...' : 'Download Resume') : 'No Resume Attached'}
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
        {visibleJobs.length === 0 && (
          <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '3rem', color: 'var(--text-secondary)', background: 'var(--glass-bg)', borderRadius: '16px' }}>
            <Search size={48} style={{ margin: '0 auto 1rem', opacity: 0.2 }} />
            <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>No jobs found</h3>
            <p>Try adjusting your search query or check the other tab.</p>
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
                ) : (
                  <span className="text-muted">No link provided</span>
                )}
              </div>
            </div>

            <div style={{ borderTop: '1px solid var(--glass-border)', paddingTop: '2rem', textAlign: 'center' }}>
              {activeTab === 'applied' ? (
                <div>
                  <h4 style={{ marginBottom: '1rem', fontSize: '1.1rem', fontWeight: 600 }}>Application Status</h4>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '1rem', backgroundColor: '#ecfdf5', borderRadius: '8px', border: '1px solid #a7f3d0', justifyContent: 'center', marginBottom: '1rem' }}>
                    <CheckCircle size={24} color="#059669" />
                    <div style={{ textAlign: 'left' }}>
                      <div style={{ fontWeight: 600, color: '#065f46' }}>Successfully Applied</div>
                    </div>
                  </div>
                  
                  <button 
                    onClick={() => handleDownloadResume(applicationsMap[selectedJob.id])}
                    className="btn btn-primary"
                    style={{ width: '100%', padding: '1rem', fontSize: '1.1rem', display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '0.5rem' }}
                    disabled={!applicationsMap[selectedJob.id]?.document_path || downloadingId === selectedJob.id}
                  >
                    {downloadingId === selectedJob.id ? (
                      <span className="spinner"></span>
                    ) : (
                      <DownloadCloud size={20} />
                    )}
                    {applicationsMap[selectedJob.id]?.document_path ? (downloadingId === selectedJob.id ? 'Downloading...' : 'Download Submitted Resume') : 'No Resume Attached'}
                  </button>
                </div>
              ) : (
                <div>
                  <h4 style={{ marginBottom: '1rem', fontSize: '1.1rem', fontWeight: 600 }}>Apply Now</h4>
                  <p style={{ color: 'var(--text-secondary)', marginBottom: '1.5rem', fontSize: '0.9rem' }}>
                    Please upload your resume to proceed with the application. Supported formats: PDF, DOC, DOCX.
                  </p>
                  
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
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
                      {applying === selectedJob.id ? (
                        <><span className="spinner"></span> Uploading & Applying...</>
                      ) : (
                        <><UploadCloud size={20} /> Upload Resume & Apply</>
                      )}
                    </label>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', margin: '0.5rem 0' }}>
                      <div style={{ flex: 1, height: '1px', backgroundColor: 'var(--glass-border)' }}></div>
                      <span style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>OR</span>
                      <div style={{ flex: 1, height: '1px', backgroundColor: 'var(--glass-border)' }}></div>
                    </div>

                    <button 
                      onClick={() => handleApplyWithoutResume(selectedJob)}
                      className="btn btn-outline"
                      style={{ 
                        width: '100%', 
                        fontSize: '1.1rem', 
                        padding: '1rem',
                        display: 'flex',
                        justifyContent: 'center',
                        alignItems: 'center',
                        gap: '0.75rem',
                      }}
                      disabled={applying === selectedJob.id}
                    >
                      {applying === selectedJob.id ? (
                        <><span className="spinner spinner-primary"></span> Applying...</>
                      ) : (
                        <><CheckCircle size={20} /> Mark as Applied (No Resume)</>
                      )}
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
