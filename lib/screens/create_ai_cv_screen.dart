import 'package:cv_project/models/cv_model.dart';
import 'package:cv_project/services/ai_service.dart';
import 'package:cv_project/services/database_service.dart';
import 'package:cv_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAICVScreen extends StatefulWidget {
  const CreateAICVScreen({super.key});

  @override
  State<CreateAICVScreen> createState() => _CreateAICVScreenState();
}

class _CreateAICVScreenState extends State<CreateAICVScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _skillLevelController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _projectsController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  
  bool _isLoading = false;

  void _showResultDialog(CVModel cv, int score, String feedback, List<dynamic> tips) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FadeScaleAnimation(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF8F6F1),
          title: const Text("AI CV Analysis ✨", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  color: const Color(0xFFD4AF37),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 20),
                Text("$score%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF3A2D5F))),
                const SizedBox(height: 10),
                Text(feedback, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Divider(),
                const Text("Improvement Tips ✨", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A2D5F))),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tips.map<Widget>((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text("• $tip", style: const TextStyle(fontSize: 14)),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Got it!", style: TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _generateCV() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final aiService = Provider.of<AIService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    try {
      final cv = await aiService.generateCV(
        name: _nameController.text,
        jobType: _jobTypeController.text,
        skillLevel: _skillLevelController.text,
        education: _educationController.text,
        experiences: _experienceController.text,
        projects: _projectsController.text,
        github: _githubController.text,
        linkedin: _linkedinController.text,
        userId: user!.uid,
      );

      if (cv != null) {
        await dbService.addCV(cv);
        final analysisResult = await aiService.analyzeCV(cv);
        
        if (mounted) {
          setState(() => _isLoading = false);
          _showResultDialog(
            cv, 
            analysisResult['score'], 
            analysisResult['feedback'],
            analysisResult['tips'] ?? []
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create with AI ✨'),
        backgroundColor: const Color(0xFF804A00),
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA57164), Color(0xFFCD7F32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading 
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFFD4AF37)),
                SizedBox(height: 20),
                Text("AI is generating and analyzing your CV...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Full Name'),
                    TextFormField(controller: _nameController, decoration: const InputDecoration(hintText: 'Enter your full name')),
                    
                    _buildFieldLabel('Target Job Title'),
                    TextFormField(controller: _jobTypeController, decoration: const InputDecoration(hintText: 'e.g. Flutter Developer')),
                    
                    _buildFieldLabel('Skill Level'),
                    TextFormField(controller: _skillLevelController, decoration: const InputDecoration(hintText: 'e.g. Intermediate, Senior')),

                    _buildFieldLabel('Education & Certificates'),
                    TextFormField(controller: _educationController, maxLines: 2, decoration: const InputDecoration(hintText: 'Mention your degrees and certifications')),

                    _buildFieldLabel('Work Experience'),
                    TextFormField(controller: _experienceController, maxLines: 3, decoration: const InputDecoration(hintText: 'Describe your previous jobs or roles')),

                    _buildFieldLabel('Projects & Links'),
                    TextFormField(controller: _projectsController, maxLines: 2, decoration: const InputDecoration(hintText: 'Key projects you worked on')),

                    _buildFieldLabel('GitHub Link'),
                    TextFormField(controller: _githubController, decoration: const InputDecoration(hintText: 'https://github.com/profile')),
                    
                    _buildFieldLabel('LinkedIn Link'),
                    TextFormField(controller: _linkedinController, decoration: const InputDecoration(hintText: 'https://linkedin.com/in/profile')),

                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _generateCV,
                      child: const Text('GENERATE SMART CV ✨', style: TextStyle(letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
