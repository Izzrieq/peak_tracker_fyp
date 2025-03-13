<?php
include 'conn.php';

$data = json_decode(file_get_contents("php://input"), true);

$username = $data['username'];
$workout_name = $data['workout_name'];
$start_time = $data['start_time'];
$end_time = $data['end_time'];
$body_weight = $data['body_weight'];
$notes = $data['notes'];
$exercises = json_encode($data['exercises']);

$query = "INSERT INTO custom_workouts (username, workout_name, start_time, end_time, body_weight, notes, exercises) 
          VALUES ('$username', '$workout_name', '$start_time', '$end_time', '$body_weight', '$notes', '$exercises')";

if (mysqli_query($conn, $query)) {
    echo json_encode(["message" => "Custom workout added successfully"]);
} else {
    echo json_encode(["error" => "Failed to add workout"]);
}
