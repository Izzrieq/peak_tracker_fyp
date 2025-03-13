<?php
include 'conn.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $workout_id = $_POST['workout_id'];

    // Check if user already has a workout
    $checkQuery = "SELECT * FROM user_workouts WHERE username = '$username'";
    $checkResult = mysqli_query($conn, $checkQuery);

    if (mysqli_num_rows($checkResult) > 0) {
        // Update existing workout
        $query = "UPDATE user_workouts SET workout_id = '$workout_id' WHERE username = '$username'";
    } else {
        // Insert new workout selection
        $query = "INSERT INTO user_workouts (username, workout_id) VALUES ('$username', '$workout_id')";
    }

    if (mysqli_query($conn, $query)) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($conn)]);
    }
}

mysqli_close($conn);
