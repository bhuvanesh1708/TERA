-- =============================================
-- TERA TAILORING - DATABASE MANAGEMENT SYSTEM
-- =============================================

-- Section 1: Database Creation and Selection
-- =============================================
DROP DATABASE IF EXISTS tera_tailoring;
CREATE DATABASE tera_tailoring;
USE tera_tailoring;

-- Section 2: Table Creation (DDL)
-- =============================================

-- 2.1 Users and Authentication
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type ENUM('consumer', 'tailor') NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    profile_picture VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- 2.2 Products and Customization
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(255),
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_available BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT NULL
);

CREATE TABLE product_options (
    option_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    option_type ENUM('fabric', 'size', 'color') NOT NULL,
    option_value VARCHAR(50) NOT NULL,
    price_adjustment DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 2.3 Shopping and Orders
CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE cart_items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    selected_fabric VARCHAR(50),
    selected_size VARCHAR(50),
    selected_color VARCHAR(50),
    price_at_time DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'completed', 'cancelled') DEFAULT 'pending',
    shipping_address TEXT,
    payment_status ENUM('pending', 'paid', 'failed') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    selected_fabric VARCHAR(50),
    selected_size VARCHAR(50),
    selected_color VARCHAR(50),
    price_at_time DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 2.4 Bidding System
CREATE TABLE bidding (
    bid_id INT PRIMARY KEY AUTO_INCREMENT,
    tailor_id INT NOT NULL,
    product_id INT NOT NULL,
    bid_amount DECIMAL(10,2) NOT NULL,
    bid_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'accepted', 'rejected') DEFAULT 'active',
    FOREIGN KEY (tailor_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 2.5 Reviews and Ratings
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 2.6 Wishlist
CREATE TABLE wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_wishlist_item (user_id, product_id)
);

-- Section 3: Indexes
-- =============================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_cart_user ON cart(user_id);
CREATE INDEX idx_wishlist_user ON wishlist(user_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_bidding_product ON bidding(product_id);
CREATE INDEX idx_bidding_tailor ON bidding(tailor_id);

-- Section 4: Triggers
-- =============================================

-- 4.1 Update Order Total Trigger
DELIMITER //
CREATE TRIGGER update_order_total
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders o
    SET total_amount = (
        SELECT SUM(price_at_time * quantity)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE o.order_id = NEW.order_id;
END //
DELIMITER ;

-- 4.2 Update Product Rating Trigger
DELIMITER //
CREATE TRIGGER update_product_rating
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE products p
    SET rating = (
        SELECT AVG(rating)
        FROM reviews
        WHERE product_id = NEW.product_id
    )
    WHERE p.product_id = NEW.product_id;
END //
DELIMITER ;

-- Section 5: Views
-- =============================================

-- 5.1 Active Products View
CREATE VIEW active_products AS
SELECT p.*, 
       GROUP_CONCAT(DISTINCT po.option_value) as available_options
FROM products p
LEFT JOIN product_options po ON p.product_id = po.product_id
WHERE p.is_available = TRUE
GROUP BY p.product_id;

-- 5.2 User Orders View
CREATE VIEW user_orders AS
SELECT 
    o.order_id,
    u.username,
    u.email,
    o.order_date,
    o.total_amount,
    o.status,
    COUNT(oi.order_item_id) as item_count
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- 5.3 Tailor Performance View
CREATE VIEW tailor_performance AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    COUNT(DISTINCT b.bid_id) as total_bids,
    COUNT(DISTINCT CASE WHEN b.status = 'accepted' THEN b.bid_id END) as accepted_bids,
    AVG(b.bid_amount) as average_bid_amount
FROM users u
LEFT JOIN bidding b ON u.user_id = b.tailor_id
WHERE u.user_type = 'tailor'
GROUP BY u.user_id;

-- Section 6: Sample Data
-- =============================================

-- 6.1 Insert Sample Users
INSERT INTO users (username, email, password, user_type, first_name, last_name, phone, address) VALUES
('john_doe', 'john@example.com', 'password123', 'consumer', 'John', 'Doe', '1234567890', '123 Main St, City'),
('jane_smith', 'jane@example.com', 'password456', 'consumer', 'Jane', 'Smith', '0987654321', '456 Oak Ave, Town'),
('tailor_mike', 'mike@example.com', 'password789', 'tailor', 'Mike', 'Johnson', '1112223333', '789 Fashion St, City'),
('tailor_anna', 'anna@example.com', 'password012', 'tailor', 'Anna', 'Williams', '4445556666', '321 Style Ave, Town');

-- 6.2 Insert Sample Products
INSERT INTO products (name, description, base_price, category, image_url) VALUES
('Formal Suit', 'Elegant formal suit for special occasions', 299.99, 'Formal Wear', 'suit.jpg'),
('Casual Shirt', 'Comfortable casual shirt for everyday wear', 49.99, 'Casual Wear', 'shirt.jpg'),
('Designer Dress', 'Elegant designer dress for special events', 199.99, 'Formal Wear', 'dress.jpg');

-- 6.3 Insert Sample Product Options
INSERT INTO product_options (product_id, option_type, option_value, price_adjustment) VALUES
(1, 'fabric', 'Wool', 50.00),
(1, 'fabric', 'Cotton', 0.00),
(1, 'size', 'S', 0.00),
(1, 'size', 'M', 0.00),
(1, 'color', 'Black', 0.00),
(1, 'color', 'Navy', 0.00);

-- 6.4 Insert Sample Bids
INSERT INTO bidding (tailor_id, product_id, bid_amount, status) VALUES
(3, 1, 250.00, 'active'),
(4, 1, 275.00, 'active'),
(3, 2, 45.00, 'active');

-- 6.5 Insert Sample Reviews
INSERT INTO reviews (user_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Excellent quality and perfect fit!'),
(2, 1, 4, 'Very good, but a bit expensive'),
(1, 2, 5, 'Comfortable and stylish');

-- Section 7: Example Queries
-- =============================================

-- 7.1 Get User Cart
SELECT p.name, ci.quantity, ci.selected_fabric, ci.selected_size, ci.selected_color, ci.price_at_time
FROM cart_items ci
JOIN products p ON ci.product_id = p.product_id
WHERE ci.cart_id = (SELECT cart_id FROM cart WHERE user_id = 1);

-- 7.2 Get Active Bids for a Product
SELECT u.username, b.bid_amount, b.bid_date
FROM bidding b
JOIN users u ON b.tailor_id = u.user_id
WHERE b.product_id = 1 AND b.status = 'active'
ORDER BY b.bid_amount DESC;

-- 7.3 Get Product Reviews with User Details
SELECT u.username, r.rating, r.comment, r.review_date
FROM reviews r
JOIN users u ON r.user_id = u.user_id
WHERE r.product_id = 1
ORDER BY r.review_date DESC;

-- 7.4 Get User Orders with Items
SELECT o.order_id, o.order_date, o.total_amount, o.status,
       p.name as product_name, oi.quantity, oi.price_at_time
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.user_id = 1
ORDER BY o.order_date DESC;

-- Section 8: Verification
-- =============================================
SELECT 'Database setup completed successfully!' as Message;
SHOW TABLES;
DESCRIBE users;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE bidding;

-- Test user retrieval
SELECT * FROM users WHERE user_type = 'tailor';

-- Test product listing
SELECT * FROM products WHERE is_available = TRUE;

-- Test the active products view
SELECT * FROM active_products; 