import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String message = "";

  Future<void> loginUser() async {
    var url = Uri.parse("http://localhost/peaktracker_api/login.php");
    var response = await http.post(
      url,
      body: {
        "email": emailController.text,
        "password": passwordController.text,
      },
    );

    var data = json.decode(response.body);

    // Debugging: Print the response
    print("Response: $data");

    if (data["status"] == "success") {
      setState(() {
        message = "Login Successful!";
      });

      var username = data["user"]["username"];
      var currentWeight = double.parse(data["user"]["body_mass"].toString());
      var targetWeight = double.parse(data["user"]["target_weight"].toString());

      Navigator.pushReplacementNamed(
        context,
        "/dashboard",
        arguments: {
          "username": username,
          "currentWeight": currentWeight,
          "targetWeight": targetWeight,
        },
      );
    } else {
      setState(() {
        message = data["message"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: loginUser,
              child: Text("Login"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(message, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/signup");
              },
              child: Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
