-- =========================================================================================
-- DOSYA: 04_Risk_Matrisi.sql
-- AMACI: Hile türlerinin cezalandırma puanlarını (Risk Matrisi) tutmak ve prosedür eklemek.
-- =========================================================================================

-- 1. RİSK MATRİSİ TABLOSU
CREATE TABLE Cheat_Risk_Rules (
    rule_id INT IDENTITY(1,1) PRIMARY KEY,
    cheat_type VARCHAR(50) NOT NULL UNIQUE,
    assigned_severity INT NOT NULL, -- Bu hile kaç puan ceza almalı?
    description NVARCHAR(255) NULL
);
GO

-- Örnek Kuralları Ekleyelim
INSERT INTO Cheat_Risk_Rules (cheat_type, assigned_severity, description) VALUES
('Memory_Injection', 10, 'Belleğe doğrudan müdahale (Kesin Ban)'),
('Spinbot', 10, 'İmkansız açısal dönüş (Kesin Ban)'),
('Aimbot_Rage', 10, 'Açık aimbot kullanımı (Kesin Ban)'),
('Macro_Suphesi', 8, 'Şüpheli hızlı tıklama/makro (Trust Factor Düşer)'),
('Speedhack', 9, 'Hız limiti aşımı (Trust Factor Düşer)');
GO

-- 2. AKILLI KAYIT PROSEDÜRÜ (Stored Procedure)
-- Sunucu sadece hile türünü söyler, puanı bu prosedür kural tablosundan otomatik bulur.
CREATE PROCEDURE sp_LogCheatEvent
    @p_player_id INT,
    @p_cheat_category VARCHAR(30),
    @p_cheat_type VARCHAR(50),
    @p_match_id INT = NULL,
    @p_event_details NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @v_severity INT;

    -- Kural tablosundan bu hilenin ceza puanını bul (Bulunamazsa varsayılan 1 puan ver)
    SELECT @v_severity = ISNULL(assigned_severity, 1)
    FROM Cheat_Risk_Rules
    WHERE cheat_type = @p_cheat_type;

    -- Log tablosuna kaydı at (Bu kayıt atıldığı an 03_Otomasyon'daki Trigger çalışacak!)
    INSERT INTO AntiCheat_Logs (
        player_id, 
        match_id, 
        cheat_category, 
        cheat_type, 
        event_details, 
        severity_level, 
        client_timestamp
    )
    VALUES (
        @p_player_id, 
        @p_match_id, 
        @p_cheat_category, 
        @p_cheat_type, 
        @p_event_details, 
        @v_severity, 
        SYSUTCDATETIME()
    );
END;
GO