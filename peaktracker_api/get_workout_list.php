<?php
include 'conn.php';

header("Content-Type: application/json");

$query = "SELECT id, name FROM workouts";
$result = mysqli_query($conn, $query);

$workouts = [];
while ($row = mysqli_fetch_assoc($result)) {
    $workouts[] = $row;
}

echo json_encode($workouts);
mysqli_close($conn);
