-- =============================================
-- TERA TAILORING - SIMPLIFIED DATABASE SCHEMA
-- =============================================

-- 1. Users Table (for both consumers and tailors)
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type ENUM('consumer', 'tailor') NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Products Table
CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(255),
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Cart Table
CREATE TABLE IF NOT EXISTS cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 4. Orders Table
CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'completed', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 5. Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 6. Bidding Table
CREATE TABLE IF NOT EXISTS bidding (
    bid_id INT PRIMARY KEY AUTO_INCREMENT,
    tailor_id INT NOT NULL,
    product_id INT NOT NULL,
    bid_amount DECIMAL(10,2) NOT NULL,
    status ENUM('active', 'accepted', 'rejected') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tailor_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sample Data
INSERT INTO users (username, email, password, user_type, first_name, last_name, phone) VALUES
('john_doe', 'john@example.com', 'password123', 'consumer', 'John', 'Doe', '1234567890'),
('jane_smith', 'jane@example.com', 'password456', 'consumer', 'Jane', 'Smith', '0987654321'),
('tailor_mike', 'mike@example.com', 'password789', 'tailor', 'Mike', 'Johnson', '1112223333');

INSERT INTO products (name, description, price, category) VALUES
('Formal Suit', 'Elegant formal suit for special occasions', 299.99, 'Formal Wear'),
('Casual Shirt', 'Comfortable casual shirt for everyday wear', 49.99, 'Casual Wear'),
('Designer Dress', 'Elegant designer dress for special events', 199.99, 'Formal Wear');

-- Verification
SELECT 'Tables created successfully!' as Message;
SHOW TABLES;
DESCRIBE users;
DESCRIBE products;
