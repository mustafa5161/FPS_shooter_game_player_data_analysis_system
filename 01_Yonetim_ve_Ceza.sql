-- =========================================================================================
-- DOSYA: 01_Yonetim_ve_Ceza.sql
-- AMACI: Oyuncu kimliklerini tutmak, ban kararlarını uygulamak ve şikayetleri depolamak.
-- =========================================================================================

-- 1. OYUNCU TEMEL BİLGİLERİ (Hedef Tahtası)
CREATE TABLE Players (
    player_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    hwid NVARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    account_created DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    trust_factor INT DEFAULT 100, 
    is_banned BIT DEFAULT 0,
    ban_date DATETIME2 NULL,
    ban_reason NVARCHAR(100) NULL
);

-- 2. KARALİSTE / İMZA VERİ TABANI (Hile Ansiklopedisi)
CREATE TABLE AC_Blacklisted_Signatures (
    signature_id INT IDENTITY(1,1) PRIMARY KEY,
    threat_type VARCHAR(50), -- 'Cheat_Exe', 'Bypassed_Driver'
    identifier_value VARCHAR(255) NOT NULL, 
    added_date DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    risk_level INT DEFAULT 10
);

-- 3. CEZA GEÇMİŞİ (Sicil Kaydı)
CREATE TABLE Ban_History (
    ban_id INT IDENTITY(1,1) PRIMARY KEY,
    player_id INT NOT NULL,
    ban_type VARCHAR(20), -- 'Permanent', 'Temporary', 'Hardware'
    reason NVARCHAR(255),
    issued_by VARCHAR(50), -- 'Auto-System' veya 'Admin_Name'
    start_date DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    end_date DATETIME2 NULL, 
    is_active BIT DEFAULT 1,
    CONSTRAINT FK_BanHistory_Players FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- 4. MANUEL İNCELEME SİSTEMİ (Mahkeme)
CREATE TABLE Manual_Review_Cases (
    case_id INT IDENTITY(1,1) PRIMARY KEY,
    suspect_player_id INT NOT NULL,
    reviewer_id INT NULL, 
    case_status VARCHAR(20) DEFAULT 'Pending', 
    verdict VARCHAR(50) NULL, 
    created_at DATETIME2 DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME2 NULL,
    CONSTRAINT FK_ReviewCases_Suspect FOREIGN KEY (suspect_player_id) REFERENCES Players(player_id)
);