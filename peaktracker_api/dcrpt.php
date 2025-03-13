<?php
$password = "$2a$12$wkzGqN79Bs.nMi11Z7MXI.HZDzuIlkgQzY7o21a9ERHT4kVWUTfJm"; // Replace with your actual password
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

echo $hashedPassword;
