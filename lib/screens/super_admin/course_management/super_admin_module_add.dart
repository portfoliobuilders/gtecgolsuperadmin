import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/models/super_admin_model.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/course_management/super_adminasignment_submission.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/course_management/super_adminquiz.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/course_management/super_adminquiz_submission.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminModuleAddScreen extends StatefulWidget {
  final int courseId;
  final int batchId;
  final String courseName;

  const AdminModuleAddScreen({
    Key? key,
    required this.courseId,
    required this.batchId,
    required this.courseName,
  }) : super(key: key);

  @override
  State<AdminModuleAddScreen> createState() => _AdminModuleAddScreenState();
}

class _AdminModuleAddScreenState extends State<AdminModuleAddScreen>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  SuperAdminModulemodel? selectedModule;
  bool isLoading = false;
  bool isFabMenuOpen = false;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      isFabMenuOpen = !isFabMenuOpen;
      if (isFabMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadModules();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  Future<void> _loadModules() async {
    await Provider.of<SuperAdminauthprovider>(context, listen: false)
        .SuperAdminfetchModulesForCourseProvider(widget.courseId, widget.batchId);
  }

 Future<void> _loadLessonsAndAssignmentsquiz() async {
    if (selectedModule != null) {
      final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);

      await provider.SuperAdminfetchLessonsForModuleProvider(
        widget.courseId,
        widget.batchId,
        selectedModule!.moduleId,
      );

      await provider.SuperfetchAssignmentForModuleProvider(
 
        widget.courseId,
               selectedModule!.moduleId,
      );
         await provider.SuperfetchQuizzesForModuleProvider(
   
      widget.courseId,
         selectedModule!.moduleId,
    );
    }

 
  }

  void _showEditAssignmentDialog(
      BuildContext context, SuperAssignmentModel assignment) {
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

                                  await provider.SuperAdminUpdateAssignment(
                                    widget.courseId,
                                    editAssignmentTitleController.text.trim(),
                                    editAssignmentDescriptionController.text
                                        .trim(),
                                    assignment.assignmentId,
                                    selectedModule!.moduleId,
                                  );

                                  Navigator.of(context).pop();

                                  // Refresh assignments
                                  await _loadLessonsAndAssignmentsquiz();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Assignment updated successfully!'),
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
                                    selectedModule!.moduleId,
                                  );

                                  Navigator.of(context).pop();

                                  await _loadLessonsAndAssignmentsquiz();

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

  void _showEditModuleDialog(BuildContext context, SuperAdminModulemodel module) {
    final TextEditingController editTitleController =
        TextEditingController(text: module.title);
    final TextEditingController editContentController =
        TextEditingController(text: module.content);
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
                'Edit Module',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editTitleController,
                      decoration: InputDecoration(
                        labelText: 'Module Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: editContentController,
                      decoration: InputDecoration(
                        labelText: 'Module Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
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

                                  await provider.SuperAdminUpdatemoduleprovider(
                                    widget.courseId,
                                    widget.batchId,
                                    editTitleController.text.trim(),
                                    editContentController.text.trim(),
                                    module.moduleId,
                                  );

                                  Navigator.of(context).pop();
                                  await _loadModules();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Module updated successfully!'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error updating module: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isUpdating = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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

  void _showCreateModuleDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    bool isCreating = false;

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
                'Create Module',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Module Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Module Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isCreating
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
                        onPressed: isCreating
                            ? null
                            : () async {
                                if (titleController.text.trim().isEmpty ||
                                    contentController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please fill all required fields'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isCreating = true;
                                });

                                try {
                                  final provider =
                                      Provider.of<SuperAdminauthprovider>(context,
                                          listen: false);

                                  await provider.SuperAdmincreatemoduleprovider(
                                    titleController.text.trim(),
                                    contentController.text.trim(),
                                    widget.courseId,
                                    widget.batchId,
                                  );

                                  Navigator.of(context).pop();
                                  await _loadModules();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Module created successfully!'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error creating module: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isCreating = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isCreating
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
                                'Create',
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

  Widget _buildModuleDropdown(List<SuperAdminModulemodel> modules) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              setState(() {
                isExpanded = !isExpanded;
              });
              if (selectedModule != null) {
                await _loadLessonsAndAssignmentsquiz();
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Module',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: modules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final module = modules[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: selectedModule?.moduleId == module.moduleId
                          ? Colors.blue.shade300
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedModule = module;
                        isExpanded = false;
                      });
                      _loadLessonsAndAssignmentsquiz();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: selectedModule?.moduleId == module.moduleId
                                  ? Colors.blue.shade100
                                  : Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedModule?.moduleId ==
                                          module.moduleId
                                      ? Colors.blue.shade900
                                      : Colors.blue.shade700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: selectedModule?.moduleId ==
                                            module.moduleId
                                        ? Colors.blue.shade900
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  module.content.isNotEmpty
                                      ? module.content
                                      : 'No description available',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedModule?.moduleId == module.moduleId)
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue.shade700,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedModuleCard(SuperAdminModulemodel module) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue.shade200, width: 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  module.content.isNotEmpty
                      ? module.content
                      : 'No module description provided',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.edit_note,
                  color: const Color.fromARGB(255, 0, 0, 0)),
              onPressed: () => _showEditModuleDialog(context, module),
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined,
                  color: const Color.fromARGB(255, 0, 0, 0)),
              onPressed: () => _handleDeleteModule(module),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDeleteModule(SuperAdminModulemodel module) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: const Text('Are you sure you want to delete this module?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final provider = Provider.of<SuperAdminauthprovider>(context, listen: false);
        await provider.Superadmindeletemoduleprovider(
          widget.courseId,
          widget.batchId,
          module.moduleId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module deleted successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete module: $error')),
        );
      }
    }
  }

  Widget _buildLessonsAndAssignmentsquizView() {
  if (selectedModule == null) return SizedBox.shrink();

  return Consumer<SuperAdminauthprovider>(
    builder: (context, provider, child) {

      final lessons = provider.SupergetLessonsForModule(selectedModule!.moduleId);
      final assignments = provider.SupergetAssignmentsForModule(selectedModule!.moduleId);
      final quiz = provider.getQuizForModule(selectedModule!.moduleId); 

      // Print the data to the terminal
      print('Lessons: $lessons');
      print('Assignments: $assignments');
      print('Quiz: $quiz');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lessons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildLessonsList(lessons),
          const SizedBox(height: 32),
          Text(
            'Assignments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAssignmentsList(assignments),
          Text(
            'Quiz',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuizList(quiz),
        ],
      );
    },
  );
}

Widget _buildQuizList(List<SuperAdminQuizModel> quiz) {
  if (quiz.isEmpty) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.quiz, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No quiz available',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: quiz.length,
    itemBuilder: (context, index) {
      final quizItem = quiz[index];
      return Card(
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.orange.shade100),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            child: Icon(Icons.quiz, color: Colors.orange),
          ),
          title: Text(
            quizItem.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(quizItem.description),
              SizedBox(height: 4),
              // Text(
              //   'Created At: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(quizItem.))}',
              //   style: TextStyle(
              //     color: Colors.blue,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_note, color: const Color.fromARGB(255, 0, 0, 0)),
                onPressed: () {
                  // Add your edit quiz logic here
                  _showEditQuizDialog(context, quizItem);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.black),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Quiz'),
                        content: const Text('Are you sure you want to delete this quiz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    try {
                      // Your logic for deleting quiz
                      await _deleteQuiz(quizItem.quizId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quiz deleted successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete quiz: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),

              ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizSubmissionPage(
                              quizId: quizItem.quizId,
                              ),
                        ),
                      );
                    },
                    child: Text("View Submissions")),

            ],
          ),
        ),
      );
    },
  );
}

// Show Edit Dialog for Quiz
void _showEditQuizDialog(BuildContext context, SuperAdminQuizModel quiz) {
  // Implement your edit dialog logic here
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Quiz: ${quiz.name}'),
        content: Column(
          children: [
            TextField(
              controller: TextEditingController(text: quiz.name),
              decoration: InputDecoration(labelText: 'Quiz Name'),
            ),
            TextField(
              controller: TextEditingController(text: quiz.description),
              decoration: InputDecoration(labelText: 'Description'),
            ),
            // Add other fields if needed (like questions, etc.)
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle update logic
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

// Function to delete a quiz (You can modify it as needed for your backend)
Future<void> _deleteQuiz(int quizId) async {
  // Your logic for deleting a quiz
  print('Deleted quiz with ID: $quizId');
}

  Widget _buildLessonsList(List<SuperAdminLessonmodel> lessons) {
    if (lessons.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.menu_book, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No lessons available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue.shade100),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text('${index + 1}'),
            ),
            title: Text(
              lesson.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(lesson.content),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_note),
                  onPressed: () => _showEditLessonDialog(context, lesson),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Lesson'),
                          content: const Text(
                              'Are you sure you want to delete this lesson?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      try {
                        await Provider.of<SuperAdminauthprovider>(context,
                                listen: false)
                            .Superadmindeletelessonprovider(
                          widget.courseId,
                          widget.batchId,
                          selectedModule!.moduleId,
                          lesson.lessonId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Lesson deleted successfully!')),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to delete lesson: $error')),
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
    );
  }

  Widget _buildAssignmentsList(List<SuperAssignmentModel> assignments) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.assignment, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No assignments available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.shade100),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.assignment, color: Colors.green),
            ),
            title: Text(
              assignment.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment.description),
                SizedBox(height: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_note,
                      color: const Color.fromARGB(255, 0, 0, 0)),
                  onPressed: () =>
                      _showEditAssignmentDialog(context, assignment),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.black),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Assignment'),
                          content: const Text(
                              'Are you sure you want to delete this assignment?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
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

                        await Provider.of<SuperAdminauthprovider>(context,
                                listen: false)
                            .Superadmindeleteassignmentprovider(
                          assignment.assignmentId,
                          widget.courseId,
                          selectedModule!.moduleId,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Assignment deleted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        await  _buildLessonsAndAssignmentsquizView();
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to delete assignment: $error'),
                            backgroundColor: Colors.red,
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
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmissionPage(
                              assignmentId: assignment.assignmentId
                              ),
                        ),
                      );
                    },
                    child: Text("View Submissions")),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Module Management', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<SuperAdminauthprovider>(
              builder: (context, provider, child) {
                final modules = provider.SupergetModulesForCourse(widget.courseId);

                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              Colors.lightBlue, // Set your desired border color
                          width: 1, // Set your desired border width
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Aligns content to the left
                        children: [
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0), // Adjust horizontal padding
                            child: Text(
                              'MODULES',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign
                                  .left, // Ensures the text is left-aligned
                            ),
                          ),
                          SizedBox(height: 8),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildModuleDropdown(modules),
                                if (selectedModule != null)
                                  _buildSelectedModuleCard(selectedModule!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (selectedModule != null)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors
                                .lightBlue, // Set your desired border color
                            width: 1, // Set your desired border width
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Aligns content to the left
                          children: [
                            SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      16.0), // Adjust horizontal padding
                              child: Text(
                                'MODULE CONTENT',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign
                                    .left, // Ensures the text is left-aligned
                              ),
                            ),
                            SizedBox(height: 8),
                            Divider(),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child:  _buildLessonsAndAssignmentsquizView(),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create Module Button (always visible)
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tooltip(
                message: 'Create Module',
                child: FloatingActionButton.small(
                  heroTag: 'createModule',
                  onPressed: () {
                    _showCreateModuleDialog(context);
                    _toggleFabMenu();
                  },
                  backgroundColor: Colors.blue[700],
                  child: const Icon(
                    Icons.create_new_folder,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          if (selectedModule != null) ...[
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tooltip(
                  message: 'Create Quiz',
                  child: FloatingActionButton.small(
                    heroTag: 'createQuiz',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizCreatorScreen(
                            moduleId: selectedModule!.moduleId,
                            courseId: widget.courseId,
                            batchId: widget.batchId,
                          ),
                        ),
                      );
                      _toggleFabMenu();
                    },
                    backgroundColor: Colors.orange,
                    child: const Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tooltip(
                  message: 'Create Assignment',
                  child: FloatingActionButton.small(
                    heroTag: 'createAssignment',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _CreateAssignmentDialog(
                          moduleId: selectedModule!.moduleId,
                          courseId: widget.courseId,
                        ),
                      );
                      _toggleFabMenu();
                    },
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tooltip(
                  message: 'Create Lesson',
                  child: FloatingActionButton.small(
                    heroTag: 'createLesson',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _CreateLessonDialog(
                          courseId: widget.courseId,
                          batchId: widget.batchId,
                          moduleId: selectedModule!.moduleId,
                        ),
                      );
                      _toggleFabMenu();
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(
                      Icons.note_add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Main FAB
          FloatingActionButton(
            heroTag: 'mainFab',
            onPressed: _toggleFabMenu,
            backgroundColor: Colors.blue,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animationController,
              color: Colors.white,
            ),
          ),
        ],
      ),
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

      Navigator.of(context).pop(); 
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
                  dueDateController.text =
                      picked.toIso8601String().split('T')[0];
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
