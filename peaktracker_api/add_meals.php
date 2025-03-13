<?php
include 'conn.php'; // Ensure this file includes the correct DB connection.

header("Content-Type: application/json");

// Read incoming JSON data
$inputData = file_get_contents('php://input');
$data = json_decode($inputData, true); // Decode the JSON data

// Extract values from the JSON data
$username = isset($data['username']) ? $data['username'] : null;
$food = isset($data['food']) ? $data['food'] : null;
$calories = isset($data['calories']) ? $data['calories'] : null;

// Check if all required fields are provided
if ($username && $food && $calories) {
    // Escape values to prevent SQL injection
    $username = mysqli_real_escape_string($conn, $username);
    $food = mysqli_real_escape_string($conn, $food);
    $calories = mysqli_real_escape_string($conn, $calories);

    // Insert the meal data into the database
    $query = "INSERT INTO meals (username, food, calories, date, timestamp) 
              VALUES ('$username', '$food', '$calories', NOW(), NOW())";

    // Execute the query
    if (mysqli_query($conn, $query)) {
        echo json_encode(['status' => 'success', 'message' => 'Meal added successfully']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to insert meal']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Missing data']);
}

// Close the database connection
mysqli_close($conn);
