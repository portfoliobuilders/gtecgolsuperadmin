import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:provider/provider.dart';

class AdminAllUsersPage extends StatefulWidget {
  const AdminAllUsersPage(
      {Key? key, required this.courseId, required this.batchId})
      : super(key: key);

  final int courseId;
  final int batchId;

  @override
  _AdminAllUsersPageState createState() => _AdminAllUsersPageState();
}

class _AdminAllUsersPageState extends State<AdminAllUsersPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<int> studentsInBatch = {};

  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
      provider.SuperAdminfetchallusersProvider();
      _fetchCurrentBatchStudents();
    });
  }

  Future<void> _fetchCurrentBatchStudents() async {
    final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
    try {
      await provider.SuperAdminfetchallusersBatchProvider(
        widget.courseId,
        widget.batchId,
      );
      setState(() {
        // Store the IDs of students already in the batch
        studentsInBatch = provider.students
            .map((student) => student.studentId)
            .toSet();
      });
    } catch (e) {
      print('Error fetching batch students: $e');
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

  void _assignUser(int userId) {
    _showActionConfirmation(
      title: 'Add to Batch',
      message: 'Are you sure you want to add this user to the batch?',
      onConfirm: () async {
        final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
        try {
          await provider.SuperassignUserToBatchProvider(
            courseId: widget.courseId,
            batchId: widget.batchId,
            userId: userId,
          );
          setState(() {
            studentsInBatch.add(userId);
          });
          _showSnackBar('User added to batch successfully!', isError: false);
        } catch (e) {
          _showSnackBar('Failed to add user: $e', isError: true);
        }
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuperAdminauthprovider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
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
                hintText: 'Search users...',
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
            child: provider.users == null
                ? Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                : provider.users!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: mediumBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.users!.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final user = provider.users![index];

                          if (!user.name.toLowerCase().contains(searchQuery) &&
                              !user.email.toLowerCase().contains(searchQuery)) {
                            return const SizedBox.shrink();
                          }

                          final bool isInBatch = studentsInBatch.contains(user.userId);

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
                                      user.name[0].toUpperCase(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
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
                                              user.phoneNumber,
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
                                              user.role,
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
                                      ? null  // Disable button if student is already in batch
                                      : () => _assignUser(user.userId),
                                    icon: const Icon(Icons.person_add),
                                    label: Text(isInBatch ? 'Added' : 'Add student'),
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
                      ),
          ),
        ],
      ),
    );
  }
}