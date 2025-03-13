<?php
include 'conn.php';

header("Content-Type: application/json");

$query = "SELECT id, name, description FROM workouts";
$result = mysqli_query($conn, $query);

if ($result) {
    $workouts = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $workouts[] = [
            'id' => $row['id'],
            'name' => $row['name'],
            'description' => $row['description']
        ];
    }
    echo json_encode($workouts);
} else {
    echo json_encode(['error' => 'No workouts found']);
}

mysqli_close($conn);
