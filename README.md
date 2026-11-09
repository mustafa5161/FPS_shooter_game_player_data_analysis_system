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

## Veritabanı ilişkilerini görsel olarak incelemek mermaid.live aşağıdaki kodu baştaki 3 tırnak harici yapıştırın:

'''
erDiagram
    Players {
        int player_id PK
        nvarchar username
        nvarchar hwid
        varchar ip_address
        datetime2 account_created
        int trust_factor
        bit is_banned
        datetime2 ban_date
        nvarchar ban_reason
    }

    AC_Blacklisted_Signatures {
        int signature_id PK
        varchar threat_type
        varchar identifier_value
        datetime2 added_date
        int risk_level
    }

    Ban_History {
        int ban_id PK
        int player_id FK
        varchar ban_type
        nvarchar reason
        varchar issued_by
        datetime2 start_date
        datetime2 end_date
        bit is_active
    }

    Manual_Review_Cases {
        int case_id PK
        int suspect_player_id FK
        int reviewer_id
        varchar case_status
        varchar verdict
        datetime2 created_at
        datetime2 resolved_at
    }

    Matches {
        int match_id PK
        nvarchar map_name
        varchar server_region
        datetime2 start_time
        int duration_seconds
    }

    Player_Hardware_Logs {
        bigint log_id PK
        int player_id FK
        nvarchar cpu_serial
        nvarchar motherboard_serial
        varchar mac_address
        datetime2 login_time
    }

    Player_Sessions {
        bigint session_id PK
        int player_id FK
        varchar ip_address
        varchar country_code
        bit vpn_detected
        datetime2 login_time
    }

    Player_Match_Stats {
        bigint stat_id PK
        int match_id FK
        int player_id FK
        int kills
        int headshots
        float distance_traveled
        float average_time_to_kill
        float sensitivity
        int fov
        int resolution_x
        int resolution_y
    }

    Combat_Kill_Events {
        bigint event_id PK
        int match_id FK
        int attacker_id
        int victim_id
        varchar hitbox_area
        float distance_meters
        int event_time_in_match
    }

    Player_Reports {
        bigint report_id PK
        int reporter_id FK
        int reported_id FK
        int match_id FK
        report_reason NVARCHAR
        datetime2 report_time
    }

    AntiCheat_Logs {
        bigint log_id PK
        int player_id FK
        int match_id FK
        varchar cheat_category
        varchar cheat_type
        nvarchar event_details
        int severity_level
        datetime2 client_timestamp
    }

    Cheat_Risk_Rules {
        int rule_id PK
        varchar cheat_type UK
        int assigned_severity
        nvarchar description
    }

    %% İlişkiler (Foreign Key Bağlantıları)
    Players ||--o{ Ban_History : "sahiptir"
    Players ||--o{ Manual_Review_Cases : "incelenir"
    Players ||--o{ Player_Hardware_Logs : "kaydeder"
    Players ||--o{ Player_Sessions : "oturumu_aclar"
    Players ||--o{ Player_Match_Stats : "oynar"
    Matches ||--o{ Player_Match_Stats : "kapsar"
    Matches ||--o{ Combat_Kill_Events : "icerir"
    Matches ||--o{ Player_Reports : "raporlanir"
    Players ||--o{ Player_Reports : "eder (reporter)"
    Players ||--o{ Player_Reports : "edilir (reported)"
    Players ||--o{ AntiCheat_Logs : "uretir"
    Matches ||--o{ AntiCheat_Logs : "kaydedilir"