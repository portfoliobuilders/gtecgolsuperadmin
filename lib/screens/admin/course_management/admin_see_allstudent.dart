import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/authprovider.dart';
import 'package:provider/provider.dart';

class UsersTabView extends StatefulWidget {
  const UsersTabView({Key? key}) : super(key: key);

  @override
  _UsersTabViewState createState() => _UsersTabViewState();
}

class _UsersTabViewState extends State<UsersTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color mediumBlue = const Color(0xFF90CAF9);
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      provider.AdminfetchallusersProvider();
      provider.AdminfetchUnApprovedusersProvider();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleApproval(int userId, String role, String action) async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await provider.adminApproveUserprovider(
        userId: userId,
        role: role,
        action: action,
      );
      if (mounted) {
        _showSnackBar(
            action == 'approve'
                ? 'User approved successfully'
                : 'User deleted successfully',
            isError: false);
        // Refresh both lists after any action
        provider.AdminfetchallusersProvider();
        provider.AdminfetchUnApprovedusersProvider();
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

  @override
  Widget build(BuildContext context) {
    final allUsersProvider = Provider.of<AdminAuthProvider>(context);
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
            color: Colors.white
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color.fromARGB(
                255, 255, 255, 255), // Background color for the selected tab
          ),
          labelColor: Colors.blue[900], // Text color for the selected tab
          unselectedLabelColor: Colors.white, // Text color for unselected tabs
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          indicatorSize: TabBarIndicatorSize
              .tab, // Ensures the indicator fills the entire tab
          tabs: const [
            Tab(text: 'Approved Users'),
            Tab(text: 'Pending Approvals'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
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
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Approved Users Tab
                _buildUserList(
                  approvedUsers,
                  isLoading,
                  'approved',
                ),
                // Unapproved Users Tab
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
    );
  }

  Widget _buildUserList(List<dynamic> users, bool isLoading, String listType) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return _buildEmptyState(listType);
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
                // User Avatar
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
                // User Details
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
                      Row(
                        children: [
                          // Only show phone number if available
                          if (user.phoneNumber != null &&
                              user.phoneNumber!.isNotEmpty) ...[
                            Icon(
                              Icons.phone,
                              size: 12,
                              color: Colors.grey[600],
                            ),
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
                          // Role Badge
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
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (listType == 'unapproved') ...[
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
                    ],
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
                      child:
                          Text(listType == 'unapproved' ? 'Reject' : 'Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
}
