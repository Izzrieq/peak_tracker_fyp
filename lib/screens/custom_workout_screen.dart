import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomWorkoutScreen extends StatefulWidget {
  final String username;

  CustomWorkoutScreen({required this.username});

  @override
  _CustomWorkoutScreenState createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String userWeight = "Loading...";
  List<Map<String, dynamic>> exercises = [];

  // Predefined Exercise List (You can add more exercises here)
  final List<String> exerciseList = [
    "Bicep Curl",
    "Bench Press",
    "Squat",
    "Deadlift",
    "Lat Pulldown",
    "Push-up",
    "Pull-up",
  ];

  @override
  void initState() {
    super.initState();
    fetchUserWeight();
  }

  Future<void> fetchUserWeight() async {
    var url = Uri.parse(
      'http://localhost/peaktracker_api/get_user_weight.php?username=${widget.username}',
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        userWeight = data['weight'] ?? 'Not available';
      });
    } else {
      setState(() {
        userWeight = 'Error fetching weight';
      });
    }
  }

  void addExercise() {
    setState(() {
      exercises.add({
        'name': exerciseList[0],
        'kg': '',
        'sets': '1',
        'reps': '1',
      });
    });
  }

  Future<void> submitWorkout() async {
    var url = Uri.parse(
      'http://localhost/peaktracker_api/add_custom_workout.php',
    );
    var response = await http.post(
      url,
      body: json.encode({
        'username': widget.username,
        'workout_name': workoutNameController.text,
        'start_time': startTimeController.text,
        'end_time': endTimeController.text,
        'body_weight': userWeight,
        'notes': notesController.text,
        'exercises': exercises,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      showSuccessDialog(responseData['message'] ?? 'Workout saved!');
    } else {
      showSuccessDialog('Failed to save workout');
    }
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text('Success!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Return to WorkoutScreen
              },
              child: Text('OK', style: TextStyle(color: Colors.green)),
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
        title: Text(
          "Create Custom Workout",
          style: TextStyle(color: Colors.white),
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: workoutNameController,
                decoration: InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeController,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: endTimeController,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer_off),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Weight: $userWeight kg",
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.monitor_weight, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: addExercise,
                icon: Icon(Icons.add),
                label: Text("Add Exercise"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: exercises[index]['name'],
                            items:
                                exerciseList.map((exercise) {
                                  return DropdownMenuItem(
                                    value: exercise,
                                    child: Text(exercise),
                                  );
                                }).toList(),
                            onChanged:
                                (value) => setState(
                                  () => exercises[index]['name'] = value,
                                ),
                            decoration: InputDecoration(
                              labelText: 'Exercise',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged:
                                      (value) => exercises[index]['kg'] = value,
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.monitor_weight),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: exercises[index]['sets'],
                                  items: List.generate(
                                    10,
                                    (i) => DropdownMenuItem(
                                      child: Text('${i + 1} Sets'),
                                      value: '${i + 1}',
                                    ),
                                  ),
                                  onChanged:
                                      (value) => setState(
                                        () => exercises[index]['sets'] = value,
                                      ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: exercises[index]['reps'],
                                  items: List.generate(
                                    20,
                                    (i) => DropdownMenuItem(
                                      child: Text('${i + 1} Reps'),
                                      value: '${i + 1}',
                                    ),
                                  ),
                                  onChanged:
                                      (value) => setState(
                                        () => exercises[index]['reps'] = value,
                                      ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: submitWorkout,
                  child: Text("Save Workout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
