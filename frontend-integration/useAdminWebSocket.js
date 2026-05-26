import { useEffect, useRef, useState } from 'react';
import SockJS from 'sockjs-client';
import { Stomp } from '@stomp/stompjs';

/**
 * Custom hook for admin dashboard WebSocket connection
 * Automatically connects and subscribes to dashboard updates
 * 
 * @param {Function} onUpdate - Callback when dashboard update received
 * @returns {Object} { connected: boolean }
 */
export const useAdminWebSocket = (onUpdate) => {
  const [connected, setConnected] = useState(false);
  const stompClientRef = useRef(null);
  
  useEffect(() => {
    // Get WebSocket URL from environment or use default
    const wsUrl = import.meta.env.VITE_WS_URL || 'http://localhost:8080/ws';
    
    // Create WebSocket connection
    const socket = new SockJS(wsUrl);
    const stompClient = Stomp.over(socket);
    
    // Disable debug logs (optional)
    stompClient.debug = () => {};
    
    // Connect to WebSocket
    stompClient.connect(
      {},
      () => {
        console.log('✅ Connected to WebSocket');
        setConnected(true);
        
        // Subscribe to admin dashboard updates
        stompClient.subscribe('/topic/admin/dashboard', (message) => {
          try {
            const event = JSON.parse(message.body);
            console.log('📊 Dashboard update received:', event);
            
            // Call the callback function with the event
            if (onUpdate) {
              onUpdate(event);
            }
          } catch (error) {
            console.error('Failed to parse WebSocket message:', error);
          }
        });
      },
      (error) => {
        console.error('❌ WebSocket connection error:', error);
        setConnected(false);
      }
    );
    
    stompClientRef.current = stompClient;
    
    // Cleanup on unmount
    return () => {
      if (stompClient && stompClient.connected) {
        stompClient.disconnect(() => {
          console.log('🔌 Disconnected from WebSocket');
        });
      }
    };
  }, [onUpdate]);
  
  return { connected };
};
