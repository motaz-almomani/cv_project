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
  late TextEditingController _cvNameController;
  late TextEditingController _nameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _summaryController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  
  List<Experience> _experiences = [];
  List<Education> _education = [];
  List<String> _courses = [];
  List<String> _skills = [];
  List<Project> _projects = [];
  List<Certificate> _certificates = [];

  @override
  void initState() {
    super.initState();
    _cvNameController = TextEditingController(text: widget.initialCV?.cvName);
    _nameController = TextEditingController(text: widget.initialCV?.fullName);
    _jobTitleController = TextEditingController(text: widget.initialCV?.jobTitle);
    _emailController = TextEditingController(text: widget.initialCV?.email);
    _phoneController = TextEditingController(text: widget.initialCV?.phone);
    _addressController = TextEditingController(text: widget.initialCV?.address);
    _summaryController = TextEditingController(text: widget.initialCV?.summary);
    _linkedinController = TextEditingController(text: widget.initialCV?.linkedin);
    _githubController = TextEditingController(text: widget.initialCV?.github);
    
    _experiences = List.from(widget.initialCV?.experiences ?? []);
    _education = List.from(widget.initialCV?.education ?? []);
    _courses = List.from(widget.initialCV?.courses ?? []);
    _skills = List.from(widget.initialCV?.skills ?? []);
    _projects = List.from(widget.initialCV?.projects ?? []);
    _certificates = List.from(widget.initialCV?.certificates ?? []);
  }

  void _addSkill() {
    setState(() {
      _skills.add('');
    });
  }

  void _addCertificate() {
    setState(() {
      _certificates.add(Certificate(name: '', organization: '', type: 'Course'));
    });
  }

  void _addExperience() {
    setState(() {
      _experiences.add(Experience(company: '', role: '', duration: ''));
    });
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF3A2D5F),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Editor'),
        backgroundColor: const Color(0xFF804A00),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA57164), Color(0xFFCD7F32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildFieldLabel('CV Name (Identity)'),
              TextFormField(
                controller: _cvNameController, 
                decoration: const InputDecoration(hintText: 'e.g. My Professional CV'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, thickness: 1.5),
              
              _buildFieldLabel('Full Name'),
              TextFormField(
                controller: _nameController, 
                decoration: const InputDecoration(hintText: 'Enter your full name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Target Job Title'),
              TextFormField(
                controller: _jobTitleController, 
                decoration: const InputDecoration(hintText: 'e.g. Flutter Developer'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('GitHub Link'),
              TextFormField(
                controller: _githubController, 
                decoration: const InputDecoration(hintText: 'https://github.com/yourprofile'),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('LinkedIn Link'),
              TextFormField(
                controller: _linkedinController, 
                decoration: const InputDecoration(hintText: 'https://linkedin.com/in/yourprofile'),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Skills'),
              ..._skills.asMap().entries.map((entry) {
                int idx = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.value,
                          decoration: InputDecoration(hintText: 'Skill #${idx + 1}'),
                          onChanged: (val) => _skills[idx] = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF3A2D5F)),
                        onPressed: () => setState(() => _skills.removeAt(idx)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addSkill,
                icon: const Icon(Icons.add, color: Color(0xFF3A2D5F)),
                label: const Text('Add Skill', style: TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Work Experiences'),
              ..._experiences.asMap().entries.map((entry) {
                int idx = entry.key;
                Experience exp = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: exp.company,
                          decoration: const InputDecoration(hintText: 'Company Name'),
                          onChanged: (val) => _experiences[idx].company = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: exp.role,
                          decoration: const InputDecoration(hintText: 'Job Role / Position'),
                          onChanged: (val) => _experiences[idx].role = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: exp.duration,
                          decoration: const InputDecoration(hintText: 'Duration (e.g. 2020 - 2022)'),
                          onChanged: (val) => _experiences[idx].duration = val,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _experiences.removeAt(idx)),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add, color: Color(0xFF3A2D5F)),
                label: const Text('Add Experience', style: TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Certificates & Awards'),
              ..._certificates.asMap().entries.map((entry) {
                int idx = entry.key;
                Certificate cert = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: cert.name,
                          decoration: const InputDecoration(hintText: 'Certificate Name'),
                          onChanged: (val) => _certificates[idx].name = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: cert.organization,
                          decoration: const InputDecoration(hintText: 'Organization/Issuer'),
                          onChanged: (val) => _certificates[idx].organization = val,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: cert.type,
                          decoration: const InputDecoration(hintText: 'Type'),
                          items: ['University', 'Academic', 'Course']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (val) => setState(() => _certificates[idx].type = val!),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _certificates.removeAt(idx)),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addCertificate,
                icon: const Icon(Icons.add, color: Color(0xFF3A2D5F)),
                label: const Text('Add Certificate', style: TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Professional Summary'),
              TextFormField(
                controller: _summaryController, 
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Write a brief about your career...'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A2D5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() && user != null) {
                    CVModel cv = CVModel(
                      id: widget.initialCV?.id ?? '',
                      userId: user.uid,
                      cvName: _cvNameController.text,
                      fullName: _nameController.text,
                      jobTitle: _jobTitleController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      address: _addressController.text,
                      summary: _summaryController.text,
                      linkedin: _linkedinController.text,
                      github: _githubController.text,
                      experiences: _experiences,
                      education: _education,
                      courses: _courses,
                      skills: _skills,
                      projects: _projects,
                      certificates: _certificates,
                    );
                    if (widget.initialCV == null) {
                      await dbService.addCV(cv);
                    } else {
                      await dbService.updateCV(widget.initialCV!.id, cv);
                    }
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('SAVE CHANGES', style: TextStyle(letterSpacing: 1.5)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
