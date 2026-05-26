# Complete Frontend Code for Helpdesk System

## Issues to Fix

1. ❌ Phone number not auto-populated in RaiseTicket page
2. ❌ Tickets not displaying in UserDashboard
3. ❌ Tickets not displaying in AgentDashboard

## Solution: Complete Working Frontend Code

### Prerequisites

```bash
npm install axios sockjs-client @stomp/stompjs
```

### File Structure
```
src/
├── services/
│   ├── api.js              # API configuration
│   ├── ticketApi.js        # Ticket API calls
│   └── websocketService.js # WebSocket connection
├── pages/
│   ├── RaiseTicket.jsx     # Create ticket page
│   ├── UserDashboard.jsx   # User's tickets
│   └── AgentDashboard.jsx  # Agent's dashboard
└── utils/
    └── auth.js             # Auth utilities
```

---

## 1. API Configuration (src/services/api.js)

```javascript
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Add token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle response errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

---

## 2. Ticket API Service (src/services/ticketApi.js)

```javascript
import api from './api';

export const ticketApi = {
  // Create new ticket
  createTicket: async (ticketData) => {
    const response = await api.post('/tickets', ticketData);
    return response.data;
  },

  // Get user's tickets
  getMyTickets: async () => {
    const response = await api.get('/tickets/my-tickets');
    return response.data;
  },

  // Get ticket details
  getTicketDetails: async (ticketId) => {
    const response = await api.get(`/tickets/${ticketId}`);
    return response.data;
  },

  // Agent: Get dashboard
  getAgentDashboard: async () => {
    const response = await api.get('/tickets/agent/dashboard');
    return response.data;
  },

  // Agent: Send message
  sendMessage: async (ticketId, message) => {
    const response = await api.post(`/tickets/${ticketId}/messages`, { message });
    return response.data;
  },

  // Agent: Update status
  updateStatus: async (ticketId, status, message = null) => {
    const response = await api.patch(`/tickets/${ticketId}/status`, { status, message });
    return response.data;
  },

  // Agent: Assign ticket
  assignTicket: async (ticketId) => {
    const response = await api.post(`/tickets/${ticketId}/assign`);
    return response.data;
  }
};

// Get current user info
export const getUserInfo = async () => {
  const response = await api.get('/users/me'); // Adjust endpoint as needed
  return response.data;
};
```

---

## 3. Auth Utilities (src/utils/auth.js)

```javascript
// Get user data from token or localStorage
export const getCurrentUser = () => {
  const userStr = localStorage.getItem('user');
  if (userStr) {
    return JSON.parse(userStr);
  }
  return null;
};

// Get token
export const getToken = () => {
  return localStorage.getItem('token');
};

// Check if user is authenticated
export const isAuthenticated = () => {
  return !!getToken();
};

// Logout
export const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  window.location.href = '/login';
};
```

---

## 4. RaiseTicket Component (COMPLETE & WORKING)

```javascript
import React, { useState, useEffect } from 'react';
import { ticketApi } from '../services/ticketApi';
import { getCurrentUser } from '../utils/auth';
import './RaiseTicket.css';

const RaiseTicket = () => {
  const [formData, setFormData] = useState({
    subject: '',
    description: '',
    category: 'TECHNICAL',
    priority: 'MEDIUM',
    userPhone: ''
  });
  
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  const [ticketNumber, setTicketNumber] = useState('');

  // Auto-populate phone number on component mount
  useEffect(() => {
    const user = getCurrentUser();
    if (user && user.phoneNumber) {
      setFormData(prev => ({
        ...prev,
        userPhone: user.phoneNumber
      }));
    }
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess(false);

    try {
      const ticket = await ticketApi.createTicket(formData);
      
      setTicketNumber(ticket.ticketNumber);
      setSuccess(true);
      
      // Reset form
      setFormData({
        subject: '',
        description: '',
        category: 'TECHNICAL',
        priority: 'MEDIUM',
        userPhone: getCurrentUser()?.phoneNumber || ''
      });

      // Show success message
      alert(`✅ Ticket created successfully!\n\nTicket Number: ${ticket.ticketNumber}\n\nYou will receive email and SMS confirmation.`);
      
    } catch (err) {
      console.error('Error creating ticket:', err);
      setError(err.response?.data?.message || 'Failed to create ticket. Please try again.');
    } finally {
      s