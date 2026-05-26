import React from 'react';
import { useNavigate } from 'react-router-dom';

const Home = () => {
  const navigate = useNavigate();
  
  // Get user info from localStorage
  const userEmail = localStorage.getItem('userEmail');
  const companyName = localStorage.getItem('companyName');
  const accountType = localStorage.getItem('accountType');
  const token = localStorage.getItem('token');

  const handleLogout = () => {
    // Clear all auth data
    localStorage.removeItem('token');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('companyName');
    localStorage.removeItem('phoneNumber');
    localStorage.removeItem('accountType');
    localStorage.removeItem('deviceId');
    
    // Redirect to login
    navigate('/login');
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h1 style={styles.title}>🎉 Welcome to Omoiservespare!</h1>
        
        <div style={styles.successMessage}>
          <p style={styles.successText}>✅ Login Successful!</p>
        </div>

        <div style={styles.userInfo}>
          <h2 style={styles.subtitle}>User Information</h2>
          <div style={styles.infoRow}>
            <span style={styles.label}>Email:</span>
            <span style={styles.value}>{userEmail || 'Not available'}</span>
          </div>
          <div style={styles.infoRow}>
            <span style={styles.label}>Company:</span>
            <span style={styles.value}>{companyName || 'Not available'}</span>
          </div>
          <div style={styles.infoRow}>
            <span style={styles.label}>Account Type:</span>
            <span style={styles.value}>{accountType || 'Not available'}</span>
          </div>
          <div style={styles.infoRow}>
            <span style={styles.label}>Token:</span>
            <span style={styles.value}>
              {token ? `${token.substring(0, 30)}...` : 'Not available'}
            </span>
          </div>
        </div>

        <div style={styles.actions}>
          <button style={styles.logoutButton} onClick={handleLogout}>
            Logout
          </button>
        </div>

        <div style={styles.footer}>
          <p style={styles.footerText}>
            Your authentication is working correctly! 🚀
          </p>
          <p style={styles.footerText}>
            You can now integrate this with your actual home page.
          </p>
        </div>
      </div>
    </div>
  );
};

const styles = {
  container: {
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    padding: '20px',
  },
  card: {
    backgroundColor: 'white',
    borderRadius: '12px',
    padding: '40px',
    maxWidth: '600px',
    width: '100%',
    boxShadow: '0 10px 40px rgba(0, 0, 0, 0.1)',
  },
  title: {
    fontSize: '28px',
    fontWeight: 'bold',
    color: '#333',
    marginBottom: '20px',
    textAlign: 'center',
  },
  successMessage: {
    backgroundColor: '#d4edda',
    border: '1px solid #c3e6cb',
    borderRadius: '8px',
    padding: '15px',
    marginBottom: '30px',
  },
  successText: {
    color: '#155724',
    fontSize: '18px',
    fontWeight: '600',
    margin: 0,
    textAlign: 'center',
  },
  userInfo: {
    backgroundColor: '#f8f9fa',
    borderRadius: '8px',
    padding: '20px',
    marginBottom: '30px',
  },
  subtitle: {
    fontSize: '20px',
    fontWeight: '600',
    color: '#333',
    marginBottom: '15px',
  },
  infoRow: {
    display: 'flex',
    justifyContent: 'space-between',
    padding: '10px 0',
    borderBottom: '1px solid #e9ecef',
  },
  label: {
    fontWeight: '600',
    color: '#666',
  },
  value: {
    color: '#333',
    wordBreak: 'break-all',
  },
  actions: {
    display: 'flex',
    justifyContent: 'center',
    marginBottom: '20px',
  },
  logoutButton: {
    backgroundColor: '#dc3545',
    color: 'white',
    border: 'none',
    borderRadius: '8px',
    padding: '12px 40px',
    fontSize: '16px',
    fontWeight: '600',
    cursor: 'pointer',
    transition: 'background-color 0.3s',
  },
  footer: {
    textAlign: 'center',
    paddingTop: '20px',
    borderTop: '1px solid #e9ecef',
  },
  footerText: {
    color: '#666',
    fontSize: '14px',
    margin: '5px 0',
  },
};

export default Home;
