import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'workout_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiscoverScreen extends StatefulWidget {
  final String username;
  final double currentWeight;
  final double targetWeight;

  DiscoverScreen({
    required this.username,
    required this.currentWeight,
    required this.targetWeight,
  });

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _currentIndex = 1; // Default index for Discover
  List<Map<String, dynamic>> meals = [];
  TextEditingController foodController = TextEditingController();
  TextEditingController calorieController = TextEditingController();

  Future<void> fetchMeals() async {
    final url =
        'http://localhost/peaktracker_api/get_meals.php?username=${widget.username}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        // Ensure the calories are treated as a number (double or int)
        setState(() {
          meals =
              List<Map<String, dynamic>>.from(data['meals']).map((meal) {
                // Convert calories to an integer (if it's a string, otherwise leave it as is)
                meal['calories'] =
                    int.tryParse(meal['calories']) ??
                    0; // Default to 0 if parsing fails
                return meal;
              }).toList();
        });
      } else {
        print("Error fetching meals: ${data['message']}");
      }
    } else {
      print("Failed to fetch meals");
    }
  }

  Future<void> addMealToDatabase(
    String username,
    String food,
    double calories,
  ) async {
    final url =
        'http://localhost/peaktracker_api/add_meals.php'; // Replace with your PHP script URL

    final data = {'username': username, 'food': food, 'calories': calories};
    print(json.encode(data)); // Print the request payload for debugging

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        print("Meal added successfully");

        // Show a customized Snackbar with a green background and action button
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Meal added successfully!',
              style: TextStyle(fontSize: 16, color: Colors.white), // Text color
            ),
            backgroundColor: Colors.green, // Snackbar background color
            action: SnackBarAction(
              label: 'UNDO', // Action text
              textColor: Colors.white, // Action text color
              onPressed: () {
                // You can implement undo action here if needed
                print("Undo action pressed");
              },
            ),
            duration: Duration(seconds: 3), // How long the Snackbar lasts
          ),
        );

        // Re-fetch meals to refresh the UI
        fetchMeals();
      } else {
        print("Error adding meal: ${data['message']}");
      }
    } else {
      print("Failed to communicate with the server");
    }
  }

  Future<void> deleteMeal(String food) async {
    final url =
        'http://localhost/peaktracker_api/delete_meals.php'; // Replace with your PHP script URL

    final data = {'username': widget.username, 'food': food};

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        print("Meal deleted successfully");
        fetchMeals(); // Refresh meal list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal deleted successfully!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print("Error deleting meal: ${data['message']}");
      }
    } else {
      print("Failed to communicate with the server");
    }
  }

  double calculateRecommendedCalories() {
    double baseCalories = 2000; // Default maintenance calories
    double weightDifference = widget.targetWeight - widget.currentWeight;

    // Adjust based on weight goal
    double adjustment = weightDifference * 100;
    double recommendedCalories = baseCalories + adjustment;

    // Ensure values are reasonable
    return recommendedCalories.clamp(1500, 3500);
  }

  void addMeal() {
    if (foodController.text.isNotEmpty && calorieController.text.isNotEmpty) {
      addMealToDatabase(
        widget.username,
        foodController.text,
        double.tryParse(calorieController.text) ?? 0,
      );
      foodController.clear();
      calorieController.clear();
    }
  }

  double totalCalories() {
    return meals.fold(0.0, (sum, meal) {
      // Ensure calories is parsed as a double, even if it's a string
      double calories = double.tryParse(meal['calories'].toString()) ?? 0.0;
      return sum + calories;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMeals(); // Fetch meals when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    double recommendedCalories = calculateRecommendedCalories();
    double progress = (totalCalories() / recommendedCalories).clamp(0.0, 1.0);

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
              "Welcome, ${widget.username} 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Current Weight: ${widget.currentWeight} kg",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Target Weight: ${widget.targetWeight} kg",
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            SizedBox(height: 20),

            // Calorie Progress Bar
            Text(
              "Daily Calorie Intake",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color:
                  totalCalories() > recommendedCalories
                      ? Colors.red
                      : Colors.green,
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text(
              "Total Calories: ${totalCalories()} kcal",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              "Recommended: ${recommendedCalories.toStringAsFixed(0)} kcal",
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),

            SizedBox(height: 20),
            Text(
              "Today's Meals",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Meal List
            Expanded(
              child:
                  meals.isEmpty
                      ? Center(
                        child: Text(
                          "No meals added yet!",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading: Icon(
                                Icons.fastfood,
                                color: Colors.orange,
                              ),
                              title: Text(
                                meals[index]['food'] ?? 'No Food Name',
                              ),
                              subtitle: Text(
                                "Calories: ${meals[index]['calories'] ?? 'N/A'} kcal",
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // Show confirmation dialog before deleting
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Deletion'),
                                        content: Text(
                                          'Are you sure you want to delete this meal?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Delete the meal and refresh the list
                                              deleteMeal(meals[index]['food']);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Adding Meals
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text("Add Meal"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: foodController,
                        decoration: InputDecoration(labelText: "Food Item"),
                      ),
                      TextField(
                        controller: calorieController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Calories"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addMeal();
                        Navigator.pop(context);
                      },
                      child: Text("Add"),
                    ),
                  ],
                ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),

      // Bottom Navigation Bar
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
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(
                context,
                "/dashboard",
                arguments: {
                  "username": widget.username,
                  "currentWeight": widget.currentWeight,
                  "targetWeight": widget.targetWeight,
                },
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(
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
            case 3:
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
