<?php
include 'conn.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Get username from request
if (!isset($_GET['username'])) {
    echo json_encode(["status" => "error", "message" => "Username is required"]);
    exit();
}

$username = $_GET['username'];

// Fetch custom workouts for the user
$sql = "SELECT id, workout_name, start_time, end_time, body_weight, notes, exercises FROM custom_workouts WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

$customWorkouts = [];
while ($row = $result->fetch_assoc()) {
    $customWorkouts[] = $row;
}

$stmt->close();
$conn->close();

// Return JSON response
if (!empty($customWorkouts)) {
    echo json_encode(["status" => "success", "custom_workouts" => $customWorkouts]);
} else {
    echo json_encode(["status" => "error", "message" => "No custom workouts found"]);
}
