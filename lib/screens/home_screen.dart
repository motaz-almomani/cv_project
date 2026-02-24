import 'package:cv_project/models/cv_model.dart';
import 'package:cv_project/screens/edit_cv_screen.dart';
import 'package:cv_project/screens/create_ai_cv_screen.dart';
import 'package:cv_project/services/auth_service.dart';
import 'package:cv_project/services/database_service.dart';
import 'package:cv_project/services/ai_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cv_project/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  Set<String> selectedCVs = {};
  bool isSelectionMode = false;

  void _showAnalysisDialog(BuildContext context, CVModel cv) async {
    final aiService = Provider.of<AIService>(context, listen: false);
    
    // 1. إظهار نافذة التحميل الاحترافية
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF3A2D5F),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Color(0xFFD4AF37)),
            SizedBox(height: 20),
            Text(
              "AI is analyzing your CV...",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Please wait a moment",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    try {
      // 2. طلب التحليل من AI
      final result = await aiService.analyzeCV(cv);
      
      if (mounted) Navigator.pop(context); // إغلاق نافذة التحميل

      final int score = result['score'];
      final String feedback = result['feedback'];
      final List<dynamic> tips = result['tips'] ?? [];

      if (mounted) {
        // 3. عرض النتيجة النهائية مع النصائح
        showDialog(
          context: context,
          builder: (context) {
            return FadeScaleAnimation(
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: const Color(0xFFF8F6F1),
                title: const Text(
                  "AI CV Analysis",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold),
                ),
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
                      Text(
                        "$score%",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3A2D5F)),
                      ),
                      const SizedBox(height: 10),
                      Text(feedback, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        "Improvement Tips ✨",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A2D5F)),
                      ),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Got it!", style: TextStyle(color: Color(0xFF3A2D5F), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // إغلاق التحميل في حال الخطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Analysis failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: isSelectionMode ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            isSelectionMode = false;
            selectedCVs.clear();
          }),
        ) : null,
        title: Text(isSelectionMode ? '${selectedCVs.length} selected' : 'MR.CV'),
        actions: isSelectionMode ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete CVs'),
                  content: Text('Delete ${selectedCVs.length} selected CVs?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                for (String id in selectedCVs) {
                  await dbService.deleteCV(id);
                }
                setState(() {
                  isSelectionMode = false;
                  selectedCVs.clear();
                });
              }
            },
          ),
        ] : [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search CVs...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF3A2D5F)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CVModel>>(
              stream: dbService.streamUserCVs(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }

                var cvs = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  cvs = cvs.where((cv) => cv.cvName.toLowerCase().contains(_searchQuery)).toList();
                }

                if (cvs.isEmpty) {
                  return const Center(
                    child: Text('No CVs found. Let\'s create one!', style: TextStyle(color: Colors.white70)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cvs.length,
                  itemBuilder: (context, index) {
                    final cv = cvs[index];
                    final isSelected = selectedCVs.contains(cv.id);
                    
                    return FadeScaleAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
                          onLongPress: () {
                            setState(() {
                              isSelectionMode = true;
                              selectedCVs.add(cv.id);
                            });
                          },
                          onTap: () {
                            if (isSelectionMode) {
                              setState(() {
                                if (selectedCVs.contains(cv.id)) {
                                  selectedCVs.remove(cv.id);
                                  if (selectedCVs.isEmpty) isSelectionMode = false;
                                } else {
                                  selectedCVs.add(cv.id);
                                }
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditCVScreen(initialCV: cv)),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF3A2D5F),
                                child: isSelected 
                                  ? const Icon(Icons.check, color: Color(0xFFD4AF37)) 
                                  : const Icon(Icons.description, color: Color(0xFFD4AF37)),
                              ),
                              title: Text(cv.cvName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(cv.jobTitle),
                              trailing: isSelectionMode
                                  ? Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: const Color(0xFFD4AF37))
                                  : IconButton(
                                      icon: const Icon(Icons.analytics, color: Color(0xFFD4AF37)),
                                      onPressed: () => _showAnalysisDialog(context, cv),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: isSelectionMode ? null : SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3A2D5F).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditCVScreen())),
                  icon: const Icon(Icons.add),
                  label: const Text("Create CV"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAICVScreen())),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("AI Magic ✨"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A2D5F),
                    foregroundColor: const Color(0xFFD4AF37),
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
