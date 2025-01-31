import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/screens/admin/batch_management/admin_add_tobatch.dart';
import 'package:provider/provider.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';

class AdminCreateBatchScreen extends StatefulWidget {
  final int courseId;

  const AdminCreateBatchScreen({Key? key, required this.courseId})
      : super(key: key);

  @override
  State<AdminCreateBatchScreen> createState() => _AdminCreateBatchScreenState();
}

class _AdminCreateBatchScreenState extends State<AdminCreateBatchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminAuthProvider>(context, listen: false)
          .AdminfetchBatchForCourseProvider(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Batches'),
      ),
      body: Consumer<AdminAuthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final batches = provider.courseBatches[widget.courseId] ?? [];
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (batches.isEmpty)
                    const Text('No batches available.')
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: batches.map((batch) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminAllUsersPage(
                                  courseId: widget.courseId,
                                  batchId: batch.batchId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 225,
                            height: 225,
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.blue,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 150,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      child: Image.asset(
                                        'assets/batch.jpg',
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12.0),
                                      bottomRight: Radius.circular(12.0),
                                    ),
                                    child: Container(
                                      color: Colors.blue[50],
                                      height: 65,
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            batch.batchName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Batch ID: ${batch.batchId}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
