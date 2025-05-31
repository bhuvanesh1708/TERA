<?php
$servername = "localhost";
$username = "root";
$password = "";

try {
    // Create connection without selecting a database
    $conn = new mysqli($servername, $username, $password);
    
    // Check connection
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }
    
    // Read SQL file
    $sql = file_get_contents('tera_db.sql');
    
    // Execute multiple queries
    if ($conn->multi_query($sql)) {
        do {
            // Store first result set
            if ($result = $conn->store_result()) {
                $result->free();
            }
        } while ($conn->next_result());
        
        echo "Database setup completed successfully!";
    } else {
        throw new Exception("Error executing SQL: " . $conn->error);
    }
    
    $conn->close();
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?> 