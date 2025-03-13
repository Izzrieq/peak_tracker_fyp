<?php
include 'conn.php';

$username = $_GET['username'];

$query = "SELECT body_mass FROM users WHERE username = '$username'";
$result = mysqli_query($conn, $query);

if ($row = mysqli_fetch_assoc($result)) {
    echo json_encode(['weight' => $row['body_mass']]);
} else {
    echo json_encode(['error' => 'User not found']);
}
