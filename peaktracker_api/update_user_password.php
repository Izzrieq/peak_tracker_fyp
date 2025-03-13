<?php
// Include the database connection file
include 'conn.php';

// Check if the required data is sent
if (
    isset($_POST['username']) && isset($_POST['current_password']) &&
    isset($_POST['new_password'])
) {
    $username = $_POST['username'];
    $currentPassword = $_POST['current_password'];
    $newPassword = $_POST['new_password'];

    // Check the current password
    $query = "SELECT password FROM users WHERE username = '$username'";
    $result = mysqli_query($conn, $query);
    if (mysqli_num_rows($result) > 0) {
        $user = mysqli_fetch_assoc($result);
        if (password_verify($currentPassword, $user['password'])) {
            // Hash the new password
            $newPasswordHashed = password_hash($newPassword, PASSWORD_DEFAULT);
            // Update the password in the database
            $updateQuery = "UPDATE users SET password = '$newPasswordHashed' WHERE username = '$username'";
            $updateResult = mysqli_query($conn, $updateQuery);
            if ($updateResult) {
                echo json_encode(['status' => 'success', 'message' => 'Password updated successfully']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to update password']);
            }
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Current password is incorrect']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'User not found']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
}
