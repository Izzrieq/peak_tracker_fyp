<?php
header("Content-Type: application/json");
include 'conn.php';

$username = $_POST['username'];
$workout_name = $_POST['workout_name'];

// Get workout ID
$query = "SELECT id FROM workouts WHERE name = ?";
$stmt = mysqli_prepare($conn, $query);
mysqli_stmt_bind_param($stmt, "s", $workout_name);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
$workout = mysqli_fetch_assoc($result);

if (!$workout) {
    echo json_encode(["status" => "error", "message" => "Workout not found"]);
    exit();
}

$workout_id = $workout['id'];

// Delete the workout from user_workouts table
$deleteQuery = "DELETE FROM user_workouts WHERE username = ? AND workout_id = ?";
$stmt = mysqli_prepare($conn, $deleteQuery);
mysqli_stmt_bind_param($stmt, "si", $username, $workout_id);
if (mysqli_stmt_execute($stmt)) {
    echo json_encode(["status" => "success", "message" => "Workout deleted"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to delete workout"]);
}

// Close connection
mysqli_stmt_close($stmt);
mysqli_close($conn);
