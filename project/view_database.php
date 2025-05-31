<?php
include 'config.php';

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h2>TERA Database Structure</h2>";

// Get all tables in the database
$tables_query = "SHOW TABLES";
$tables_result = $conn->query($tables_query);

if ($tables_result->num_rows > 0) {
    while ($table = $tables_result->fetch_array()) {
        $table_name = $table[0];
        
        echo "<h3>Table: " . htmlspecialchars($table_name) . "</h3>";
        
        // Get table structure
        $structure_query = "DESCRIBE " . $table_name;
        $structure_result = $conn->query($structure_query);
        
        echo "<table border='1' style='border-collapse: collapse; width: 100%; margin-bottom: 20px;'>";
        echo "<tr>
                <th>Field</th>
                <th>Type</th>
                <th>Null</th>
                <th>Key</th>
                <th>Default</th>
                <th>Extra</th>
              </tr>";
        
        while ($row = $structure_result->fetch_assoc()) {
            echo "<tr>";
            echo "<td>" . htmlspecialchars($row['Field']) . "</td>";
            echo "<td>" . htmlspecialchars($row['Type']) . "</td>";
            echo "<td>" . htmlspecialchars($row['Null']) . "</td>";
            echo "<td>" . htmlspecialchars($row['Key']) . "</td>";
            echo "<td>" . htmlspecialchars($row['Default']) . "</td>";
            echo "<td>" . htmlspecialchars($row['Extra']) . "</td>";
            echo "</tr>";
        }
        echo "</table>";
        
        // Show sample data
        echo "<h4>Sample Data:</h4>";
        $data_query = "SELECT * FROM " . $table_name . " LIMIT 5";
        $data_result = $conn->query($data_query);
        
        if ($data_result->num_rows > 0) {
            echo "<table border='1' style='border-collapse: collapse; width: 100%; margin-bottom: 40px;'>";
            
            // Get column names
            $fields = $data_result->fetch_fields();
            echo "<tr>";
            foreach ($fields as $field) {
                echo "<th>" . htmlspecialchars($field->name) . "</th>";
            }
            echo "</tr>";
            
            // Reset pointer
            $data_result->data_seek(0);
            
            // Show data
            while ($row = $data_result->fetch_assoc()) {
                echo "<tr>";
                foreach ($row as $value) {
                    echo "<td>" . htmlspecialchars($value) . "</td>";
                }
                echo "</tr>";
            }
            echo "</table>";
        } else {
            echo "<p>No data found in this table</p>";
        }
    }
} else {
    echo "<p>No tables found in the database</p>";
}

$conn->close();
?> 