# FPS Hile Tespiti Veritabanı Projesi

Bu proje, MSSQL (T-SQL) kullanarak FPS oyunlarındaki hileleri tespit eden, oyuncu istatistiklerini izleyen ve otomatik ceza (ban) uygulayan bir veritabanı projesidir.

## Dosya Yapısı

Veritabanını kurmak için SQL dosyalarını SSMS üzerinde sırasıyla çalıştırın:

0. `00_CREATE_DATABASE.sql`: Database'yi oluşturur.
1. `01_Yonetim_ve_Ceza.sql`: Oyuncu profillerini, ban sicilini ve karalisteyi oluşturur.
2. `02_Hile_Tespiti.sql`: Maç istatistiklerini, donanım loglarını ve hile log tablolarını oluşturur.
3. `03_Otomasyon.sql`: Log tablosuna gelen verileri kontrol edip otomatik ban atan Trigger'ı kurar.
4. `04_Risk_Matrisi.sql`: Hile türlerinin puanlarını tutan kural tablosunu ve kayıt prosedürünü ekler.

## Nasıl Test Edilir?

Veritabanı kurulduktan sonra aşağıdaki örnek kodları çalıştırarak sistemi test edebilirsiniz:

```sql
-- 1. Test oyuncusu ekle
INSERT INTO Players (username, hwid, ip_address) 
VALUES ('TestOyuncusu', 'HWID_123', '192.168.1.100');

-- 2. Hile logu gönder (Bellek enjeksiyonu cezası 10 puandır ve otomatik banlar)
EXEC sp_LogCheatEvent 
    @p_player_id = 1, 
    @p_cheat_category = 'Nisan', 
    @p_cheat_type = 'Memory_Injection';

-- 3. Sonucu kontrol et
SELECT username, trust_factor, is_banned, ban_reason FROM Players;
SELECT * FROM Ban_History;