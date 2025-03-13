<?php
include 'conn.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $workout_id = $_POST['workout_id'];

    if (!empty($username) && !empty($workout_id)) {
        $query = "INSERT INTO user_workouts (username, workout_id) VALUES ('$username', '$workout_id')";

        if (mysqli_query($conn, $query)) {
            echo json_encode(['status' => 'success']);
        } else {
            echo json_encode(['status' => 'failed', 'message' => mysqli_error($conn)]);
        }
    } else {
        echo json_encode(['status' => 'failed', 'message' => 'Invalid data']);
    }
}
