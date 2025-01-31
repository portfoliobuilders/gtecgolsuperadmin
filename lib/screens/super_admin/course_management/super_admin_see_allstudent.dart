import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';

class UsersTabView extends StatefulWidget {
  const UsersTabView({Key? key}) : super(key: key);

  @override
  _UsersTabViewState createState() => _UsersTabViewState();
}

class _UsersTabViewState extends State<UsersTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  bool isExpanded = false;
  List<List<String>> excelData = [];
  bool isFileUploaded = false;
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      final provider =
          Provider.of<SuperAdminauthprovider>(context, listen: false);
      provider.SuperAdminfetchallusersProvider();
      provider.SuperAdminfetchUnApprovedusersProvider();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleApproval(int userId, String role, String action) async {
    final provider =
        Provider.of<SuperAdminauthprovider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await provider.SuperadminApproveUserprovider(
        userId: userId,
        role: role,
        action: action,
      );
      if (mounted) {
        _showSnackBar(
          action == 'approve'
              ? 'User approved successfully'
              : 'User deleted successfully',
          isError: false,
        );
        provider.SuperAdminfetchallusersProvider();
        provider.SuperAdminfetchUnApprovedusersProvider();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    if (searchQuery.isEmpty) return users;
    return users.where((user) {
      final query = searchQuery.toLowerCase();
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      final phoneNumber = (user.phoneNumber?.toLowerCase() ?? '');

      return name.contains(query) ||
          email.contains(query) ||
          phoneNumber.contains(query);
    }).toList();
  }

  List<dynamic> _getApprovedUsers(
      List<dynamic>? allUsers, List<dynamic>? unapprovedUsers) {
    if (allUsers == null) return [];
    if (unapprovedUsers == null) return allUsers;

    final unapprovedIds = unapprovedUsers.map((u) => u.userId).toSet();
    return allUsers
        .where((user) => !unapprovedIds.contains(user.userId))
        .toList();
  }

  void _readExcelBytes(Uint8List bytes) {
    try {
      var excel = Excel.decodeBytes(bytes);
      List<List<String>> data = [];

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          data.add(row.map((cell) => cell?.value.toString() ?? '').toList());
        }
        break;
      }

      setState(() {
        excelData = data;
        isFileUploaded = true;
      });
    } catch (e) {
      _showSnackBar('Failed to read the Excel file: $e', isError: true);
    }
  }

  // Add this to your UsersTabView class
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.bytes != null) {
      try {
        var excel = Excel.decodeBytes(result.files.single.bytes!);
        List<List<String>> data = [];

        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows) {
            data.add(row.map((cell) => cell?.value.toString() ?? '').toList());
          }
          break; // Process only the first sheet
        }

        if (data.isEmpty) {
          _showSnackBar('Excel file is empty', isError: true);
          return;
        }

        // Navigate to preview page and wait for result
        final approved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ExcelPreviewPage(excelData: data),
          ),
        );

        // If approved successfully, refresh the user lists
        if (approved == true) {
          if (!mounted) return;
          final provider = Provider.of<SuperAdminauthprovider>(
            context,
            listen: false,
          );
          provider.SuperAdminfetchallusersProvider();
          provider.SuperAdminfetchUnApprovedusersProvider();
        }
      } catch (e) {
        _showSnackBar('Failed to read Excel file: $e', isError: true);
      }
    } else {
      _showSnackBar('No file selected', isError: true);
    }
  }

  Widget _buildUserList(List<dynamic> users, bool isLoading, String listType) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredUsers = _filterUsers(users);
    if (filteredUsers.isEmpty) {
      return _buildEmptyState(listType);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user, listType);
      },
    );
  }

  Widget _buildUserCard(dynamic user, String listType) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: primaryBlue,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildUserInfo(user),
                ],
              ),
            ),
            _buildActionButtons(user, listType),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(dynamic user) {
    return Row(
      children: [
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
          Icon(Icons.phone, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            user.phoneNumber!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
        ],
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            user.role.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(dynamic user, String listType) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (listType == 'unapproved')
          TextButton(
            onPressed: () => _handleApproval(
              user.userId,
              user.role,
              'approve',
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              minimumSize: const Size(80, 40),
              textStyle: const TextStyle(fontSize: 14),
            ),
            child: const Text('Approve'),
          ),
        TextButton(
          onPressed: () => _handleApproval(
            user.userId,
            user.role,
            'reject',
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            minimumSize: const Size(80, 40),
            textStyle: const TextStyle(fontSize: 14),
          ),
          child: Text(listType == 'unapproved' ? 'Reject' : 'Delete'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String listType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: mediumBlue),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? listType == 'unapproved'
                    ? 'No pending approvals'
                    : 'No approved users found'
                : 'No matching users found',
            style: TextStyle(
              fontSize: 18,
              color: primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcelDataPreview() {
    if (!isFileUploaded || excelData.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Preview of Uploaded Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: excelData.first
                .map((header) => DataColumn(label: Text(header)))
                .toList(),
            rows: excelData
                .skip(1)
                .map((row) => DataRow(
                    cells: row.map((cell) => DataCell(Text(cell))).toList()))
                .toList(),
          ),
        ),
        ElevatedButton(
          onPressed: () => _handleExcelDataUpload(),
          child: const Text('Approve'),
        ),
      ],
    );
  }

  Future<void> _handleExcelDataUpload() async {
    if (excelData.isEmpty || excelData.length <= 1) {
      _showSnackBar('No users data found to approve.', isError: true);
      return;
    }

    final List<Map<String, dynamic>> users = [];
    for (var i = 1; i < excelData.length; i++) {
      var row = excelData[i];
      users.add({
        "name": row[0],
        "email": row[1],
        "role": row[2],
        "password": row[3],
        "phoneNumber": row[4],
      });
    }

    try {
      final provider =
          Provider.of<SuperAdminauthprovider>(context, listen: false);
      await provider.SuperAdmincreateUsers(users);
      _showSnackBar('Users successfully created.');
    } catch (e) {
      _showSnackBar('Failed to create users: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allUsersProvider = Provider.of<SuperAdminauthprovider>(context);
    final approvedUsers = _getApprovedUsers(
      allUsersProvider.users,
      allUsersProvider.unapprovedUsers,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Users Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
          ),
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Approved Users'),
            Tab(text: 'Pending Approvals'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: lightBlue,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, color: primaryBlue),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: primaryBlue),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
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
                  borderSide: BorderSide(color: primaryBlue),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (allUsersProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: Column(
                children: [
                  _buildExcelDataPreview(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUserList(
                          approvedUsers,
                          isLoading,
                          'approved',
                        ),
                        _buildUserList(
                          allUsersProvider.unapprovedUsers ?? [],
                          isLoading,
                          'unapproved',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isExpanded) ...[
            FloatingActionButton(
              heroTag: "btn1",
              tooltip: "Upload Files",
              mini: true,
              onPressed: _uploadFile,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.upload, color: Colors.white),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "btn2",
              tooltip: "Create User",
              mini: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserRegistrationPage(),
                  ),
                );
              },
              backgroundColor: const Color.fromARGB(255, 31, 175, 214),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: "main",
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            backgroundColor: Colors.blue,
            child: Icon(isExpanded ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }
}

class ExcelPreviewPage extends StatefulWidget {
  final List<List<String>> excelData;

  const ExcelPreviewPage({
    Key? key,
    required this.excelData,
  }) : super(key: key);

  @override
  State<ExcelPreviewPage> createState() => _ExcelPreviewPageState();
}

class _ExcelPreviewPageState extends State<ExcelPreviewPage> {
  bool isLoading = false;

  Future<void> _handleExcelDataUpload() async {
    if (widget.excelData.isEmpty || widget.excelData.length <= 1) {
      _showSnackBar('No users data found to approve.', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final List<Map<String, dynamic>> users = [];
      for (var i = 1; i < widget.excelData.length; i++) {
        var row = widget.excelData[i];
        // Validate row data
        if (row.length < 5) {
          throw Exception('Invalid data format in row $i');
        }
        users.add({
          "name": row[0],
          "email": row[1],
          "role": row[2],
          "password": row[3],
          "phoneNumber": row[4],
        });
      }

      final provider =
          Provider.of<SuperAdminauthprovider>(context, listen: false);
      await provider.SuperAdmincreateUsers(users);

      if (mounted) {
        _showSnackBar('Users successfully created.');
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to create users: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Data Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        backgroundColor: Colors.blueAccent, // Blue color for the app bar
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Processing users data...',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.excelData.length - 1} Users Found',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please review the data before approving',
                                style: TextStyle(
                                  color: Colors.blueGrey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: widget.excelData.first
                                .map((header) => DataColumn(
                                      label: Text(
                                        header,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            rows: widget.excelData
                                .skip(1)
                                .map(
                                  (row) => DataRow(
                                    cells: row
                                        .map((cell) => DataCell(Text(cell)))
                                        .toList(),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Approve Button Container at bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleExcelDataUpload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent, // Blue button
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isLoading ? 'Processing...' : 'Approve All Users',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({Key? key}) : super(key: key);

  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> _registerUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _roleController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showSnackBar('All fields are required.', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = {
        "name": _nameController.text,
        "email": _emailController.text,
        "role": _roleController.text,
        "password": _passwordController.text,
        "phoneNumber": _phoneController.text,
      };

      final provider =
          Provider.of<SuperAdminauthprovider>(context, listen: false);
      await provider.SuperAdmincreateUsers([user]);

      if (mounted) {
        _showSnackBar('User successfully created.');
        _clearFields();
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to create user: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _roleController.clear();
    _passwordController.clear();
    _phoneController.clear();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Register User',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, 'Name', Icons.person),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  _buildTextField(_roleController, 'Role', Icons.badge),
                  _buildTextField(_passwordController, 'Password', Icons.lock,
                      isPassword: true),
                  _buildTextField(
                      _phoneController, 'Phone Number', Icons.phone),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
