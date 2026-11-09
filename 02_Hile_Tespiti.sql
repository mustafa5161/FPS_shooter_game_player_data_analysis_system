-- =========================================================================================
-- DOSYA: 02_Hile_Tespiti.sql
-- AMACI: İhlalleri, anormallikleri ve oyun içi istatistikleri yakalamak. (Sensörler)
-- =========================================================================================

-- 1. MAÇ ALTYAPISI
CREATE TABLE Matches (
    match_id INT IDENTITY(1,1) PRIMARY KEY,
    map_name NVARCHAR(50) NOT NULL,
    server_region VARCHAR(20),
    start_time DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    duration_seconds INT
);

-- 2. DONANIM PARMAK İZİ LOGLARI (Spoofer Tespiti)
CREATE TABLE Player_Hardware_Logs (
    log_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    cpu_serial NVARCHAR(100),
    motherboard_serial NVARCHAR(100),
    mac_address VARCHAR(17),
    login_time DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_HardwareLogs_Players FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- 3. AĞ VE OTURUM TAKİBİ (VPN / Hesap Paylaşımı Tespiti)
CREATE TABLE Player_Sessions (
    session_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    ip_address VARCHAR(45),
    country_code VARCHAR(5),
    vpn_detected BIT DEFAULT 0,
    login_time DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Sessions_Players FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- 4. MAÇ İÇİ OYUNCU İSTATİSTİKLERİ
CREATE TABLE Player_Match_Stats (
    stat_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    kills INT DEFAULT 0,
    headshots INT DEFAULT 0,
    distance_traveled FLOAT, 
    average_time_to_kill FLOAT, 
    sensitivity FLOAT NOT NULL,
    fov INT NOT NULL,
    resolution_x INT NOT NULL,
    resolution_y INT NOT NULL,
    CONSTRAINT FK_PlayerMatchStats_Matches FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    CONSTRAINT FK_PlayerMatchStats_Players FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- 5. DETAYLI VURUŞ TELEMETRİSİ
CREATE TABLE Combat_Kill_Events (
    event_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    match_id INT NOT NULL,
    attacker_id INT NOT NULL,
    victim_id INT NOT NULL,
    hitbox_area VARCHAR(20), 
    distance_meters FLOAT,
    event_time_in_match INT, 
    CONSTRAINT FK_CombatEvents_Matches FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);

-- 6. SOSYAL TESPİT (Oyuncu Şikayetleri)
CREATE TABLE Player_Reports (
    report_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    reporter_id INT NOT NULL,
    reported_id INT NOT NULL,
    match_id INT NOT NULL,
    report_reason NVARCHAR(50) NOT NULL, 
    report_time DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_PlayerReports_Reporter FOREIGN KEY (reporter_id) REFERENCES Players(player_id),
    CONSTRAINT FK_PlayerReports_Reported FOREIGN KEY (reported_id) REFERENCES Players(player_id),
    CONSTRAINT FK_PlayerReports_Matches FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);

-- 7. MERKEZİ ANTI-CHEAT MÜDAHALE LOGLARI (JSON Destekli)
CREATE TABLE AntiCheat_Logs (
    log_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    match_id INT NULL, 
    cheat_category VARCHAR(30) NOT NULL, -- 'Gorus', 'Nisan', 'Hareket', 'Baglanti'
    cheat_type VARCHAR(50) NOT NULL, 
    event_details NVARCHAR(MAX) NULL, -- JSON formatında hile detayları
    severity_level INT DEFAULT 1, 
    client_timestamp DATETIME2 NOT NULL,
    CONSTRAINT FK_AntiCheatLogs_Players FOREIGN KEY (player_id) REFERENCES Players(player_id),
    CONSTRAINT FK_AntiCheatLogs_Matches FOREIGN KEY (match_id) REFERENCES Matches(match_id)
);