/**
 * Secure Token Manager
 * Provides encrypted storage and secure handling of JWT tokens
 */

class SecureTokenManager {
  constructor() {
    this.memoryToken = null;
    this.encryptionKey = this.generateEncryptionKey();
  }

  /**
   * Generate a simple encryption key based on browser fingerprint
   * Note: This is obfuscation, not true encryption. For production,
   * use a proper encryption library like crypto-js
   */
  generateEncryptionKey() {
    const fingerprint = [
      navigator.userAgent,
      navigator.language,
      new Date().getTimezoneOffset(),
      screen.width + 'x' + screen.height
    ].join('|');
    
    // Simple hash function
    let hash = 0;
    for (let i = 0; i < fingerprint.length; i++) {
      const char = fingerprint.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(36);
  }

  /**
   * Simple XOR encryption (for obfuscation)
   * For production, use crypto-js or Web Crypto API
   */
  encrypt(text) {
    if (!text) return null;
    
    const key = this.encryptionKey;
    let encrypted = '';
    
    for (let i = 0; i < text.length; i++) {
      const charCode = text.charCodeAt(i) ^ key.charCodeAt(i % key.length);
      encrypted += String.fromCharCode(charCode);
    }
    
    // Base64 encode to make it storage-safe
    return btoa(encrypted);
  }

  /**
   * Simple XOR decryption
   */
  decrypt(encrypted) {
    if (!encrypted) return null;
    
    try {
      const key = this.encryptionKey;
      const decoded = atob(encrypted);
      let decrypted = '';
      
      for (let i = 0; i < decoded.length; i++) {
        const charCode = decoded.charCodeAt(i) ^ key.charCodeAt(i % key.length);
        decrypted += String.fromCharCode(charCode);
      }
      
      return decrypted;
    } catch (error) {
      console.error('Decryption failed:', error);
      return null;
    }
  }

  /**
   * Store token securely
   */
  setToken(token) {
    if (!token) return;
    
    // Store in memory for quick access
    this.memoryToken = token;
    
    // Store encrypted version in localStorage
    const encrypted = this.encrypt(token);
    localStorage.setItem('_st', encrypted); // Obscure key name
    
    // Store token metadata (not the token itself)
    const metadata = {
      exp: this.getTokenExpiry(token),
      iat: Date.now()
    };
    localStorage.setItem('_stm', JSON.stringify(metadata));
  }

  /**
   * Get token securely
   */
  getToken() {
    // First check memory
    if (this.memoryToken) {
      if (this.isTokenValid(this.memoryToken)) {
        return this.memoryToken;
      } else {
        this.clearToken();
        return null;
      }
    }
    
    // Try to retrieve from localStorage
    const encrypted = localStorage.getItem('_st');
    if (encrypted) {
      const token = this.decrypt(encrypted);
      if (token && this.isTokenValid(token)) {
        this.memoryToken = token;
        return token;
      } else {
        this.clearToken();
        return null;
      }
    }
    
    return null;
  }

  /**
   * Check if token is valid (not expired)
   */
  isTokenValid(token) {
    if (!token) return false;
    
    try {
      const payload = this.parseJWT(token);
      if (!payload.exp) return true; // No expiry set
      
      const now = Math.floor(Date.now() / 1000);
      return payload.exp > now;
    } catch (error) {
      return false;
    }
  }

  /**
   * Parse JWT token (without verification)
   */
  parseJWT(token) {
    try {
      const base64Url = token.split('.')[1];
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
      const jsonPayload = decodeURIComponent(atob(base64).split('').map(c => {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
      }).join(''));
      
      return JSON.parse(jsonPayload);
    } catch (error) {
      console.error('Failed to parse JWT:', error);
      return {};
    }
  }

  /**
   * Get token expiry timestamp
   */
  getTokenExpiry(token) {
    const payload = this.parseJWT(token);
    return payload.exp || null;
  }

  /**
   * Get masked token for display (shows only first/last few chars)
   */
  getMaskedToken() {
    const token = this.getToken();
    if (!token) return null;
    
    if (token.length < 20) return '***';
    
    return token.substring(0, 10) + '...' + token.substring(token.length - 10);
  }

  /**
   * Clear token from all storage
   */
  clearToken() {
    this.memoryToken = null;
    localStorage.removeItem('_st');
    localStorage.removeItem('_stm');
    
    // Also clear old token keys for migration
    localStorage.removeItem('token');
    localStorage.removeItem('authToken');
    localStorage.removeItem('jwt');
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated() {
    return this.getToken() !== null;
  }

  /**
   * Get token metadata
   */
  getTokenMetadata() {
    const token = this.getToken();
    if (!token) return null;
    
    const payload = this.parseJWT(token);
    return {
      email: payload.sub || payload.email,
      accountType: payload.accountType,
      exp: payload.exp,
      iat: payload.iat,
      expiresIn: payload.exp ? Math.floor((payload.exp * 1000 - Date.now()) / 1000) : null
    };
  }

  /**
   * Migrate old tokens to secure storage
   */
  migrateOldTokens() {
    const oldKeys = ['token', 'authToken', 'jwt'];
    
    for (const key of oldKeys) {
      const oldToken = localStorage.getItem(key);
      if (oldToken && oldToken.startsWith('eyJ')) {
        console.log(`Migrating token from ${key} to secure storage`);
        this.setToken(oldToken);
        localStorage.removeItem(key);
        return true;
      }
    }
    
    return false;
  }
}

// Create singleton instance
const tokenManager = new SecureTokenManager();

// Auto-migrate old tokens on load
tokenManager.migrateOldTokens();

export default tokenManager;
