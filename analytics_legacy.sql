-- ПОГАНА СХЕМА (стартова)
CREATE DATABASE IF NOT EXISTS analytics_legacy;
USE analytics_legacy;

DROP TABLE IF EXISTS pv;
CREATE TABLE pv (
   id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
   user_id BIGINT UNSIGNED NOT NULL,
   url VARCHAR(255) NOT NULL,
   country CHAR(2) NOT NULL,
   device ENUM('desktop','mobile','tablet') NOT NULL,
   created_at DATETIME NOT NULL,
   duration_ms INT UNSIGNED NOT NULL,
   PRIMARY KEY (id),
   KEY idx_url_country_date (url, country, created_at),
   KEY idx_user_date (user_id, created_at)
) ENGINE=InnoDB;

-- Вибірка топ 5 сторінок за унікальними користувачами у діапазоні дат і країні.
SELECT url, COUNT(DISTINCT user_id) AS uniq_users
FROM pv
WHERE country = 'UA'
  AND created_at BETWEEN '2025-09-15 00:00:00' AND '2025-09-17 23:59:59'
GROUP BY url
ORDER BY uniq_users DESC
    LIMIT 5;


-- Видозмінений запит, до 1000 рядків
START TRANSACTION;

INSERT INTO pv (user_id, url, country, device, created_at, duration_ms) VALUES
    (1,'/home','UA','desktop','2025-09-15 10:11:12',350),
    (2,'/product/42','UA','mobile','2025-09-15 11:01:02',900),
    (3,'/product/7','PL','tablet','2025-09-15 12:30:45',420),
    (1,'/cart','UA','mobile','2025-09-15 13:21:00',150),
    (4,'/checkout','DE','desktop','2025-09-15 14:10:33',200),
    (5,'/home','UA','desktop','2025-09-16 08:05:55',300),
    (6,'/product/13','UA','mobile','2025-09-16 09:21:10',600),
    (7,'/product/42','PL','desktop','2025-09-16 10:11:11',480),
    (8,'/home','DE','tablet','2025-09-16 11:45:25',230),
    (9,'/product/99','UA','mobile','2025-09-16 12:33:00',550),
    (10,'/search?q=laptop','UA','desktop','2025-09-16 13:55:40',400),
    (11,'/product/7','UA','mobile','2025-09-16 14:01:12',250),
    (12,'/checkout','PL','desktop','2025-09-16 15:23:50',320),
    (13,'/product/42','UA','tablet','2025-09-17 09:11:00',410),
    (14,'/home','UA','mobile','2025-09-17 10:20:05',180),
    (15,'/cart','DE','desktop','2025-09-17 11:40:22',270),
    (16,'/product/88','UA','mobile','2025-09-17 12:00:00',500),
    (17,'/checkout','PL','tablet','2025-09-17 12:15:15',350),
    (18,'/product/7','UA','desktop','2025-09-17 13:45:33',260),
    (19,'/search?q=phone','UA','mobile','2025-09-17 14:50:05',700),
    (20,'/home','DE','desktop','2025-09-17 15:05:00',310);

COMMIT;

-- Приклад LOAD DATA, в разі якщо даних дуже багато
    LOAD DATA INFILE '/pv.csv'
INTO TABLE pv
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
(user_id, url, country, device, created_at, duration_ms);
