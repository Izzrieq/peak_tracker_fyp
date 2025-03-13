<?php
include 'conn.php';
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Fetch workout categories
$sql = "SELECT * FROM workouts";
$result = $conn->query($sql);

$workouts = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $workouts[] = $row;
    }
}

echo json_encode($workouts);

$conn->close();
