import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function AdminDashboard() {
  const [jobs, setJobs] = useState([])
  const [loading, setLoading] = useState(true)
  
  const [formData, setFormData] = useState({
    company_name: '',
    job_title: '',
    description: '',
    application_url: '',
    last_date: ''
  })

  useEffect(() => {
    fetchJobs()
  }, [])

  const fetchJobs = async () => {
    const { data } = await supabase
      .from('jobs')
      .select('*')
      .order('created_at', { ascending: false })
    if (data) setJobs(data)
    setLoading(false)
  }

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value })
  }

  const handleCreateJob = async (e) => {
    e.preventDefault()
    const { data: { session } } = await supabase.auth.getSession()
    
    const { error } = await supabase.from('jobs').insert([
      {
        ...formData,
        created_by: session.user.id
      }
    ])

    if (error) {
      alert("Error creating job: " + error.message)
    } else {
      setFormData({
        company_name: '',
        job_title: '',
        description: '',
        application_url: '',
        last_date: ''
      })
      fetchJobs()
    }
  }

  const toggleJobActive = async (id, currentStatus) => {
    await supabase.from('jobs').update({ is_active: !currentStatus }).eq('id', id)
    fetchJobs()
  }

  const deleteJob = async (id) => {
    if(confirm("Are you sure you want to delete this job?")) {
      await supabase.from('jobs').delete().eq('id', id)
      fetchJobs()
    }
  }

  return (
    <div className="animate-fade-in">
      <h1 className="heading-1">Admin Dashboard</h1>
      
      <div className="glass-panel" style={{ padding: '2rem', marginBottom: '2rem' }}>
        <h2 className="heading-2" style={{ fontSize: '1.25rem' }}>Post a New Job</h2>
        <form onSubmit={handleCreateJob} style={{ display: 'grid', gap: '1rem', gridTemplateColumns: '1fr 1fr' }}>
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Company Name</label>
            <input type="text" name="company_name" value={formData.company_name} onChange={handleChange} className="form-input" required />
          </div>
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Job Title</label>
            <input type="text" name="job_title" value={formData.job_title} onChange={handleChange} className="form-input" required />
          </div>
          <div className="form-group" style={{ gridColumn: '1 / -1', marginBottom: 0 }}>
            <label className="form-label">Description</label>
            <textarea name="description" value={formData.description} onChange={handleChange} className="form-input" rows="3" required></textarea>
          </div>
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Application URL</label>
            <input type="url" name="application_url" value={formData.application_url} onChange={handleChange} className="form-input" required />
          </div>
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Last Date</label>
            <input type="date" name="last_date" value={formData.last_date} onChange={handleChange} className="form-input" required />
          </div>
          <div style={{ gridColumn: '1 / -1', marginTop: '1rem' }}>
            <button type="submit" className="btn btn-primary">Post Job</button>
          </div>
        </form>
      </div>

      <h2 className="heading-2" style={{ fontSize: '1.25rem' }}>Manage Existing Jobs</h2>
      <div style={{ overflowX: 'auto' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', backgroundColor: 'white', borderRadius: '8px', overflow: 'hidden', boxShadow: 'var(--card-shadow)' }}>
          <thead style={{ backgroundColor: '#f1f5f9' }}>
            <tr>
              <th style={{ padding: '1rem', textAlign: 'left' }}>Company</th>
              <th style={{ padding: '1rem', textAlign: 'left' }}>Title</th>
              <th style={{ padding: '1rem', textAlign: 'left' }}>Status</th>
              <th style={{ padding: '1rem', textAlign: 'left' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {jobs.map(job => (
              <tr key={job.id} style={{ borderTop: '1px solid #e2e8f0' }}>
                <td style={{ padding: '1rem' }}>{job.company_name}</td>
                <td style={{ padding: '1rem' }}>{job.job_title}</td>
                <td style={{ padding: '1rem' }}>
                  <span style={{ 
                    padding: '0.25rem 0.5rem', 
                    borderRadius: '999px', 
                    fontSize: '0.75rem',
                    fontWeight: 600,
                    backgroundColor: job.is_active ? '#dcfce7' : '#fee2e2',
                    color: job.is_active ? '#166534' : '#991b1b'
                  }}>
                    {job.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td style={{ padding: '1rem', display: 'flex', gap: '0.5rem' }}>
                  <button onClick={() => toggleJobActive(job.id, job.is_active)} className="btn btn-outline" style={{ padding: '0.25rem 0.5rem', fontSize: '0.75rem' }}>
                    Toggle Status
                  </button>
                  <button onClick={() => deleteJob(job.id)} className="btn" style={{ padding: '0.25rem 0.5rem', fontSize: '0.75rem', backgroundColor: '#ef4444', color: 'white', border: 'none' }}>
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
