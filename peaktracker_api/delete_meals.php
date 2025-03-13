<?php
include 'conn.php';

// Get parameters from the request (adjust based on how you pass data)
$data = json_decode(file_get_contents("php://input"));

$username = $data->username;
$food = $data->food;

// SQL query to delete the meal
$sql = "DELETE FROM meals WHERE username = '$username' AND food = '$food'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Meal deleted successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error deleting meal: " . $conn->error]);
}

$conn->close();
