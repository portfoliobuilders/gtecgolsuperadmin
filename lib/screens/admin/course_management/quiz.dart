import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/models/admin_model.dart';
import 'package:provider/provider.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';

class QuizCreatorScreen extends StatefulWidget {
  final int courseId;
  final int moduleId;
  final int batchId;
  final AdminQuizModel? quizToEdit;

  const QuizCreatorScreen({
    Key? key,
    required this.courseId,
    required this.moduleId,
    required this.batchId,
    this.quizToEdit,
  }) : super(key: key);

  @override
  _QuizCreatorScreenState createState() => _QuizCreatorScreenState();
}

class _QuizCreatorScreenState extends State<QuizCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> questions = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.quizToEdit != null) {
      _nameController.text = widget.quizToEdit!.name;
      _descriptionController.text = widget.quizToEdit!.description;
      
      // Create a deep copy of questions to prevent modifying original data
      questions = widget.quizToEdit!.questions.map((question) {
        return {
          "questionId": question.questionId,
          "text": question.text,
          "answers": question.answers.map((answer) => {
            "answerId": answer.answerId,
            "text": answer.text,
            "isCorrect": answer.isCorrect ?? false,
          }).toList(),
        };
      }).toList();
    }

    _nameController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _showSnackBar(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _addNewQuestion() {
    setState(() {
      questions.add({
        "text": "",
        "answers": List.generate(
          4,
          (index) => {
            "text": "",
            "isCorrect": false,
          },
        ),
      });
      _hasChanges = true;
    });
  }

  Future<void> _removeQuestion(int index) async {
    if (!mounted) return;

    final questionData = questions[index];
    final bool isExistingQuestion = questionData.containsKey('questionId');

    if (isExistingQuestion) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Question'),
          content: const Text(
            'Are you sure you want to delete this question? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

      if (confirm == true) {
        try {
          final provider = Provider.of<AdminAuthProvider>(context, listen: false);
          await provider.deleteQuestionProvider(
            quizId: widget.quizToEdit!.quizId,
            questionId: questionData['questionId'],
          );
          
          setState(() {
            questions.removeAt(index);
            _hasChanges = true;
          });
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete question: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // For new questions, just remove from the list
      setState(() {
        questions.removeAt(index);
        _hasChanges = true;
      });
    }
  }

  void _updateQuestionText(int questionIndex, String text) {
    setState(() {
      questions[questionIndex]["text"] = text;
      _hasChanges = true;
    });
  }

  void _updateAnswerText(int questionIndex, int answerIndex, String text) {
    setState(() {
      questions[questionIndex]["answers"][answerIndex]["text"] = text;
      _hasChanges = true;
    });
  }

  void _updateCorrectAnswer(int questionIndex, int answerIndex, bool value) {
    setState(() {
      for (var answer in questions[questionIndex]["answers"]) {
        answer["isCorrect"] = false;
      }
      questions[questionIndex]["answers"][answerIndex]["isCorrect"] = value;
      _hasChanges = true;
    });
  }

  bool _validateQuestions() {
    if (questions.isEmpty) {
      _showSnackBar('Please add at least one question', true);
      return false;
    }

    for (int i = 0; i < questions.length; i++) {
      var question = questions[i];
      if (question["text"].toString().trim().isEmpty) {
        _showSnackBar('Question ${i + 1} must have text', true);
        return false;
      }

      bool hasCorrectAnswer = false;
      bool hasEmptyAnswer = false;

      for (var answer in question["answers"]) {
        if (answer["text"].toString().trim().isEmpty) {
          hasEmptyAnswer = true;
        }
        if (answer["isCorrect"]) {
          hasCorrectAnswer = true;
        }
      }

      if (hasEmptyAnswer) {
        _showSnackBar('All answers in question ${i + 1} must have text', true);
        return false;
      }

      if (!hasCorrectAnswer) {
        _showSnackBar('Question ${i + 1} must have one correct answer', true);
        return false;
      }
    }

    return true;
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate() || !_validateQuestions()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);

      if (widget.quizToEdit != null) {
        await provider.updateQuizProvider(
          quizId: widget.quizToEdit!.quizId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          questions: questions,
        );
        _showSnackBar('Quiz updated successfully!', false);
      } else {
        await provider.createQuizProvider(
          batchId: widget.batchId,
          courseId: widget.courseId,
          moduleId: widget.moduleId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          questions: questions,
        );
        _showSnackBar('Quiz created successfully!', false);
      }

      await provider.fetchQuizzesForModuleProvider(
        widget.courseId,
        widget.moduleId,
      );

      setState(() {
        _hasChanges = false;
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(
        widget.quizToEdit != null ? 'Error updating quiz: $e' : 'Error creating quiz: $e',
        true
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
// ... (previous code remains the same until the build method)

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.quizToEdit != null ? 'Edit Quiz' : 'Create Quiz',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Quiz Details Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue[100]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.quizToEdit != null ? 'Edit Quiz Details' : 'Quiz Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Quiz Name',
                          prefixIcon: Icons.quiz,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a quiz name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          prefixIcon: Icons.description,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a quiz description';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Questions Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue[100]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Questions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _addNewQuestion,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Question'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (questions.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 48,
                                    color: Colors.blue[200],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No questions added yet',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Click "Add Question" to start creating your quiz',
                                    style: TextStyle(
                                      color: Colors.blue[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ...questions.asMap().entries.map((entry) {
                          int index = entry.key;
                          var question = entry.value;
                          return _buildQuestionCard(index, question);
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                if (questions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isLoading
                            ? 'Saving...'
                            : (widget.quizToEdit != null ? 'Update Quiz' : 'Save Quiz'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Question ${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeQuestion(index),
                  color: Colors.red[400],
                  tooltip: 'Delete Question',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              initialValue: question["text"],
              label: 'Question Text',
              prefixIcon: Icons.help_outline,
              onChanged: (text) => _updateQuestionText(index, text),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the question text';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Answers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              question["answers"].length,
              (answerIndex) => _buildAnswerField(index, answerIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerField(int questionIndex, int answerIndex) {
    final answer = questions[questionIndex]["answers"][answerIndex];
    String optionLetter = String.fromCharCode(65 + answerIndex); // A, B, C, D

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
        color: answer["isCorrect"] ? Colors.green[50] : Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: answer["isCorrect"] ? Colors.green[100] : Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              optionLetter,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: answer["isCorrect"] ? Colors.green[700] : Colors.blue[700],
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: answer["text"],
              decoration: InputDecoration(
                hintText: 'Enter answer',
                hintStyle: TextStyle(color: Colors.blue[200]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (text) => _updateAnswerText(questionIndex, answerIndex, text),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the answer text';
                }
                return null;
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: answer["isCorrect"],
                  onChanged: (value) => _updateCorrectAnswer(
                    questionIndex,
                    answerIndex,
                    value ?? false,
                  ),
                  activeColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'Correct',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    IconData? prefixIcon,
    int maxLines = 1,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.blue[700],
          fontSize: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Colors.blue[400],
                size: 20,
              )
            : null,
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[400]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}