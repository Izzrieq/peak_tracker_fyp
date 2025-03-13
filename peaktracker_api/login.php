<?php
include 'conn.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Get the email and password from POST request
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Prepare SQL statement to prevent SQL injection
    if ($stmt = $conn->prepare("SELECT * FROM users WHERE email = ?")) {
        $stmt->bind_param("s", $email);  // "s" stands for string
        $stmt->execute();
        $result = $stmt->get_result();

        // Check if user exists
        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();

            // Verify the password using bcrypt
            if (password_verify($password, $user['password'])) {
                // Password is correct, send success response
                echo json_encode([
                    "status" => "success",
                    "message" => "Login successful",
                    "user" => $user
                ]);
            } else {
                // Incorrect password
                echo json_encode(["status" => "error", "message" => "Incorrect password"]);
            }
        } else {
            // User not found
            echo json_encode(["status" => "error", "message" => "User not found"]);
        }

        // Close statement
        $stmt->close();
    } else {
        // Error preparing statement
        echo json_encode(["status" => "error", "message" => "Database error"]);
    }
}
