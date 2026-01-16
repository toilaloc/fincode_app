-- create test database
CREATE DATABASE IF NOT EXISTS fincode_test
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- grant permissions
GRANT ALL PRIVILEGES ON fincode_development.* TO 'fincode_user'@'%';
GRANT ALL PRIVILEGES ON fincode_test.* TO 'fincode_user'@'%';

FLUSH PRIVILEGES;
