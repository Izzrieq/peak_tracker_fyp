import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'workout_screen.dart';
import 'discover_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final double currentWeight;
  final double targetWeight;

  ProfileScreen({
    required this.username,
    required this.currentWeight,
    required this.targetWeight,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _currentWeightController = TextEditingController();
  TextEditingController _targetWeightController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch user profile from the API
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse(
      "http://localhost/peaktracker_api/get_user_profile.php?username=${widget.username}",
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"] == "success") {
        _usernameController.text = data["user"]["username"];
        _emailController.text = data["user"]["email"];
        _currentWeightController.text = data["user"]["body_mass"].toString();
        _targetWeightController.text = data["user"]["target_weight"].toString();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Update the user profile
  Future<void> _updateUserProfile() async {
    var url = Uri.parse(
      "http://localhost/peaktracker_api/update_user_profile.php",
    );

    var response = await http.post(
      url,
      body: {
        "username": widget.username,
        "new_username": _usernameController.text,
        "new_email": _emailController.text,
        "new_currentWeight": _currentWeightController.text,
        "new_targetWeight": _targetWeightController.text,
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show the password update dialog
  Future<void> _showUpdatePasswordDialog() async {
    final TextEditingController _currentPasswordController =
        TextEditingController();
    final TextEditingController _newPasswordController =
        TextEditingController();
    final TextEditingController _confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                ),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                ),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_newPasswordController.text ==
                    _confirmPasswordController.text) {
                  // Call API to update password
                  var response = await _updatePassword(
                    _currentPasswordController.text,
                    _newPasswordController.text,
                  );

                  if (response["status"] == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password updated successfully!")),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update password.")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Passwords do not match.")),
                  );
                }
              },
              child: Text("Update Password"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // API call to update password
  Future<Map<String, dynamic>> _updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    var url = Uri.parse(
      "http://localhost/peaktracker_api/update_user_password.php",
    );

    var response = await http.post(
      url,
      body: {
        "username": widget.username,
        "current_password": currentPassword,
        "new_password": newPassword,
      },
    );

    return json.decode(response.body);
  }

  // Log out function
  Future<void> _logout() async {
    // Clear any saved user data and navigate to login screen
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Peak Tracker", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false, // This removes the back arrow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                  children: [
                    _buildTextFieldCard("Username", _usernameController),
                    _buildTextFieldCard(
                      "Email",
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextFieldCard(
                      "Current Weight (kg)",
                      _currentWeightController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFieldCard(
                      "Target Weight (kg)",
                      _targetWeightController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserProfile,
                      child: Text("Update Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showUpdatePasswordDialog,
                      child: Text("Update Password"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logout,
                      child: Text("Log Out"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
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
        currentIndex: 3,
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
              break;
          }
        },
      ),
    );
  }

  // Function to build a text field card for each input field
  Widget _buildTextFieldCard(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter $label",
                border: OutlineInputBorder(),
              ),
              keyboardType: keyboardType,
              obscureText: obscureText,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced password field with icon
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
