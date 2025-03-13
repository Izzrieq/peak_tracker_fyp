<?php
include 'conn.php';
header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST['username'];
    $email = $_POST['email'];
    $password = password_hash($_POST['password'], PASSWORD_BCRYPT);

    // Default values for body_mass and target_weight
    $body_mass = 50;
    $target_weight = 50;

    $query = "INSERT INTO users (username, email, password, body_mass, target_weight) 
              VALUES ('$username', '$email', '$password', '$body_mass', '$target_weight')";

    if ($conn->query($query) === TRUE) {
        echo json_encode(["message" => "User registered successfully"]);
    } else {
        echo json_encode(["error" => "Registration failed"]);
    }
}

$conn->close();
