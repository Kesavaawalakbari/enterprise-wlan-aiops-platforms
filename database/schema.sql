-- 1. SITES TABLE
CREATE TABLE IF NOT EXISTS sites (
    site_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_name VARCHAR(100) NOT NULL UNIQUE,
    location TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. BUILDINGS TABLE
CREATE TABLE IF NOT EXISTS buildings (
    building_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID REFERENCES sites(site_id) ON DELETE CASCADE,
    building_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (site_id, building_name)
);

-- 3. FLOORS TABLE
CREATE TABLE IF NOT EXISTS floors (
    floor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID REFERENCES buildings(building_id) ON DELETE CASCADE,
    floor_name VARCHAR(50) NOT NULL,
    floor_plan_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (building_id, floor_name)
);

-- 4. AP GROUPS TABLE
CREATE TABLE IF NOT EXISTS ap_groups (
    group_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_name VARCHAR(100) NOT NULL UNIQUE,
    profile_config JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. ACCESS POINTS TABLE
CREATE TABLE IF NOT EXISTS access_points (
    ap_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    floor_id UUID REFERENCES floors(floor_id) ON DELETE SET NULL,
    group_id UUID REFERENCES ap_groups(group_id) ON DELETE SET NULL,
    ap_name VARCHAR(100) NOT NULL UNIQUE, -- Contoh: AP-JKT-A23-001
    mac_address VARCHAR(17) NOT NULL UNIQUE,
    ip_address VARCHAR(15),
    status VARCHAR(20) DEFAULT 'offline',
    hardware_model VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. MONITORING DATA TABLE
CREATE TABLE IF NOT EXISTS monitoring_data (
    monitor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ap_id UUID REFERENCES access_points(ap_id) ON DELETE CASCADE,
    cpu_usage NUMERIC(5,2),
    memory_usage NUMERIC(5,2),
    connected_clients INT DEFAULT 0,
    bandwidth_in_mbps NUMERIC(10,2) DEFAULT 0.00,
    bandwidth_out_mbps NUMERIC(10,2) DEFAULT 0.00,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. HEALTH SCORES TABLE
CREATE TABLE IF NOT EXISTS health_scores (
    health_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ap_id UUID REFERENCES access_points(ap_id) ON DELETE CASCADE,
    score INT CHECK (score BETWEEN 0 AND 100),
    factors JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. ANOMALIES TABLE
CREATE TABLE IF NOT EXISTS anomalies (
    anomaly_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ap_id UUID REFERENCES access_points(ap_id) ON DELETE CASCADE,
    anomaly_type VARCHAR(100) NOT NULL,
    confidence_score NUMERIC(5,2),
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. AI ANALYSIS TABLE
CREATE TABLE IF NOT EXISTS ai_analysis (
    analysis_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    anomaly_id UUID REFERENCES anomalies(anomaly_id) ON DELETE CASCADE,
    root_cause TEXT,
    recommendation TEXT,
    analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. ALERTS TABLE
CREATE TABLE IF NOT EXISTS alerts (
    alert_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ap_id UUID REFERENCES access_points(ap_id) ON DELETE CASCADE,
    severity VARCHAR(20) CHECK (severity IN ('critical', 'warning', 'info')),
    message TEXT NOT NULL,
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID REFERENCES alerts(alert_id) ON DELETE CASCADE,
    channel VARCHAR(50), -- email, slack, whatsapp
    status VARCHAR(20) DEFAULT 'pending',
    sent_at TIMESTAMP
);

-- 12. WORKFLOW LOGS TABLE
CREATE TABLE IF NOT EXISTS workflow_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_name VARCHAR(100) NOT NULL, -- Contoh: n8n Auto-Healing
    execution_id VARCHAR(100),
    status VARCHAR(20),
    details JSONB,
    triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. NEIGHBOR SSIDS TABLE
CREATE TABLE IF NOT EXISTS neighbor_ssids (
    neighbor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ap_id UUID REFERENCES access_points(ap_id) ON DELETE CASCADE,
    ssid VARCHAR(100),
    signal_strength_dbm INT,
    channel INT,
    scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. ROGUE ACCESS POINTS TABLE
CREATE TABLE IF NOT EXISTS rogue_access_points (
    rogue_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bssid VARCHAR(17) NOT NULL UNIQUE,
    ssid VARCHAR(100),
    classification VARCHAR(50) DEFAULT 'unclassified',
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) CHECK (role IN ('superadmin', 'network_engineer', 'viewer')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
