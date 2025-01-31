import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gtecgolsuperadmin/models/admin_model.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';
import 'package:provider/provider.dart';

class QuizSubmissionPage extends StatefulWidget {
  final int quizId;
  final String title;

  const QuizSubmissionPage({
    Key? key, 
    required this.quizId,
    required this.title,
  }) : super(key: key);

  @override
  State<QuizSubmissionPage> createState() => _QuizSubmissionPageState();
}

class _QuizSubmissionPageState extends State<QuizSubmissionPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Match the color scheme from AdminAllUsersPage
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminAuthProvider>(context, listen: false)
            .fetchQuizSubmissions(widget.quizId));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Widget _buildStatusBadge(bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Text(
        isCorrect ? 'Correct' : 'Incorrect',
        style: TextStyle(
          color: isCorrect ? Colors.green[700] : Colors.red[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizSubmission submission) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: mediumBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(submission.questionText),
          const SizedBox(height: 16),
          Text(
            'Selected Answer:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(submission.selectedAnswer)),
              _buildStatusBadge(submission.isCorrect),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, List<QuizSubmission>> _groupSubmissionsByStudent(List<QuizSubmission> submissions) {
    final Map<String, List<QuizSubmission>> grouped = {};
    for (var submission in submissions) {
      if (!grouped.containsKey(submission.studentEmail)) {
        grouped[submission.studentEmail] = [];
      }
      grouped[submission.studentEmail]!.add(submission);
    }
    return grouped;
  }

  int _getCorrectAnswersCount(List<QuizSubmission> submissions) {
    return submissions.where((submission) => submission.isCorrect).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                hintText: 'Search students...',
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
            child: Consumer<AdminAuthProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }

                final submissions = provider.quizsubmissions[widget.quizId] ?? [];
                if (submissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: mediumBlue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No submissions found',
                          style: TextStyle(
                            fontSize: 18,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final groupedSubmissions = _groupSubmissionsByStudent(submissions);
                
                final filteredSubmissions = searchQuery.isEmpty
                    ? groupedSubmissions
                    : Map.fromEntries(
                        groupedSubmissions.entries.where((entry) {
                          final submissions = entry.value;
                          final studentName = submissions.first.studentName.toLowerCase();
                          final studentEmail = submissions.first.studentEmail.toLowerCase();
                          return studentName.contains(searchQuery) || 
                                 studentEmail.contains(searchQuery);
                        }),
                      );

                return RefreshIndicator(
                  color: primaryBlue,
                  onRefresh: () => provider.fetchQuizSubmissions(widget.quizId),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSubmissions.length,
                    itemBuilder: (context, index) {
                      final studentEmail = filteredSubmissions.keys.elementAt(index);
                      final studentSubmissions = filteredSubmissions[studentEmail]!;
                      final firstSubmission = studentSubmissions.first;
                      final correctCount = _getCorrectAnswersCount(studentSubmissions);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: mediumBlue, width: 1),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: primaryBlue,
                            child: Text(
                              firstSubmission.studentName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            firstSubmission.studentName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstSubmission.studentEmail,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getFormattedDate(firstSubmission.submittedAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Score: $correctCount/${studentSubmissions.length}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.quiz_outlined,
                                        size: 20,
                                        color: primaryBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Quiz Responses',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...studentSubmissions.map((submission) => 
                                    _buildQuestionCard(submission)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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