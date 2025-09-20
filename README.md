## SQL: зміни та оптимізація таблиці `pv`

### Фінальний варіант таблиці

```sql
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
   KEY idx_user_date (user_id, created_at),
   UNIQUE KEY uniq_user_url_time (user_id, url(255), created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

## Пояснення змін у SQL

### Типи колонок
- **BIGINT UNSIGNED** для `id` і `user_id` → підтримка мільйонів рядків.
- **DATETIME** для `created_at` → швидкі запити по датах та діапазонах.
- **CHAR(2)** для `country`, **ENUM** для `device` → економія пам’яті та стандартизація.
- **INT UNSIGNED** для `duration_ms` → неможливість негативних значень.

### Індекси
- `idx_url_country_date` та `idx_user_date` → прискорюють вибірку та агрегацію (типові аналітичні запити).
- **UNIQUE KEY `uniq_user_url_time`** → запобігає дублюванню одного і того ж перегляду користувачем.

### URL
- Залишено як `VARCHAR(255)` для економії пам’яті та підтримки основних запитів.

### Загальна мета змін
- Мінімізація дублювання та економія ресурсів.
- Підтримка мільйонів рядків з високою швидкістю аналітичних запитів.
- Готовність до batch insert або `LOAD DATA INFILE` для великих обсягів даних.

### PHP

- Переписано скрипт у **клас `ReportApp`** з методами для обробки, підрахунку та запису звітів.  
- **Валідація:** враховуються лише записи зі `status="paid"` і `amount>0`.  
- **Підрахунок:** загальна сума (`total_paid`), кількість валідних замовлень та середнє (`avg`).  
- **Безпечний запис у файл:** використання тимчасового файлу та атомарного `rename()`.  
- **Логування:** всі важливі події та помилки записуються у `report.log`.  
- **Консольний вивід:** при запуску скрипта відображається кількість валідних замовлень, total_paid та avg, що дозволяє швидко перевіряти роботу звіту.  

**Мета:** підвищення надійності та безпечності обробки даних, забезпечення логування та контроль над звітами без втручання користувача.
