import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'choose_workout.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final String username;
  final double currentWeight;
  final double targetWeight;

  WorkoutScreen({
    required this.username,
    required this.currentWeight,
    required this.targetWeight,
  });

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<dynamic> workouts = [];
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    fetchSelectedWorkouts();
  }

  Future<void> fetchSelectedWorkouts() async {
    List<dynamic> premadeWorkouts = [];
    List<dynamic> customWorkouts = [];

    var premadeUrl = Uri.parse(
      "http://localhost/peaktracker_api/get_selected_workout.php?username=${widget.username}",
    );
    var premadeResponse = await http.get(premadeUrl);
    print("Premade Workout Response: ${premadeResponse.body}"); // Debugging

    if (premadeResponse.statusCode == 200) {
      var data = json.decode(premadeResponse.body);
      if (data["status"] == "success") {
        premadeWorkouts = data["workouts"];
      } else {
        print("Error: ${data['message']}"); // Print the error message from API
      }
    } else {
      print("HTTP Error: ${premadeResponse.statusCode}");
    }

    var customUrl = Uri.parse(
      "http://localhost/peaktracker_api/get_custom_workout.php?username=${widget.username}",
    );
    var customResponse = await http.get(customUrl);
    if (customResponse.statusCode == 200) {
      var data = json.decode(customResponse.body);
      if (data["status"] == "success") {
        customWorkouts = data["custom_workouts"];
      }
    }

    setState(() {
      // Decode the exercises field for each custom workout
      customWorkouts =
          customWorkouts.map((workout) {
            workout['exercises'] = json.decode(
              workout['exercises'],
            ); // Decode exercises string to list
            return workout;
          }).toList();

      workouts = [...premadeWorkouts, ...customWorkouts];
    });
  }

  Future<void> deleteWorkout(String workoutName) async {
    var url = Uri.parse("http://localhost/peaktracker_api/delete_workout.php");
    var response = await http.post(
      url,
      body: {"username": widget.username, "workout_name": workoutName},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"] == "success") {
        setState(() {
          workouts.removeWhere(
            (workout) =>
                workout['workout_name'] == workoutName ||
                workout['name'] == workoutName,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Workout deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> deleteCustomWorkout(String workoutName) async {
    var url = Uri.parse(
      "http://localhost/peaktracker_api/delete_custom_workout.php",
    );
    var response = await http.post(
      url,
      body: {"username": widget.username, "workout_name": workoutName},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"] == "success") {
        setState(() {
          workouts.removeWhere(
            (workout) =>
                workout['workout_name'] == workoutName ||
                workout['name'] == workoutName,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Custom workout deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void showDeleteConfirmationDialog(
    String workoutName, {
    bool isCustom = false,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Workout"),
          content: Text("Are you sure you want to delete '$workoutName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isCustom) {
                  deleteCustomWorkout(workoutName);
                } else {
                  deleteWorkout(workoutName);
                }
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workout", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child:
            workouts.isEmpty
                ? Center(child: Text("No workouts selected yet."))
                : ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    var workout = workouts[index];
                    List<dynamic> exercises =
                        workout["exercises"] is List<dynamic>
                            ? workout["exercises"]
                            : [];

                    bool isCustom = workout.containsKey('start_time');
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          workout['workout_name'] ??
                              workout['name'] ??
                              "No name available",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCustom ? Colors.orange : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isCustom) ...[
                              Text("Start Time: ${workout['start_time']}"),
                              Text("End Time: ${workout['end_time']}"),
                              Text("Body Weight: ${workout['body_weight']} kg"),
                              Text("Notes: ${workout['notes']}"),
                              SizedBox(height: 10),
                            ],
                            ...exercises.map<Widget>((exercise) {
                              return Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  "- ${exercise['name']} | Sets: ${exercise['sets']}, Reps: ${exercise['reps']}",
                                ),
                              );
                            }).toList(),
                            if (!isCustom) Text("Premade workout"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => showDeleteConfirmationDialog(
                                workout['workout_name'] ??
                                    workout['name'] ??
                                    "",
                                isCustom: workout.containsKey(
                                  'start_time',
                                ), // Assuming custom workouts have 'start_time' field
                              ),
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChooseWorkoutScreen(username: widget.username),
            ),
          ).then((_) => fetchSelectedWorkouts());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
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

          // Navigate to the respective screen based on the selected tab
          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DashboardScreen(
                        username: widget.username,
                        currentWeight: widget.currentWeight,
                        targetWeight: widget.targetWeight,
                      ),
                ),
              );
              break;
            case 1: // Discover
              Navigator.pushReplacement(
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
              // No need to navigate here, you're already on the WorkoutScreen
              break;
            case 3: // Profile
              Navigator.pushReplacement(
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
