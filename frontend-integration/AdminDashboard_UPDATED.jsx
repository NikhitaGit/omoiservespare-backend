import React, { useEffect, useMemo, useState, useCallback } from "react";
import { getDashboard } from "../api/adminDashboardApi";
import { useAdminWebSocket } from "../hooks/useAdminWebSocket";
import "../styles/adminDashboard.css";

/* ✅ Trending item images from src/assets */
import teaImg from "../assets/Tea.webp";
import idliImg from "../assets/Idli.jpg";
import coffeeImg from "../assets/Coffee.webp";
import vegThaliImg from "../assets/Veg-Thali.jpg";
import dosaImg from "../assets/IMG_0862.webp";

/* ✅ Map item name -> image */
const ITEM_IMAGES = {
  Tea: teaImg,
  Idli: idliImg,
  Coffee: coffeeImg,
  "Veg Thali": vegThaliImg,
  Dosa: dosaImg,
};

const RANGE_OPTIONS = [
  { key: "today", label: "Today" },
  { key: "week", label: "This Week" },
  { key: "15d", label: "Last 15 Days" },
  { key: "month", label: "This Month" },
  { key: "year", label: "This Year" },
];

function formatINR(n) {
  return `₹${Math.round(n).toLocaleString("en-IN")}`;
}

/* ========================= Small SVG components ========================= */
function Ring({ value, max = 100, size = 44, stroke = 7, className = "" }) {
  const v = Math.max(0, Math.min(value, max));
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const p = max === 0 ? 0 : v / max;
  const dash = c * p;
  
  return (
    <svg
      className={`ring ${className}`}
      width={size}
      height={size}
      viewBox={`0 0 ${size} ${size}`}
      aria-hidden="true"
    >
      <circle
        className="ringTrack"
        cx={size / 2}
        cy={size / 2}
        r={r}
        strokeWidth={stroke}
        fill="none"
      />
      <circle
        className="ringValue"
        cx={size / 2}
        cy={size / 2}
        r={r}
        strokeWidth={stroke}
        fill="none"
        strokeDasharray={`${dash} ${c - dash}`}
        strokeLinecap="round"
        transform={`rotate(-90 ${size / 2} ${size / 2})`}
      />
    </svg>
  );
}

function AreaChart({ data }) {
  const W = 640;
  const H = 240;
  const P = 22;
  
  const vals = data.map((d) => d.sales);
  const max = Math.max(...vals, 1);
  const xStep = data.length <= 1 ? 0 : (W - 2 * P) / (data.length - 1);
  
  const pts = data.map((d, i) => {
    const x = P + i * xStep;
    const y = H - P - (d.sales / max) * (H - 2 * P);
    return { x, y, label: d.label, value: d.sales };
  });
  
  const line = pts.map((p) => `${p.x},${p.y}`).join(" ");
  const area = `${P},${H - P} ${line} ${P + xStep * (pts.length - 1)},${H - P}`;
  
  return (
    <div className="areaChart">
      <svg viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none">
        <line className="gridLine" x1={P} y1={H - P} x2={W - P} y2={H - P} />
        <line className="gridLine" x1={P} y1={P} x2={P} y2={H - P} />
        <polygon className="areaFill" points={area} />
        <polyline className="areaLine" points={line} />
        {pts.map((p, idx) => (
          <g key={idx}>
            <circle className="areaDot" cx={p.x} cy={p.y} r="4" />
          </g>
        ))}
      </svg>
      <div className="areaXAxis">
        {data.map((d, idx) => (
          <span key={idx}>{d.label}</span>
        ))}
      </div>
    </div>
  );
}

function AdminDashboard() {
  const [range, setRange] = useState("week");
  const [dashboard, setDashboard] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Fetch dashboard data from backend API
  const fetchDashboard = useCallback(async (selectedRange) => {
    setLoading(true);
    setError(null);
    
    try {
      const data = await getDashboard(selectedRange);
      setDashboard(data);
      console.log('✅ Dashboard data loaded:', data);
    } catch (err) {
      console.error('❌ Failed to load dashboard:', err);
      setError('Failed to load dashboard. Please try again.');
      
      // Check if it's an auth error
      if (err.response?.status === 401) {
        setError('Please login to view the dashboard.');
      }
    } finally {
      setLoading(false);
    }
  }, []);
  
  // Handle WebSocket updates
  const handleWebSocketUpdate = useCallback((event) => {
    console.log('🔄 Real-time update:', event);
    
    if (event.type === 'ORDER_COMPLETED') {
      // Update KPIs in real-time
      setDashboard(prev => {
        if (!prev) return prev;
        
        return {
          ...prev,
          kpis: {
            ...prev.kpis,
            todayRevenue: prev.kpis.todayRevenue + (event.amount || 0),
            totalOrders: prev.kpis.totalOrders + 1,
          }
        };
      });
    }
  }, []);
  
  // Connect to WebSocket for real-time updates
  const { connected } = useAdminWebSocket(handleWebSocketUpdate);
  
  // Initial load
  useEffect(() => {
    fetchDashboard(range);
  }, [range, fetchDashboard]);
  
  // Loading state
  if (loading) {
    return (
      <div className="adm2">
        <main className="adm2Main">
          <div style={{ textAlign: 'center', padding: '50px' }}>
            <h2>Loading dashboard...</h2>
          </div>
        </main>
      </div>
    );
  }
  
  // Error state
  if (error) {
    return (
      <div className="adm2">
        <main className="adm2Main">
          <div style={{ textAlign: 'center', padding: '50px', color: 'red' }}>
            <h2>Error</h2>
            <p>{error}</p>
            <button onClick={() => fetchDashboard(range)}>Retry</button>
          </div>
        </main>
      </div>
    );
  }
  
  // No data state
  if (!dashboard) {
    return (
      <div className="adm2">
        <main className="adm2Main">
          <div style={{ textAlign: 'center', padding: '50px' }}>
            <h2>No data available</h2>
          </div>
        </main>
      </div>
    );
  }
  
  // Main render
  return (
    <div className="adm2 noSidebar">
      <main className="adm2Main">
        {/* Topbar */}
        <div className="adm2Topbar">
          <div>
            <h1 className="adm2Title">Admin Dashboard</h1>
            <p className="adm2Sub">
              Revenue, orders, trending items and performance overview.
              {connected && <span style={{ color: '#4ade80', marginLeft: '10px' }}>● Live</span>}
            </p>
          </div>
          <div className="adm2TopbarRight">
            <select 
              value={range} 
              onChange={(e) => setRange(e.target.value)} 
              className="adm2Select"
            >
              {RANGE_OPTIONS.map((r) => (
                <option key={r.key} value={r.key}>{r.label}</option>
              ))}
            </select>
          </div>
        </div>

        {/* KPI Cards */}
        <section className="adm2Kpis">
          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Today Revenue</div>
                <div className="kpiBig">{formatINR(dashboard.kpis.todayRevenue)}</div>
              </div>
              <Ring value={dashboard.kpis.todayRevenue} max={2000} className="ringOrange" />
            </div>
            <div className="kpiFoot">
              {dashboard.kpis.todayRevenueGrowth > 0 && (
                <span>↑ {dashboard.kpis.todayRevenueGrowth.toFixed(1)}% growth</span>
              )}
            </div>
          </div>

          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Total Revenue</div>
                <div className="kpiBig">{formatINR(dashboard.kpis.totalRevenue)}</div>
              </div>
              <Ring value={dashboard.kpis.totalRevenue} max={10000} className="ringBlue" />
            </div>
            <div className="kpiFoot">Selected range</div>
          </div>

          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Total Orders</div>
                <div className="kpiBig">{dashboard.kpis.totalOrders}</div>
              </div>
              <Ring value={dashboard.kpis.totalOrders} max={100} className="ringGreen" />
            </div>
            <div className="kpiFoot">Paid orders count</div>
          </div>

          <div className="kpiCard">
            <div className="kpiHead">
              <div>
                <div className="kpiLabel">Customers</div>
                <div className="kpiBig">{dashboard.kpis.customers}</div>
              </div>
              <Ring value={dashboard.kpis.customers} max={50} className="ringPurple" />
            </div>
            <div className="kpiFoot">Unique in range</div>
          </div>
        </section>

        {/* Main Grid */}
        <section className="adm2Grid">
          {/* Left Column */}
          <div className="adm2Col">
            {/* Trending Items */}
            <div className="panel">
              <div className="panelTop">
                <h3>Trending Items</h3>
                <span className="pill2">Top selling</span>
              </div>
              <div className="trendList">
                {dashboard.trendingItems.length === 0 ? (
                  <div className="empty">No trending items in this range.</div>
                ) : (
                  dashboard.trendingItems.map((item, idx) => {
                    const imgSrc = ITEM_IMAGES[item.name];
                    return (
                      <div className="trendRow" key={item.itemId}>
                        <div className="rank">#{idx + 1}</div>
                        <div className="trendThumb">
                          {imgSrc ? (
                            <img src={imgSrc} alt={item.name} />
                          ) : (
                            item.name?.[0]?.toUpperCase() || "🍽"
                          )}
                        </div>
                        <div className="trendMeta">
                          <div className="trendName">{item.name}</div>
                          <div className="trendSub">
                            {formatINR(item.revenue)} • {item.quantitySold} sold
                          </div>
                        </div>
                        <div className={`trendChip ${item.growthPercent >= 0 ? 'up' : 'down'}`}>
                          {item.growthPercent >= 0 ? '↑' : '↓'}
                          {Math.abs(item.growthPercent).toFixed(1)}%
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>

            {/* Revenue Chart */}
            <div className="panel">
              <div className="panelTop">
                <h3>Revenue Overview</h3>
                <span className="muted2">Line + area chart</span>
              </div>
              {dashboard.revenueSeries.length === 0 ? (
                <div className="empty">No data for this range.</div>
              ) : (
                <AreaChart data={dashboard.revenueSeries} />
              )}
            </div>

            {/* Top vs Least Sold */}
            <div className="panel">
              <div className="panelTop">
                <h3>Top vs Least Sold (Today)</h3>
                <span className="muted2">Quick check</span>
              </div>
              <div className="twoTables">
                <div className="miniTable">
                  <div className="miniHead">
                    <span>Top Sold</span>
                    <span className="pill2">Qty</span>
                  </div>
                  {dashboard.topSoldToday.map((item) => (
                    <div className="miniRow" key={item.itemId}>
                      <span className="miniName">{item.name}</span>
                      <span className="miniNum">{item.qty}</span>
                    </div>
                  ))}
                </div>
                <div className="miniTable">
                  <div className="miniHead">
                    <span>Least Sold</span>
                    <span className="pill2 ghost">0 included</span>
                  </div>
                  {dashboard.leastSoldToday.map((item) => (
                    <div className="miniRow" key={item.itemId}>
                      <span className="miniName">{item.name}</span>
                      <span className="miniNum">{item.qty}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="adm2Col right">
            {/* Category Split */}
            <div className="panel">
              <div className="panelTop">
                <h3>Category Split</h3>
                <span className="muted2">Menu distribution</span>
              </div>
              <div className="donutBox">
                <div className="donut" style={{
                  background: `conic-gradient(
                    var(--c1) 0 ${dashboard.categoryDistribution[0]?.percentage || 0}%,
                    var(--c2) ${dashboard.categoryDistribution[0]?.percentage || 0}% ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0)}%,
                    var(--c3) ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0)}% ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0) + (dashboard.categoryDistribution[2]?.percentage || 0)}%,
                    var(--c4) ${(dashboard.categoryDistribution[0]?.percentage || 0) + (dashboard.categoryDistribution[1]?.percentage || 0) + (dashboard.categoryDistribution[2]?.percentage || 0)}% 100%
                  )`
                }}>
                  <div className="donutHole">
                    <div className="donutBig">
                      {dashboard.categoryDistribution.reduce((sum, cat) => sum + cat.count, 0)}
                    </div>
                    <div className="donutSub">Items</div>
                  </div>
                </div>
                <div className="legend">
                  {dashboard.categoryDistribution.map((cat, idx) => (
                    <div className="legRow" key={cat.category}>
                      <span className={`dot dot${idx + 1}`} />
                      <span className="legName">{cat.category}</span>
                      <span className="legVal">{Math.round(cat.percentage)}%</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Sessions */}
            <div className="panel">
              <div className="panelTop">
                <h3>Total Sessions</h3>
                <span className="muted2">Traffic</span>
              </div>
              <div className="statBig">{dashboard.sessions.totalSessions}</div>
              <div className="statSub">Live: {dashboard.sessions.liveVisitors} visitors</div>
            </div>

            {/* Customer Rate */}
            <div className="panel">
              <div className="panelTop">
                <h3>Customer Rate</h3>
                <span className="muted2">Repeat / retention</span>
              </div>
              <div className="rateRow">
                <div className="statBig">{dashboard.customerRate.returningPercent.toFixed(1)}%</div>
                <div className="rateBars">
                  <div className="ratePill">
                    <span className="dot dot2" /> Returning
                  </div>
                  <div className="ratePill">
                    <span className="dot dot1" /> First time
                  </div>
                </div>
              </div>
            </div>

            {/* Insights */}
            {dashboard.insights && dashboard.insights.length > 0 && (
              <div className="panel">
                <div className="panelTop">
                  <h3>Insights</h3>
                  <span className="muted2">AI-generated</span>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {dashboard.insights.map((insight, idx) => (
                    <div key={idx} style={{ 
                      padding: '10px', 
                      background: 'rgba(59, 130, 246, 0.1)', 
                      borderRadius: '8px',
                      fontSize: '14px',
                      fontWeight: '500'
                    }}>
                      💡 {insight}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </section>
      </main>
    </div>
  );
}

export default AdminDashboard;
