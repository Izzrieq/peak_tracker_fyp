<?php
include 'conn.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get data from POST request
    $username = $_POST['username'];
    $workout_name = $_POST['workout_name'];

    // Sanitize inputs
    $username = $conn->real_escape_string($username);
    $workout_name = $conn->real_escape_string($workout_name);

    // SQL to delete custom workout
    $sql = "DELETE FROM custom_workouts WHERE username = '$username' AND workout_name = '$workout_name'";

    if ($conn->query($sql) === TRUE) {
        // Successfully deleted
        echo json_encode(["status" => "success", "message" => "Custom workout deleted successfully"]);
    } else {
        // Error deleting custom workout
        echo json_encode(["status" => "error", "message" => "Error deleting custom workout: " . $conn->error]);
    }

    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
