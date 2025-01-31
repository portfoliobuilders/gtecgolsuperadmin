import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:provider/provider.dart';


class QuizSubmissionPage extends StatefulWidget {
  final int quizId;

  const QuizSubmissionPage({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizSubmissionPage> createState() => _QuizSubmissionPageState();
}

class _QuizSubmissionPageState extends State<QuizSubmissionPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<SuperAdminauthprovider>(context, listen: false).SuperfetchQuizSubmissions(widget.quizId));
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Submissions')),
      body: Consumer<SuperAdminauthprovider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final submissions = provider.quizsubmissions[widget.quizId] ?? [];
          if (submissions.isEmpty) {
            return const Center(child: Text('No submissions found'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.SuperfetchQuizSubmissions(widget.quizId),
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
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(submission.studentName[0].toUpperCase()),
                    ),
                    title: Text(submission.studentName),
                    subtitle: Text(_getFormattedDate(submission.submittedAt)),
                    trailing: Text(
                      submission.status.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
