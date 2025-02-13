import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';
import 'package:provider/provider.dart';

class superTeachersListScreen extends StatefulWidget {
  final int courseId;
  final int batchId;

  const superTeachersListScreen({
    Key? key,
    required this.courseId,
    required this.batchId,
  }) : super(key: key);

  @override
  State<superTeachersListScreen> createState() => _superTeachersListScreenState();
}

class _superTeachersListScreenState extends State<superTeachersListScreen> {
  bool isLoading = true;
  String? error;
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      await Provider.of<AdminAuthProvider>(context, listen: false)
          .AdminfetchallteachersBatchProvider(widget.courseId, widget.batchId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _showRemoveConfirmation(BuildContext context, dynamic teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text('Remove Teacher'),
        content: Text('Are you sure you want to remove ${teacher.name} from this batch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<AdminAuthProvider>(context, listen: false);
                await provider.AdmindeleteUserFromBatchprovider(
                  courseId: widget.courseId,
                  batchId: widget.batchId,
                  userId: teacher.teacherId,
                );
                _loadTeachers(); // Reload the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${teacher.name} removed from batch'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove teacher: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Consumer<AdminAuthProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.batchteacherData?.batchName ?? 'Teachers List',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeachers,
          ),
        ],
      ),
      body: Container(
        color: lightBlue.withOpacity(0.3),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : error != null
                ? _buildErrorWidget()
                : Consumer<AdminAuthProvider>(
                    builder: (context, provider, child) {
                      final teachers = provider.batchteacherData?.teachers ?? [];
                      
                      if (teachers.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: teachers.length,
                        itemBuilder: (context, index) {
                          final teacher = teachers[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: mediumBlue, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: primaryBlue,
                                    child: Text(
                                      teacher.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                                      ],
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _showRemoveConfirmation(context, teacher),
                                    icon: const Icon(Icons.person_remove, color: Colors.red),
                                    label: const Text('Remove'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: mediumBlue),
          const SizedBox(height: 16),
          Text(
            'No teachers in this batch',
            style: TextStyle(fontSize: 18, color: primaryBlue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
