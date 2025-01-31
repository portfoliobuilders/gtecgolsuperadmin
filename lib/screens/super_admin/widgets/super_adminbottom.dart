import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/login/super_admin_login.dart';
import 'package:provider/provider.dart';

class AdminBottom extends StatefulWidget {
  final Function(String) onMenuItemSelected;
  final bool isLargeScreen;

  const AdminBottom({
    super.key,
    required this.onMenuItemSelected,
    required this.isLargeScreen,
  });

  @override
  _AdminBottomState createState() => _AdminBottomState();
}

class _AdminBottomState extends State<AdminBottom> {
  bool isLoading = false;

  Future<void> _logout(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      await Provider.of<SuperAdminauthprovider>(context, listen: false).Superlogout(); // Call the provider function
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuperAdminLoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue color for the button
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                ),
                elevation: 5, // Add some elevation for a shadow effect
              ),
              onPressed: isLoading ? null : () => _logout(context), // Disable the button when loading
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                  : const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text color
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
