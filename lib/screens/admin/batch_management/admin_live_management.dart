import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gtecgolsuperadmin/models/admin_model.dart';
import 'package:provider/provider.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';

class AdminAddLiveCourse extends StatefulWidget {
  const AdminAddLiveCourse({Key? key}) : super(key: key);

  @override
  State<AdminAddLiveCourse> createState() => _AdminAddLiveCourseState();
}

class _AdminAddLiveCourseState extends State<AdminAddLiveCourse> {
  bool isCourseExpanded = false;
  bool isBatchExpanded = false;
  dynamic selectedCourse;
  dynamic selectedBatch;
  
  // Enhanced color palette
  final Color primaryBlue = const Color(0xFF1A73E8);
  final Color lightBlue = const Color(0xFFF3F8FF);
  final Color mediumBlue = const Color(0xFF82B1FF);
  final Color accentGreen = const Color(0xFF34A853);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Live Course Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lightBlue,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildCourseSection(provider),
                if (selectedCourse != null) ...[
                  const SizedBox(height: 36),
                  _buildBatchSection(provider),
                  if (selectedBatch != null) ...[
                    const SizedBox(height: 36),
                    LiveSessionManagement(
                      courseId: selectedCourse.courseId,
                      batchId: selectedBatch.batchId,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.video_camera_front, size: 32, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Session Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create and manage live sessions for your courses',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSection(AdminAuthProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, size: 24, color: primaryBlue),
              const SizedBox(width: 12),
              Text(
                'SELECT COURSE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdownSection(
            isExpanded: isCourseExpanded,
            selectedValue: selectedCourse?.name ?? 'Select Course',
            onTap: () {
              setState(() {
                isCourseExpanded = !isCourseExpanded;
              });
            },
          ),
          if (isCourseExpanded)
            _buildCourseList(provider)
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required bool isExpanded,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: mediumBlue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: lightBlue.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedValue,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selectedValue.contains('Select')
                      ? Colors.grey[600]
                      : Colors.black87,
                ),
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(AdminAuthProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.course.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final course = provider.course[index];
              final isSelected = selectedCourse?.courseId == course.courseId;
              return _buildListItem(
                title: course.name,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedCourse = course;
                    selectedBatch = null;
                    isCourseExpanded = false;
                    provider.AdminfetchBatchForCourseProvider(course.courseId);
                  });
                },
                icon: Icons.book_outlined,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBatchSection(AdminAuthProvider provider) {
    final batches = provider.courseBatches[selectedCourse.courseId] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups, size: 24, color: primaryBlue),
              const SizedBox(width: 12),
              Text(
                'SELECT BATCH',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdownSection(
            isExpanded: isBatchExpanded,
            selectedValue: selectedBatch?.batchName ?? 'Select Batch',
            onTap: () {
              setState(() {
                isBatchExpanded = !isBatchExpanded;
              });
            },
          ),
          if (isBatchExpanded)
            _buildBatchList(batches),
        ],
      ),
    );
  }

  Widget _buildBatchList(List<dynamic> batches) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: batches.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batches.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final batch = batches[index];
                    final isSelected = selectedBatch?.batchId == batch.batchId;
                    return _buildListItem(
                      title: batch.batchName,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedBatch = batch;
                          isBatchExpanded = false;
                        });
                      },
                      icon: Icons.group_outlined,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey[400], size: 24),
          const SizedBox(width: 12),
          Text(
            'No batches available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? lightBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryBlue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? primaryBlue : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryBlue : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: primaryBlue, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class LiveSessionManagement extends StatefulWidget {
  final int courseId;
  final int batchId;

  const LiveSessionManagement({
    Key? key,
    required this.courseId,
    required this.batchId,
  }) : super(key: key);

  @override
  State<LiveSessionManagement> createState() => _LiveSessionManagementState();
}

class _LiveSessionManagementState extends State<LiveSessionManagement> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _liveLinkController = TextEditingController();
  DateTime? _selectedDateTime;
  late Future<AdminLiveLinkResponse?> liveDataFuture;
  
  final Color primaryBlue = const Color(0xFF1A73E8);
  final Color lightBlue = const Color(0xFFF3F8FF);

  @override
  void initState() {
    super.initState();
    _refreshLiveData();
  }

  void _refreshLiveData() {
    setState(() {
      liveDataFuture = Provider.of<AdminAuthProvider>(context, listen: false)
          .AdminfetchLiveAdmin(widget.batchId);
    });
  }

  Widget _buildCreateSession() {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Live Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _liveLinkController,
              decoration: InputDecoration(
                labelText: 'Live Link',
                hintText: 'Enter the live session link',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.link, color: primaryBlue),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a live link' : null,
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: primaryBlue),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDateTime == null
                          ? 'Select Date and Time'
                          : DateFormat('MMM dd, yyyy HH:mm').format(_selectedDateTime!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDateTime == null ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: primaryBlue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedDateTime != null) {
                    try {
                      await context.read<AdminAuthProvider>().AdmincreateLivelinkprovider(
                            widget.batchId,
                            _liveLinkController.text,
                            _selectedDateTime!,
                          );
                      _refreshLiveData();
                      _liveLinkController.clear();
                      setState(() {
                        _selectedDateTime = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Live session created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating live session'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Live Session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSessionDetails(AdminLiveLinkResponse liveLink) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Live Session',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_note_outlined),
                    onPressed: () => _showEditDialog(liveLink),
                    color: primaryBlue,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: _deleteLiveLink,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailItem(
            icon: Icons.link,
            title: 'Live Link',
            content: liveLink.liveLink,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.access_time,
            title: 'Start Time',
            content: DateFormat('MMM dd, yyyy HH:mm')
                .format(liveLink.liveStartTime.toLocal()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.video_call_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Live Session',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new live session using the form above',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLiveLink() async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Live Session'),
            content: const Text('Are you sure you want to delete this live session?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context
                      .read<AdminAuthProvider>()
                      .AdmindeleteLiveprovider(widget.courseId,
                        widget.batchId);
                  _refreshLiveData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live session deleted successfully')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting live session: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditDialog(AdminLiveLinkResponse liveLink) async {
    final TextEditingController editLinkController =
        TextEditingController(text: liveLink.liveLink);
    DateTime? editDateTime = liveLink.liveStartTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Edit Live Session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: editLinkController,
                    decoration: InputDecoration(
                      labelText: 'Live Link',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.link, color: primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: editDateTime ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              editDateTime ?? DateTime.now()),
                        );
                        if (time != null) {
                          setState(() {
                            editDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: primaryBlue),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM dd, yyyy HH:mm').format(editDateTime!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Implement your update logic here
                      Navigator.of(context).pop();
                      _refreshLiveData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Live session updated successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating live session: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCreateSession(),
        FutureBuilder<AdminLiveLinkResponse?>(
          future: liveDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return _buildEmptyState();
            }

            return _buildLiveSessionDetails(snapshot.data!);
          },
        ),
      ],
    );
  }
}
