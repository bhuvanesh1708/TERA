<?php
$servername = "localhost";
$username = "root";
$password = "";

// Create connection without selecting a database
$conn = new mysqli($servername, $username, $password);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Create database
$sql = "CREATE DATABASE IF NOT EXISTS tera_db";
if ($conn->query($sql) === TRUE) {
    echo "Database created successfully\n";
} else {
    echo "Error creating database: " . $conn->error . "\n";
}

// Select the database
$conn->select_db("tera_db");

// Create users table
$sql = "CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(50) NOT NULL,
    last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)";

if ($conn->query($sql) === TRUE) {
    echo "Users table created successfully\n";
} else {
    echo "Error creating table: " . $conn->error . "\n";
}

// Create a test user
$test_email = "test@example.com";
$test_password = password_hash("test123", PASSWORD_DEFAULT);
$test_first_name = "Test";
$test_last_name = "User";
$test_user_type = "consumer";

// Check if test user already exists
$check_sql = "SELECT * FROM users WHERE email = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("s", $test_email);
$check_stmt->execute();
$result = $check_stmt->get_result();

if ($result->num_rows == 0) {
    // Insert test user
    $insert_sql = "INSERT INTO users (email, password, first_name, last_name, user_type) VALUES (?, ?, ?, ?, ?)";
    $insert_stmt = $conn->prepare($insert_sql);
    $insert_stmt->bind_param("sssss", $test_email, $test_password, $test_first_name, $test_last_name, $test_user_type);
    
    if ($insert_stmt->execute()) {
        echo "Test user created successfully\n";
        echo "Email: test@example.com\n";
        echo "Password: test123\n";
    } else {
        echo "Error creating test user: " . $insert_stmt->error . "\n";
    }
} else {
    echo "Test user already exists\n";
}

$conn->close();
?> 
