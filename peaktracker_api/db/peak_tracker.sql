-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Mar 13, 2025 at 04:28 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `peak_tracker`
--

-- --------------------------------------------------------

--
-- Table structure for table `custom_workouts`
--

CREATE TABLE `custom_workouts` (
  `id` int(11) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `workout_name` varchar(255) DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `body_weight` float DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `exercises` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`exercises`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `custom_workouts`
--

INSERT INTO `custom_workouts` (`id`, `username`, `workout_name`, `start_time`, `end_time`, `body_weight`, `notes`, `exercises`, `created_at`) VALUES
(1, 'Izz', 'Ramadan Fit', '02:06:00', '03:06:00', 120, 'Push', '[{\"name\":\"Bicep Curl\",\"kg\":\"25\",\"sets\":\"3\",\"reps\":\"15\"}]', '2025-03-13 07:41:11'),
(4, 'test', 'test', '05:00:00', '06:00:00', 50, 'test', '[{\"name\":\"Bicep Curl\",\"kg\":\"35\",\"sets\":\"3\",\"reps\":\"15\"}]', '2025-03-13 07:41:11'),
(5, 'niko', 'Test', '03:00:00', '05:00:00', 83, 'test', '[{\"name\":\"Bicep Curl\",\"kg\":\"25\",\"sets\":\"3\",\"reps\":\"14\"}]', '2025-03-13 07:41:11');

-- --------------------------------------------------------

--
-- Table structure for table `meals`
--

CREATE TABLE `meals` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `food` varchar(255) NOT NULL,
  `calories` double NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `body_mass` float DEFAULT NULL,
  `target_weight` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `body_mass`, `target_weight`) VALUES
(4, 'niko', 'nk@gmail.com', '$2y$10$Qw6Bd/qpBmOksJYhpDb7HejXQAy.eSYpLfhzVSnkI9vAoOMeg7zfa', 83, 70),
(6, 'test', 'test@gmail.com', '$2y$10$dPeyjVJwWNNDMVLHJsnCoeOmCr4JDbxM7rJ7X5yY5DjX4yLRWjIb.', 50, 50);

-- --------------------------------------------------------

--
-- Table structure for table `user_workouts`
--

CREATE TABLE `user_workouts` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `workout_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_workouts`
--

INSERT INTO `user_workouts` (`id`, `username`, `workout_id`, `created_at`, `updated_at`) VALUES
(12, 'niko', 5, '2025-03-12 18:28:54', '2025-03-12 18:28:54'),
(13, 'niko', 1, '2025-03-12 18:29:54', '2025-03-12 18:29:54');

-- --------------------------------------------------------

--
-- Table structure for table `workouts`
--

CREATE TABLE `workouts` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `workouts`
--

INSERT INTO `workouts` (`id`, `name`, `description`) VALUES
(1, 'Cardio', 'Improve your heart health with running, cycling, and jumping rope.'),
(2, 'Strength Training', 'Build muscle mass with weightlifting and resistance exercises.'),
(3, 'Yoga', 'Enhance flexibility and mental wellness through guided poses.'),
(4, 'HIIT', 'High-intensity interval training for fat loss and endurance.'),
(5, 'ABS', 'Target the muscles in your stomach, primarily through flexion and extension exercises');

-- --------------------------------------------------------

--
-- Table structure for table `workout_exercises`
--

CREATE TABLE `workout_exercises` (
  `id` int(11) NOT NULL,
  `workout_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `sets` int(11) NOT NULL,
  `reps` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `workout_exercises`
--

INSERT INTO `workout_exercises` (`id`, `workout_id`, `name`, `sets`, `reps`) VALUES
(1, 1, 'Jump Rope', 3, 50),
(2, 1, 'Running', 3, 10),
(3, 1, 'Jumping Jacks', 3, 40),
(4, 2, 'Push-ups', 3, 15),
(5, 2, 'Pull-ups', 3, 10),
(6, 2, 'Deadlifts', 3, 12),
(7, 3, 'Downward Dog', 3, 30),
(8, 3, 'Warrior Pose', 3, 30),
(9, 3, 'Tree Pose', 3, 30);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `custom_workouts`
--
ALTER TABLE `custom_workouts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meals`
--
ALTER TABLE `meals`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_workouts`
--
ALTER TABLE `user_workouts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `workout_id` (`workout_id`);

--
-- Indexes for table `workouts`
--
ALTER TABLE `workouts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `workout_exercises`
--
ALTER TABLE `workout_exercises`
  ADD PRIMARY KEY (`id`),
  ADD KEY `workout_id` (`workout_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `custom_workouts`
--
ALTER TABLE `custom_workouts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `meals`
--
ALTER TABLE `meals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `user_workouts`
--
ALTER TABLE `user_workouts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `workouts`
--
ALTER TABLE `workouts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `workout_exercises`
--
ALTER TABLE `workout_exercises`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
