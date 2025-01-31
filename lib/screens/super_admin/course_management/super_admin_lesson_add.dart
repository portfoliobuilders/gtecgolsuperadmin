import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/contants/super_admingtec_token.dart';
import 'package:gtecgolsuperadmin/models/super_admin_model.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/course_management/super_adminquiz.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminModuleLessonsScreen extends StatefulWidget {
  final int moduleId;
  final int courseId;
  final int batchId;
  final String moduleTitle;
  final String courseName;

  const AdminModuleLessonsScreen({
    Key? key,
    required this.moduleId,
    required this.courseId,
    required this.batchId,
    required this.moduleTitle,
    required this.courseName,
  }) : super(key: key);

  @override
  State<AdminModuleLessonsScreen> createState() =>
      _AdminModuleLessonsScreenState();
}

class _AdminModuleLessonsScreenState extends State<AdminModuleLessonsScreen> {
  bool isLoading = true;

  String? error;

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _loadAssignments();
  }

  Future<void> _showCreateAssignmentDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => _CreateAssignmentDialog(
        moduleId: widget.moduleId,
        courseId: widget.courseId,
      ),
    );

    if (result == true) {
      // Refresh assignments if creation was successful
      _loadAssignments();
    }
  }

  Future<void> _loadAssignments() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await Provider.of<SuperAdminauthprovider>(context, listen: false)
          .SupergetAssignmentsForModule(widget.moduleId);
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

  void _showEditAssignmentDialog(BuildContext context, SuperAssignmentModel assignment) {
  final TextEditingController editAssignmentTitleController =
      TextEditingController(text: assignment.title);
  final TextEditingController editAssignmentDescriptionController =
      TextEditingController(text: assignment.description);
  final TextEditingController editDueDateController = TextEditingController(
      text: assignment.dueDate.toIso8601String().split('T')[0]);
  bool isUpdating = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Edit Assignment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            content: SizedBox(
              width: 600, // Set desired dialog width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: editAssignmentTitleController,
                    decoration: InputDecoration(
                      labelText: 'Assignment Title*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: editAssignmentDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Assignment Content*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: editDueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isUpdating
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () async {
                              if (editAssignmentTitleController.text
                                      .trim()
                                      .isEmpty ||
                                  editAssignmentDescriptionController.text
                                      .trim()
                                      .isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please fill all required fields'),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isUpdating = true;
                              });

                              try {
                                final provider = Provider.of<SuperAdminauthprovider>(
                                    context,
                                    listen: false);

                                await provider.SuperAdminUpdateAssignment(
                                  widget.courseId,
                                  editAssignmentTitleController.text.trim(),
                                  editAssignmentDescriptionController.text
                                      .trim(),
                                  assignment.assignmentId,
                                  widget.moduleId,
                                );

                                Navigator.of(context).pop();

                                // Refresh assignments
                                await _loadAssignments();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Assignment updated successfully!'),  
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error updating assignment: ${e.toString()}'),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isUpdating = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}


  void _showEditLessonDialog(BuildContext context, SuperAdminLessonmodel lesson) {
    final TextEditingController editTitleController =
        TextEditingController(text: lesson.title);
    final TextEditingController editContentController =
        TextEditingController(text: lesson.content);
    final TextEditingController editVideoLinkController =
        TextEditingController(text: lesson.videoLink);
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Lesson',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600, // Set desired dialog width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editTitleController,
                      decoration: InputDecoration(
                        labelText: 'Lesson Title*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editContentController,
                      decoration: InputDecoration(
                        labelText: 'Lesson Content*',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editVideoLinkController,
                      decoration: InputDecoration(
                        labelText: 'Video Link (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isUpdating
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isUpdating
                            ? null
                            : () async {
                                if (editTitleController.text.trim().isEmpty ||
                                    editContentController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please fill all required fields'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isUpdating = true;
                                });

                                try {
                                  final provider =
                                      Provider.of<SuperAdminauthprovider>(context,
                                          listen: false);

                                  await provider.SuperAdminUpdatelessonprovider(
                                    widget.courseId,
                                    widget.batchId,
                                    editTitleController.text.trim(),
                                    editContentController.text.trim(),
                                    lesson.lessonId,
                                    widget.moduleId,
                                  );

                                  Navigator.of(context).pop();

                                  // Refresh lessons
                                  await _loadLessons();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Lesson updated successfully!'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error updating lesson: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isUpdating = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadLessons() async {
    try {
      await Provider.of<SuperAdminauthprovider>(context, listen: false)
          .SuperAdminfetchLessonsForModuleProvider(
              widget.courseId, widget.batchId, widget.moduleId);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showCreateLessonDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _CreateLessonDialog(
        courseId: widget.courseId,
        batchId: widget.batchId,
        moduleId: widget.moduleId,
      ),
    );

    // Refresh lessons after creating one
    _loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuperAdminauthprovider>(
      builder: (context, provider, child) {
        final lessons = provider.SupergetLessonsForModule(widget.moduleId);
        final assignments = provider.SuperfetchAssignmentForModuleProvider(
            widget.moduleId, widget.courseId);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue, // Set the color of the AppBar
            title:
                Text(widget.moduleTitle, style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white), // Back arrow icon
              onPressed: () {
                Navigator.pop(
                    context); // Pop the current screen from the navigation stack
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuizCreatorScreen(
                              moduleId: widget.moduleId,
                              courseId: widget.courseId,
                              batchId: widget.batchId,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white, // Text color of the button
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Button padding
                ),
                child: Text(
                  'Button', // Text of the button
                  style:
                      TextStyle(color: Colors.blue), // Text color of the button
                ),
              ),
              const SizedBox(
                  width: 16), // To add spacing after the button if needed
            ],
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lessons',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _showCreateAssignmentDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create Assignment',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                 ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => QuizCreatorScreen(
                                                moduleId: widget.moduleId,
                                                courseId: widget.courseId,
                                                batchId: widget.batchId,
                                              )),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create quiz',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _showCreateLessonDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Create Lesson',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Lessons List
                        lessons.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.menu_book,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No lessons available for this module',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: lessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = lessons[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 187, 234, 255),
                                        width: 2,
                                      ),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(16.0),
                                      title: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              (index + 1).toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lesson.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  lesson.content,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_note,
                                                color: Colors.black),
                                            onPressed: () =>
                                                _showEditLessonDialog(
                                                    context, lesson),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_sweep_outlined,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Delete Lesson'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this lesson?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await Provider.of<
                                                              SuperAdminauthprovider>(
                                                          context,
                                                          listen: false)
                                                      .Superadmindeletelessonprovider(
                                                    widget.courseId,
                                                    widget.batchId,
                                                    widget.moduleId,
                                                    lesson.lessonId,
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Lesson deleted successfully!')),
                                                  );
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Failed to delete lesson: $error')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        SizedBox(height: 16),
 Text(
                                'Assignments',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),                        SizedBox(height: 24),
                        if (isLoading)
                          Center(child: CircularProgressIndicator())
                        else if (error != null)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                SizedBox(height: 16),
                                Text(error!,
                                    style: TextStyle(color: Colors.red)),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadAssignments,
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else
                          Consumer<SuperAdminauthprovider>(
                            builder: (context, provider, child) {
                              final assignments = provider
                                  .SupergetAssignmentsForModule(widget.moduleId);

                              if (assignments.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.pending_actions,
                                          size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'No Assignments available for this module',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                             
                              

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: assignments.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final assignment = assignments[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 187, 234, 255),
                                        width: 2,
                                      ),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(16.0),
                                      title: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  assignment.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  assignment.description,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_note,
                                                color: Colors.black),
                                            onPressed: () =>
                                                _showEditAssignmentDialog(
                                                    context, assignment),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_sweep_outlined,
                                                color: Colors.black),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Delete Assignment'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this assignment?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                try {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  await Provider.of<
                                                              SuperAdminauthprovider>(
                                                          context,
                                                          listen: false)
                                                      .Superadmindeleteassignmentprovider(
                                                    assignment.assignmentId,
                                                    widget.courseId,
                                                    widget.moduleId,
                                                  );

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Assignment deleted successfully!'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );

                                                  await _loadAssignments();
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Failed to delete assignment: $error'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } finally {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _CreateLessonDialog extends StatefulWidget {
  final int courseId;
  final int batchId;
  final int moduleId;

  const _CreateLessonDialog({
    Key? key,
    required this.courseId,
    required this.batchId,
    required this.moduleId,
  }) : super(key: key);

  @override
  State<_CreateLessonDialog> createState() => _CreateLessonDialogState();
}

class _CreateLessonDialogState extends State<_CreateLessonDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();
  bool isCreatingLesson = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    videoLinkController.dispose();
    super.dispose();
  }

  Future<void> _createLesson() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isCreatingLesson = true);
    try {
      await Provider.of<SuperAdminauthprovider>(context, listen: false)
          .SuperAdmincreatelessonprovider(
        widget.courseId,
        widget.batchId,
        widget.moduleId,
        contentController.text,
        titleController.text,
        videoLinkController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson created successfully!')),
      );

      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating lesson: $e')),
      );
    } finally {
      setState(() => isCreatingLesson = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCreatingLesson = false; // Local state for loading indicator

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Create New Lesson',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 600, // Set desired dialog width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 20),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Lesson Title*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Lesson Content*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: videoLinkController,
              decoration: InputDecoration(
                labelText: 'Video Link (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed:
                    isCreatingLesson ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isCreatingLesson
                    ? null
                    : () async {
                        if (titleController.text.trim().isEmpty ||
                            contentController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isCreatingLesson = true;
                        });

                        try {
                          // Call the create lesson logic
                          await _createLesson();

                          // Refresh lessons to show the newly created lesson
                          await Provider.of<SuperAdminauthprovider>(context,
                                  listen: false)
                              .SuperAdminfetchLessonsForModuleProvider(
                                  widget.courseId,
                                  widget.batchId,
                                  widget.moduleId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lesson created successfully!'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error creating lesson: ${e.toString()}'),
                            ),
                          );
                        } finally {
                          setState(() {
                            isCreatingLesson = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isCreatingLesson
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _CreateAssignmentDialog extends StatefulWidget {
  final int moduleId;
  final int courseId;

  const _CreateAssignmentDialog({
    Key? key,
    required this.moduleId,
    required this.courseId,
  }) : super(key: key);

  @override
  State<_CreateAssignmentDialog> createState() =>
      _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<_CreateAssignmentDialog> {
  final TextEditingController assignmentTitleController =
      TextEditingController();
  final TextEditingController assignmentDescriptionController =
      TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  bool isCreatingAssignment = false;

  @override
  void dispose() {
    assignmentTitleController.dispose();
    assignmentDescriptionController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> _createAssignment() async {
    if (assignmentTitleController.text.isEmpty ||
        assignmentDescriptionController.text.isEmpty ||
        dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isCreatingAssignment = true);
    try {
      await Provider.of<SuperAdminauthprovider>(context, listen: false)
          .SupercreateAssignmentProvider(
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        title: assignmentTitleController.text.trim(),
        description: assignmentDescriptionController.text.trim(),
        dueDate: dueDateController.text.trim(),
      );

      Navigator.of(context).pop(); // Close the dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating assignment: $e')),
      );
    } finally {
      setState(() => isCreatingAssignment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Create New Assignment',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: 600, // Set desired dialog width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 20),
            TextFormField(
              controller: assignmentTitleController,
              decoration: InputDecoration(
                labelText: 'Assignment Title*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: assignmentDescriptionController,
              decoration: InputDecoration(
                labelText: 'Assignment Description*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: dueDateController,
              decoration: InputDecoration(
                labelText: 'Due Date*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  dueDateController.text = picked.toIso8601String().split('T')[0];
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isCreatingAssignment
                    ? null
                    : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isCreatingAssignment ? null : _createAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isCreatingAssignment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
