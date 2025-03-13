<?php
include 'conn.php'; // Ensure this file includes the correct DB connection.

header("Content-Type: application/json");

// Get the username parameter
$username = isset($_GET['username']) ? $_GET['username'] : null;

// If username is provided, fetch meals
if ($username) {
    $username = mysqli_real_escape_string($conn, $username);

    // Query to fetch all meals for the given username
    $query = "SELECT food, calories FROM meals WHERE username = '$username' ORDER BY date DESC";

    $result = mysqli_query($conn, $query);

    if (mysqli_num_rows($result) > 0) {
        $meals = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $meals[] = $row;
        }
        echo json_encode(['status' => 'success', 'meals' => $meals]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'No meals found']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Missing username']);
}

// Close the database connection
mysqli_close($conn);
