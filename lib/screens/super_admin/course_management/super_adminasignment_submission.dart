import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class SubmissionPage extends StatefulWidget {
  final int assignmentId;

  const SubmissionPage({Key? key, required this.assignmentId}) : super(key: key);

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => 
      Provider.of<SuperAdminauthprovider>(context, listen: false)
        .SuperfetchSubmissions(widget.assignmentId)
    );
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Widget _buildStatusBadge(String status) {
    final isCompleted = status.toLowerCase() == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isCompleted ? Colors.green[700] : Colors.orange[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubmissionDetails(BuildContext context, dynamic submission) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (submission.content.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.description_outlined, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Submission Content',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(submission.content),
            ),
            const Divider(height: 32),
          ],
          
          // Student Information Section
          Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                'Student Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow(Icons.email_outlined, 'Email', submission.studentEmail),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today_outlined, 
            'Submitted', 
            _getFormattedDate(submission.submittedAt)
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.update_outlined, 
            'Last Updated', 
            _getFormattedDate(submission.updatedAt)
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Submissions'),
        elevation: 0,
      ),
      body: Consumer<SuperAdminauthprovider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Changed this line to get submissions instead of fetching them
          final submissions = provider.SupergetSubmissionsForAssignment(widget.assignmentId);

          // Check if submissions is null or empty
          if (submissions == null || submissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No submissions found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no submissions for this assignment yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.SuperfetchSubmissions(widget.assignmentId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        submission.studentName[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      submission.studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      _getFormattedDate(submission.submittedAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    trailing: _buildStatusBadge(submission.status),
                    children: [
                      _buildSubmissionDetails(context, submission),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}