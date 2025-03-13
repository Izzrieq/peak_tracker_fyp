import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'discover_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final double currentWeight;
  final double targetWeight;

  DashboardScreen({
    required this.username,
    required double? currentWeight,
    required double? targetWeight,
  }) : currentWeight = currentWeight ?? 50.0, // Default to 50.0 if null
       targetWeight = targetWeight ?? 50.0;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> workouts = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    var url = Uri.parse("http://localhost/peaktracker_api/get_workout.php");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        workouts = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debugging prints
    print("Username: ${widget.username}");
    print("Current Weight: ${widget.currentWeight}");
    print("Target Weight: ${widget.targetWeight}");

    // Prevent division by zero
    double progress =
        widget.currentWeight > 0
            ? (widget.currentWeight - widget.targetWeight) /
                widget.currentWeight
            : 0.0;
    progress = progress.clamp(0.0, 1.0); // Ensure between 0 and 1

    return Scaffold(
      appBar: AppBar(
        title: Text("Peak Tracker", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.username}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Your Progress"),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey,
              color: Colors.blue.shade900,
            ),
            SizedBox(height: 10),
            Text(
              "${(progress * 100).toStringAsFixed(1)}% remaining to reach your target weight",
            ),
            SizedBox(height: 20),
            Text(
              "Workout Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(workouts[index]['name']),
                      subtitle: Text(workouts[index]['description']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 1: // Discover
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DiscoverScreen(
                        username: widget.username,
                        currentWeight: widget.currentWeight,
                        targetWeight: widget.targetWeight,
                      ),
                ),
              );
              break;
            case 2: // Workout
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => WorkoutScreen(
                        username: widget.username,
                        currentWeight: widget.currentWeight,
                        targetWeight: widget.targetWeight,
                      ),
                ),
              );
              break;
            case 3: // Profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProfileScreen(
                        username: widget.username,
                        currentWeight: widget.currentWeight,
                        targetWeight: widget.targetWeight,
                      ),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
