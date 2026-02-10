import 'package:cv_project/models/cv_model.dart';
import 'package:cv_project/screens/edit_cv_screen.dart';
import 'package:cv_project/services/auth_service.dart';
import 'package:cv_project/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My CV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<CVModel?>(
        stream: dbService.streamCV(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cv = snapshot.data;

          if (cv == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No CV found. Create one!'),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditCVScreen()),
                    ),
                    child: const Text('Create CV'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(cv.fullName, style: Theme.of(context).textTheme.headlineMedium),
              Text(cv.email),
              Text(cv.phone),
              Text(cv.address),
              const Divider(),
              const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(cv.summary),
              const Divider(),
              const Text('Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...cv.experiences.map((exp) => ListTile(
                    title: Text(exp.role),
                    subtitle: Text(exp.company),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditCVScreen(initialCV: cv)),
                ),
                child: const Text('Edit CV'),
              ),
            ],
          );
        },
      ),
    );
  }
}
