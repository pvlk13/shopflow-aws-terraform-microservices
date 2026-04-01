INSERT INTO users (name, email, password) VALUES
('Alice Johnson', 'alice@example.com', 'alice123'),
('Bob Smith', 'bob@example.com', 'bob123')
ON CONFLICT (email) DO NOTHING;

INSERT INTO orders (user_id, product_id, quantity, status)
SELECT id, 101, 2, 'PLACED' FROM users WHERE email = 'alice@example.com';

INSERT INTO orders (user_id, product_id, quantity, status)
SELECT id, 202, 1, 'SHIPPED' FROM users WHERE email = 'bob@example.com';