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

## Veritabanı İlişki Şeması (ER Diagram)

Aşağıdaki şemada projemizin tüm tabloları, sütunları ve aralarındaki ilişkiler gösterilmektedir:

```mermaid
erDiagram
    Players {
        int player_id PK
        nvarchar username
        nvarchar hwid
        varchar ip_address
        int trust_factor
        bit is_banned
    }

    Player_Hardware_Logs {
        bigint log_id PK
        int player_id FK
        nvarchar cpu_serial
        nvarchar motherboard_serial
    }

    Player_Sessions {
        bigint session_id PK
        int player_id FK
        varchar ip_address
        bit vpn_detected
    }

    Matches {
        int match_id PK
        nvarchar map_name
        varchar server_region
    }

    Player_Match_Stats {
        bigint stat_id PK
        int match_id FK
        int player_id FK
        int kills
        int headshots
    }

    Combat_Kill_Events {
        bigint event_id PK
        int match_id FK
        int attacker_id
        int victim_id
        varchar hitbox_area
    }

    Player_Reports {
        bigint report_id PK
        int reporter_id FK
        int reported_id FK
        int match_id FK
    }

    Manual_Review_Cases {
        int case_id PK
        int suspect_player_id FK
        varchar case_status
    }

    AntiCheat_Logs {
        bigint log_id PK
        int player_id FK
        int match_id FK
        varchar cheat_category
        varchar cheat_type
        int severity_level
    }

    AC_Blacklisted_Signatures {
        int signature_id PK
        varchar threat_type
        varchar identifier_value
    }

    Ban_History {
        int ban_id PK
        int player_id FK
        varchar ban_type
        nvarchar reason
    }

    Cheat_Risk_Rules {
        int rule_id PK
        varchar cheat_type
        int assigned_severity
    }

    Players ||--o{ Player_Hardware_Logs : "has"
    Players ||--o{ Player_Sessions : "has"
    Players ||--o{ Player_Match_Stats : "plays"
    Players ||--o{ Combat_Kill_Events : "attacker"
    Players ||--o{ Player_Reports : "reports"
    Players ||--o{ Manual_Review_Cases : "suspect"
    Players ||--o{ AntiCheat_Logs : "generates"
    Players ||--o{ Ban_History : "receives"

    Matches ||--o{ Player_Match_Stats : "contains"
    Matches ||--o{ Combat_Kill_Events : "records"
    Matches ||--o{ Player_Reports : "includes"
    Matches ||--o{ AntiCheat_Logs : "occurs_in"