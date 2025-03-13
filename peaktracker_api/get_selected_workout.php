<?php
header("Content-Type: application/json");
include 'conn.php';

$username = $_GET['username'];

// Query to get workouts and their exercises
$query = "SELECT w.id AS workout_id, w.name AS workout_name, w.description, 
                 we.name AS exercise_name, we.sets, we.reps
          FROM user_workouts uw
          JOIN workouts w ON uw.workout_id = w.id
          LEFT JOIN workout_exercises we ON w.id = we.workout_id
          WHERE uw.username = ?";

$stmt = mysqli_prepare($conn, $query);
mysqli_stmt_bind_param($stmt, "s", $username);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

// Organize workouts and their exercises
$workouts = [];
while ($row = mysqli_fetch_assoc($result)) {
    $workout_id = $row['workout_id'];

    // If the workout is not yet added, initialize it
    if (!isset($workouts[$workout_id])) {
        $workouts[$workout_id] = [
            "name" => $row["workout_name"],
            "description" => $row["description"],
            "exercises" => []
        ];
    }

    // Add exercise if available
    if (!empty($row["exercise_name"])) {
        $workouts[$workout_id]["exercises"][] = [
            "name" => $row["exercise_name"],
            "sets" => $row["sets"],
            "reps" => $row["reps"]
        ];
    }
}

// Convert associative array to indexed array
$workouts = array_values($workouts);

// Return JSON response
if (!empty($workouts)) {
    echo json_encode(["status" => "success", "workouts" => $workouts]);
} else {
    echo json_encode(["status" => "error", "message" => "No workouts found"]);
}

// Close connection
mysqli_stmt_close($stmt);
mysqli_close($conn);
