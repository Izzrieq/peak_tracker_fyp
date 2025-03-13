<?php
include 'conn.php';

// Check if all the required POST data is present
if (
    isset($_POST['username']) && isset($_POST['new_username']) &&
    isset($_POST['new_email']) && isset($_POST['new_currentWeight']) &&
    isset($_POST['new_targetWeight'])
) {
    $username = $_POST['username'];
    $newUsername = $_POST['new_username'];
    $newEmail = $_POST['new_email'];
    $newCurrentWeight = $_POST['new_currentWeight'];
    $newTargetWeight = $_POST['new_targetWeight'];

    // Validate the email format
    if (!filter_var($newEmail, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid email format']);
        exit();
    }

    // Update the user profile in the database
    $query = "UPDATE users SET 
                username = '$newUsername', 
                email = '$newEmail', 
                body_mass = '$newCurrentWeight', 
                target_weight = '$newTargetWeight'
              WHERE username = '$username'";

    $result = mysqli_query($conn, $query);

    if ($result) {
        echo json_encode(['status' => 'success', 'message' => 'Profile updated successfully']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to update profile']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
}
