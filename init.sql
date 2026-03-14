-- RevPay Microservices - Database Initialization
-- This file runs automatically when MySQL container starts for the first time.

CREATE DATABASE IF NOT EXISTS auth_db;
CREATE DATABASE IF NOT EXISTS user_db;
CREATE DATABASE IF NOT EXISTS wallet_db;
CREATE DATABASE IF NOT EXISTS transaction_db;
CREATE DATABASE IF NOT EXISTS invoice_loan_db;
CREATE DATABASE IF NOT EXISTS notification_db;

-- Grant all privileges to the app user on each database
GRANT ALL PRIVILEGES ON auth_db.*         TO 'revpay_user'@'%';
GRANT ALL PRIVILEGES ON user_db.*         TO 'revpay_user'@'%';
GRANT ALL PRIVILEGES ON wallet_db.*       TO 'revpay_user'@'%';
GRANT ALL PRIVILEGES ON transaction_db.*  TO 'revpay_user'@'%';
GRANT ALL PRIVILEGES ON invoice_loan_db.* TO 'revpay_user'@'%';
GRANT ALL PRIVILEGES ON notification_db.* TO 'revpay_user'@'%';

FLUSH PRIVILEGES;
