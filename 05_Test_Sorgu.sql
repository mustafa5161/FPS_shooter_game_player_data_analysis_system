-- 1. Test oyuncusu ekle
INSERT INTO Players (username, hwid, ip_address) 
VALUES ('HileciMehmet', 'HWID_TEST_999', '192.168.1.100');

-- 2. Akıllı prosedür ile hile logu gönder (Puanı manuel yazmıyoruz, sistem kendisi bulup banlıyor)
EXEC sp_LogCheatEvent 
    @p_player_id = 1, 
    @p_cheat_category = 'Nisan', 
    @p_cheat_type = 'Memory_Injection';

-- 3. Sonucu kontrol et (Mehmet banlanmış mı?)
SELECT username, trust_factor, is_banned, ban_reason FROM Players;
SELECT * FROM Ban_History;