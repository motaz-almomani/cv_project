import 'package:cv_project/models/cv_model.dart';
import 'package:cv_project/services/database_service.dart';
import 'package:cv_project/services/user_settings_service.dart';
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

  late String _pdfTemplate;

  List<Experience> _experiences = [];
  List<Education> _education = [];
  List<String> _courses = [];
  List<String> _skills = [];
  List<Project> _projects = [];
  List<Certificate> _certificates = [];

  static const _deep = Color(0xFF0F172A);
  static const _accent = Color(0xFF0EA5E9);

  @override
  void initState() {
    super.initState();
    _cvNameController = TextEditingController(text: widget.initialCV?.cvName ?? '');
    _nameController = TextEditingController(text: widget.initialCV?.fullName ?? '');
    _jobTitleController = TextEditingController(text: widget.initialCV?.jobTitle ?? '');
    _emailController = TextEditingController(text: widget.initialCV?.email ?? '');
    _phoneController = TextEditingController(text: widget.initialCV?.phone ?? '');
    _addressController = TextEditingController(text: widget.initialCV?.address ?? '');
    _summaryController = TextEditingController(text: widget.initialCV?.summary ?? '');
    _linkedinController = TextEditingController(text: widget.initialCV?.linkedin ?? '');
    _githubController = TextEditingController(text: widget.initialCV?.github ?? '');

    if (widget.initialCV != null) {
      final t = widget.initialCV!.pdfTemplate;
      _pdfTemplate = ['modern', 'classic', 'minimal'].contains(t) ? t : 'modern';
    } else {
      _pdfTemplate = 'modern';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.initialCV != null) return;
        final prefsTemplate = context.read<UserSettingsService>().defaultPdfTemplate;
        if (['modern', 'classic', 'minimal'].contains(prefsTemplate)) {
          setState(() => _pdfTemplate = prefsTemplate);
        }
      });
    }

    _experiences = List.from(widget.initialCV?.experiences ?? []);
    _education = List.from(widget.initialCV?.education ?? []);
    _courses = List.from(widget.initialCV?.courses ?? []);
    _skills = List.from(widget.initialCV?.skills ?? []);
    _projects = List.from(widget.initialCV?.projects ?? []);
    _certificates = List.from(widget.initialCV?.certificates ?? []);
  }

  @override
  void dispose() {
    _cvNameController.dispose();
    _nameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  void _addSkill() => setState(() => _skills.add(''));
  void _addCertificate() => setState(() => _certificates.add(Certificate(name: '', organization: '', type: 'Course')));
  void _addExperience() => setState(() => _experiences.add(Experience(company: '', role: '', duration: '')));
  void _addEducation() => setState(() => _education.add(Education(institution: '', degree: '', year: '')));
  void _addCourse() => setState(() => _courses.add(''));
  void _addProject() => setState(() => _projects.add(Project(name: '', description: '', link: '')));

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(
        label,
        style: const TextStyle(color: _deep, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final user = FirebaseAuth.instance.currentUser;
    final isEdit = widget.initialCV != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit CV' : 'New CV'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildFieldLabel('CV name'),
              TextFormField(
                controller: _cvNameController,
                decoration: const InputDecoration(hintText: 'e.g. Software engineer — UK version'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('PDF template'),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'modern', label: Text('Modern'), tooltip: 'Bold header & sections'),
                  ButtonSegment<String>(value: 'classic', label: Text('Classic'), tooltip: 'Centered, traditional'),
                  ButtonSegment<String>(value: 'minimal', label: Text('Minimal'), tooltip: 'Compact & clean'),
                ],
                selected: {_pdfTemplate},
                onSelectionChanged: (set) => setState(() => _pdfTemplate = set.first),
              ),
              const SizedBox(height: 8),
              const Divider(height: 32),

              _buildFieldLabel('Full name'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Your full name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('Target job title'),
              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(hintText: 'e.g. Flutter developer'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('Email'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'you@example.com'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('Phone'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '+1 …'),
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('Address'),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(hintText: 'City, country'),
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('GitHub'),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(hintText: 'https://github.com/…'),
              ),
              const SizedBox(height: 8),
              _buildFieldLabel('LinkedIn'),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(hintText: 'https://linkedin.com/in/…'),
              ),
              const SizedBox(height: 16),

              _buildFieldLabel('Skills'),
              ..._skills.asMap().entries.map((entry) {
                final idx = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.value,
                          decoration: InputDecoration(hintText: 'Skill ${idx + 1}'),
                          onChanged: (val) => _skills[idx] = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: _deep),
                        onPressed: () => setState(() => _skills.removeAt(idx)),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addSkill,
                icon: const Icon(Icons.add, color: _accent),
                label: const Text('Add skill', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
              ),

              _buildFieldLabel('Work experience'),
              ..._experiences.asMap().entries.map((entry) {
                final idx = entry.key;
                final exp = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: exp.company,
                          decoration: const InputDecoration(hintText: 'Company'),
                          onChanged: (val) => _experiences[idx].company = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: exp.role,
                          decoration: const InputDecoration(hintText: 'Role / title'),
                          onChanged: (val) => _experiences[idx].role = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: exp.duration,
                          decoration: const InputDecoration(hintText: 'Duration (e.g. 2020 — 2023)'),
                          onChanged: (val) => _experiences[idx].duration = val,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _experiences.removeAt(idx)),
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                            label: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444))),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add, color: _accent),
                label: const Text('Add experience', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
              ),

              _buildFieldLabel('Education'),
              ..._education.asMap().entries.map((entry) {
                final idx = entry.key;
                final ed = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: ed.institution,
                          decoration: const InputDecoration(hintText: 'School / university'),
                          onChanged: (val) => _education[idx].institution = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: ed.degree,
                          decoration: const InputDecoration(hintText: 'Degree or program'),
                          onChanged: (val) => _education[idx].degree = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: ed.year,
                          decoration: const InputDecoration(hintText: 'Year or range'),
                          onChanged: (val) => _education[idx].year = val,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _education.removeAt(idx)),
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                            label: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444))),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addEducation,
                icon: const Icon(Icons.add, color: _accent),
                label: const Text('Add education', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
              ),

              _buildFieldLabel('Courses'),
              ..._courses.asMap().entries.map((entry) {
                final idx = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.value,
                          decoration: InputDecoration(hintText: 'Course ${idx + 1}'),
                          onChanged: (val) => _courses[idx] = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: _deep),
                        onPressed: () => setState(() => _courses.removeAt(idx)),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addCourse,
                icon: const Icon(Icons.add, color: _accent),
                label: const Text('Add course', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
              ),

              _buildFieldLabel('Projects'),
              ..._projects.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: p.name,
                          decoration: const InputDecoration(hintText: 'Project name'),
                          onChanged: (val) => _projects[idx].name = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: p.description,
                          maxLines: 2,
                          decoration: const InputDecoration(hintText: 'Short description'),
                          onChanged: (val) => _projects[idx].description = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: p.link,
                          decoration: const InputDecoration(hintText: 'Link (optional)'),
                          onChanged: (val) => _projects[idx].link = val,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _projects.removeAt(idx)),
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                            label: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444))),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addProject,
                icon: const Icon(Icons.add, color: _accent),
                label: const Text('Add project', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
              ),

              _buildFieldLabel('Certificates & awards'),
              ..._certificates.asMap().entries.map((entry) {
                final idx = entry.key;
                final cert = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: cert.name,
                          decoration: const InputDecoration(hintText: 'Certificate name'),
                          onChanged: (val) => _certificates[idx].name = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: cert.organization,
                          decoration: const InputDecoration(hintText: 'Organization'),
                          onChanged: (val) => _certificates[idx].organization = val,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            children: ['University', 'Academic', 'Course'].map((t) {
                              final selected = cert.type == t;
                              return FilterChip(
                                label: Text(t),
                                selected: selected,
                                onSelected: (_) => setState(() => _certificates[idx].type = t),
                              );
                            }).toList(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _certificates.removeAt(idx)),
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                            label: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444))),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addCertificate,
                icon: const Icon(Icons.add, color: _accent),
                label: const Text('Add certificate', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
              ),

              _buildFieldLabel('Professional summary'),
              TextFormField(
                controller: _summaryController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Brief overview of your experience and goals…'),
              ),
              const SizedBox(height: 28),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || user == null) return;
                  final cv = CVModel(
                    id: widget.initialCV?.id ?? '',
                    userId: user.uid,
                    cvName: _cvNameController.text.trim(),
                    pdfTemplate: _pdfTemplate,
                    createdAtMs: widget.initialCV?.createdAtMs ?? 0,
                    updatedAtMs: widget.initialCV?.updatedAtMs ?? 0,
                    fullName: _nameController.text.trim(),
                    jobTitle: _jobTitleController.text.trim(),
                    email: _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    address: _addressController.text.trim(),
                    summary: _summaryController.text.trim(),
                    linkedin: _linkedinController.text.trim(),
                    github: _githubController.text.trim(),
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
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEdit ? 'Save changes' : 'Create CV'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
