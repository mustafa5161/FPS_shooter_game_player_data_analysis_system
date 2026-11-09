-- =========================================================================================
-- DOSYA: 03_Otomasyon.sql
-- AMACI: Loglardan gelen verilere göre otomatik cezalandırma (Trigger) ve indeksler.
-- =========================================================================================

-- PERFORMANS İÇİN İNDEKSLER
CREATE NONCLUSTERED INDEX IX_Players_HWID ON Players(hwid);
CREATE NONCLUSTERED INDEX IX_Players_IP ON Players(ip_address);
CREATE NONCLUSTERED INDEX IX_AntiCheatLogs_Category ON AntiCheat_Logs(cheat_category, cheat_type);

GO

-- OTOMATİK CEZALANDIRMA TETİKLEYİCİSİ (TRIGGER)
CREATE TRIGGER trg_AutoBan_TrustFactor 
ON AntiCheat_Logs
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;

    -- 1. KESİN HİLE (Severity 10): Anında Kalıcı Ban ve Sicil Kaydı
    UPDATE p
    SET p.is_banned = 1,
        p.ban_date = SYSUTCDATETIME(),
        p.ban_reason = 'Auto-Ban: ' + i.cheat_type,
        p.trust_factor = 0
    FROM Players p
    INNER JOIN inserted i ON p.player_id = i.player_id
    WHERE i.severity_level >= 10 AND p.is_banned = 0;

    INSERT INTO Ban_History (player_id, ban_type, reason, issued_by, start_date, is_active)
    SELECT i.player_id, 'Permanent', 'Severity 10 Violation: ' + i.cheat_type, 'Auto-System', SYSUTCDATETIME(), 1
    FROM inserted i
    WHERE i.severity_level >= 10;

    -- 2. ŞÜPHELİ HAREKET (Severity 8-9): Güven Faktörünü Düşür
    UPDATE p
    SET p.trust_factor = CASE 
                            WHEN p.trust_factor - 25 < 0 THEN 0 
                            ELSE p.trust_factor - 25 
                         END
    FROM Players p
    INNER JOIN inserted i ON p.player_id = i.player_id
    WHERE i.severity_level IN (8, 9) AND p.is_banned = 0;
END;
GO