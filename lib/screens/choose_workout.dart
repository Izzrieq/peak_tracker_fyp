import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_workout_screen.dart';

class ChooseWorkoutScreen extends StatefulWidget {
  final String username;

  ChooseWorkoutScreen({required this.username});

  @override
  _ChooseWorkoutScreenState createState() => _ChooseWorkoutScreenState();
}

class _ChooseWorkoutScreenState extends State<ChooseWorkoutScreen> {
  List<Map<String, dynamic>> workouts = [];

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    var url = Uri.parse('http://localhost/peaktracker_api/get_workouts.php');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        var data = json.decode(response.body);
        setState(() {
          workouts = List<Map<String, dynamic>>.from(
            data.map((item) {
              item['id'] = int.tryParse(item['id'].toString()) ?? 0;
              return item;
            }),
          );
        });
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      print('Error fetching workouts');
    }
  }

  Future<void> addWorkoutToUser(int workoutId) async {
    var url = Uri.parse('http://localhost/peaktracker_api/add_workout.php');

    try {
      var response = await http.post(
        url,
        body: {'username': widget.username, 'workout_id': workoutId.toString()},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the full response

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check response status to decide which message to show
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Workout added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add workout: ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Workout", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(
              context,
            ); // This will navigate back to the previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(workouts[index]['name']),
            subtitle: Text(workouts[index]['description']),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                int workoutId =
                    int.tryParse(workouts[index]['id'].toString()) ?? 0;
                if (workoutId != 0) {
                  // Call function to add workout to user
                  addWorkoutToUser(workoutId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid workout ID'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CustomWorkoutScreen(username: widget.username),
            ),
          );
        },
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        child: Icon(Icons.fitness_center),
        tooltip: 'Custom Workout',
      ),
    );
  }
}
