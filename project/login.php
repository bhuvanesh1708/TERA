<?php
include 'config.php';

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Log file setup
$log_file = 'login_errors.log';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    try {
        // Log the received data
        file_put_contents($log_file, "Login attempt: " . date('Y-m-d H:i:s') . "\n", FILE_APPEND);
        file_put_contents($log_file, "POST data: " . print_r($_POST, true) . "\n", FILE_APPEND);

        $email = $_POST['email'];
        $password = $_POST['password'];

        if (empty($email) || empty($password)) {
            throw new Exception("Email and password are required");
        }

        $sql = "SELECT * FROM users WHERE email = ? AND user_type = 'consumer'";
        $stmt = $conn->prepare($sql);
        
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }

        $stmt->bind_param("s", $email);
        
        if (!$stmt->execute()) {
            throw new Exception("Execute failed: " . $stmt->error);
        }

        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            if (password_verify($password, $user['password'])) {
                session_start();
                $_SESSION['user_id'] = $user['user_id'];
                $_SESSION['user_name'] = $user['first_name'] . ' ' . $user['last_name'];
                $_SESSION['user_email'] = $user['email'];
                
                // Update last login time
                $update_sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = ?";
                $update_stmt = $conn->prepare($update_sql);
                $update_stmt->bind_param("i", $user['user_id']);
                $update_stmt->execute();
                
                echo json_encode([
                    'status' => 'success', 
                    'message' => 'Login successful',
                    'user_id' => $user['user_id']
                ]);
            } else {
                throw new Exception("Invalid password");
            }
        } else {
            throw new Exception("User not found");
        }
    } catch (Exception $e) {
        file_put_contents($log_file, "Error: " . $e->getMessage() . "\n", FILE_APPEND);
        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid request method'
    ]);
}
?> 