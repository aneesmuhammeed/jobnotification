import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function AdminDashboard() {
  const [jobs, setJobs] = useState([])
  const [loading, setLoading] = useState(true)
  
  const [formData, setFormData] = useState({
    company_name: '',
    job_title: '',
    description: '',
    application_urls: [''],
    last_date: ''
  })

  const fetchJobs = async () => {
    try {
      const { data, error } = await supabase
        .from('jobs')
        .select('*')
        .order('created_at', { ascending: false })
      if (error) throw error
      if (data) setJobs(data)
    } catch (err) {
      console.error("Error fetching jobs:", err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchJobs()
  }, [])

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value })
  }

  const handleUrlChange = (index, value) => {
    const newUrls = [...formData.application_urls]
    newUrls[index] = value
    setFormData({ ...formData, application_urls: newUrls })
  }

  const addUrlField = () => {
    setFormData({ ...formData, application_urls: [...formData.application_urls, ''] })
  }

  const removeUrlField = (index) => {
    const newUrls = formData.application_urls.filter((_, i) => i !== index)
    setFormData({ ...formData, application_urls: newUrls })
  }

  const handleCreateJob = async (e) => {
    e.preventDefault()
    setLoading(true)
    const { data: { session } } = await supabase.auth.getSession()
    
    const validUrls = formData.application_urls.filter(url => url.trim() !== '')

    try {
      const { error } = await supabase.from('jobs').insert([
        {
          company_name: formData.company_name,
          job_title: formData.job_title,
          description: formData.description,
          application_urls: validUrls,
          last_date: formData.last_date,
          created_by: session.user.id
        }
      ])

      if (error) throw error
      
      alert("Job posted successfully!")
      setFormData({
        company_name: '',
        job_title: '',
        description: '',
        application_urls: [''],
        last_date: ''
      })
      fetchJobs()
    } catch (err) {
      alert("Error creating job: " + err.message)
      setLoading(false)
    }
  }

  const toggleJobActive = async (id, currentStatus) => {
    try {
      const { error } = await supabase.from('jobs').update({ is_active: !currentStatus }).eq('id', id)
      if (error) throw error
      fetchJobs()
    } catch (err) {
      alert("Error updating status: " + err.message)
    }
  }

  const deleteJob = async (id) => {
    if(confirm("Are you sure you want to delete this job?")) {
      try {
        const { error } = await supabase.from('jobs').delete().eq('id', id)
        if (error) throw error
        fetchJobs()
      } catch (err) {
        alert("Error deleting job: " + err.message)
      }
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
          <div className="form-group" style={{ gridColumn: '1 / -1', marginBottom: 0 }}>
            <label className="form-label">Application URLs</label>
            {formData.application_urls.map((url, index) => (
              <div key={index} style={{ display: 'flex', gap: '0.5rem', marginBottom: '0.5rem' }}>
                <input 
                  type="url" 
                  value={url} 
                  onChange={(e) => handleUrlChange(index, e.target.value)} 
                  className="form-input" 
                  placeholder="https://example.com/apply"
                  required={index === 0} 
                />
                {formData.application_urls.length > 1 && (
                  <button type="button" onClick={() => removeUrlField(index)} className="btn btn-outline" style={{ padding: '0 0.75rem', borderColor: '#ef4444', color: '#ef4444' }}>
                    &times;
                  </button>
                )}
              </div>
            ))}
            <button type="button" onClick={addUrlField} className="btn btn-outline" style={{ fontSize: '0.75rem', padding: '0.25rem 0.5rem', marginTop: '0.25rem' }}>
              + Add another link
            </button>
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
      <div className="glass-panel" style={{ overflowX: 'auto', padding: '0' }}>
        <table>
          <thead>
            <tr>
              <th>Company</th>
              <th>Title</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {jobs.map(job => (
              <tr key={job.id}>
                <td>{job.company_name}</td>
                <td>{job.job_title}</td>
                <td>
                  <span style={{ 
                    padding: '0.25rem 0.75rem', 
                    borderRadius: '999px', 
                    fontSize: '0.75rem',
                    fontWeight: 600,
                    backgroundColor: job.is_active ? 'rgba(16, 185, 129, 0.15)' : 'rgba(239, 68, 68, 0.15)',
                    color: job.is_active ? '#34d399' : '#f87171',
                    border: job.is_active ? '1px solid rgba(16, 185, 129, 0.3)' : '1px solid rgba(239, 68, 68, 0.3)'
                  }}>
                    {job.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td style={{ display: 'flex', gap: '0.5rem' }}>
                  <button onClick={() => toggleJobActive(job.id, job.is_active)} className="btn btn-outline" style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem' }}>
                    Toggle Status
                  </button>
                  <button onClick={() => deleteJob(job.id)} className="btn" style={{ padding: '0.25rem 0.75rem', fontSize: '0.75rem', backgroundColor: 'rgba(239, 68, 68, 0.2)', color: '#f87171', border: '1px solid rgba(239, 68, 68, 0.3)' }}>
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
