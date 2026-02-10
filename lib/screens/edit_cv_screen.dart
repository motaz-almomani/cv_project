import 'package:cv_project/models/cv_model.dart';
import 'package:cv_project/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditCVScreen extends StatefulWidget {
  final CVModel? initialCV;
  const EditCVScreen({super.key, this.initialCV});

  @override
  State<EditCVScreen> createState() => _EditCVScreenState();
}

class _EditCVScreenState extends State<EditCVScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _summaryController;
  List<Experience> _experiences = [];
  List<Education> _education = [];
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialCV?.fullName);
    _emailController = TextEditingController(text: widget.initialCV?.email);
    _phoneController = TextEditingController(text: widget.initialCV?.phone);
    _addressController = TextEditingController(text: widget.initialCV?.address);
    _summaryController = TextEditingController(text: widget.initialCV?.summary);
    _experiences = widget.initialCV?.experiences ?? [];
    _education = widget.initialCV?.education ?? [];
    _skills = widget.initialCV?.skills ?? [];
  }

  void _addExperience() {
    setState(() {
      _experiences.add(Experience(company: '', role: '', duration: ''));
    });
  }

  void _addEducation() {
    setState(() {
      _education.add(Education(institution: '', degree: '', year: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit CV')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address')),
            TextFormField(controller: _summaryController, decoration: const InputDecoration(labelText: 'Professional Summary'), maxLines: 3),
            const Divider(),
            const Text('Experiences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._experiences.asMap().entries.map((entry) {
              int idx = entry.key;
              Experience exp = entry.value;
              return Column(
                children: [
                  TextFormField(
                    initialValue: exp.company,
                    decoration: const InputDecoration(labelText: 'Company'),
                    onChanged: (val) => _experiences[idx].company = val,
                  ),
                  TextFormField(
                    initialValue: exp.role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    onChanged: (val) => _experiences[idx].role = val,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
            ElevatedButton(onPressed: _addExperience, child: const Text('Add Experience')),
            const Divider(),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && user != null) {
                  CVModel cv = CVModel(
                    id: user.uid,
                    fullName: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                    summary: _summaryController.text,
                    experiences: _experiences,
                    education: _education,
                    skills: _skills,
                  );
                  await dbService.updateCV(user.uid, cv);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save CV'),
            ),
          ],
        ),
      ),
    );
  }
}
