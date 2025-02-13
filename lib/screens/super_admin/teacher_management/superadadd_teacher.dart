import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:provider/provider.dart';

class superAdminTeacherPage extends StatefulWidget {
  final int courseId;
  final int batchId;

  const superAdminTeacherPage({
    Key? key,
    required this.courseId,
    required this.batchId,
  }) : super(key: key);

  @override
  State<superAdminTeacherPage> createState() => _superAdminTeacherPageState();
}

class _superAdminTeacherPageState extends State<superAdminTeacherPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<int> teachersInBatch = {};

  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
      provider.SuperAdminfetchallusersProvider();
      _fetchCurrentBatchTeachers();
    });
  }

  Future<void> _fetchCurrentBatchTeachers() async {
    final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
    try {
      await provider.superAdminfetchallteachersBatchProvider(
        widget.courseId,
        widget.batchId,
      );
      if (mounted) {
        setState(() {
          teachersInBatch = Set.from(
            (provider.batchteacherData?.teachers ?? [])
                .map((teacher) => teacher.teacherId)
          );
        });
      }
    } catch (e) {
      print('Error fetching batch teachers: $e');
    }
  }

  void _showActionConfirmation({
    required String title,
    required String message,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _assignTeacher(dynamic teacher) {
    _showActionConfirmation(
      title: 'Add to Batch',
      message: 'Are you sure you want to add ${teacher.name} to the batch?',
      onConfirm: () async {
        final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
        try {
          await provider.SuperassignUserToBatchProvider(
            courseId: widget.courseId,
            batchId: widget.batchId,
            userId: teacher.userId,
          );
          
          await _fetchCurrentBatchTeachers(); // Refresh the list
          
          _showSnackBar('${teacher.name} added to batch successfully!', isError: false);
        } catch (e) {
          _showSnackBar('Failed to add teacher: $e', isError: true);
        }
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teachers'),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: lightBlue,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search teachers...',
                prefixIcon: Icon(Icons.search, color: primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mediumBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: mediumBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryBlue, width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<SuperAdminauthprovider>(
              builder: (context, provider, child) {
                if (provider.users == null) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }

                if (provider.users!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: mediumBlue),
                        const SizedBox(height: 16),
                        Text(
                          'No teachers found',
                          style: TextStyle(
                            fontSize: 18,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final teachers = provider.users!.where((user) =>
                  user.role.toLowerCase() == 'teacher' &&
                  (user.name.toLowerCase().contains(searchQuery) ||
                   user.email.toLowerCase().contains(searchQuery))
                ).toList();

                return ListView.builder(
                  itemCount: teachers.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    final bool isInBatch = teachersInBatch.contains(teacher.userId);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: mediumBlue, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: primaryBlue,
                              child: Text(
                                teacher.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teacher.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    teacher.email,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 16,
                                        color: primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        teacher.phoneNumber,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.badge,
                                        size: 16,
                                        color: primaryBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        teacher.role,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: isInBatch
                                ? null
                                : () => _assignTeacher(teacher),
                              icon: const Icon(Icons.person_add),
                              label: Text(isInBatch ? 'Added' : 'Add teacher'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInBatch 
                                  ? Colors.grey
                                  : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}