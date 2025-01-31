import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gtecgolsuperadmin/provider/super_adminauthprovider.dart';

class AdminUserCard extends StatefulWidget {
  final int? userId;

  AdminUserCard({this.userId});

  @override
  _AdminUserCardState createState() => _AdminUserCardState();
}

class _AdminUserCardState extends State<AdminUserCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<SuperAdminauthprovider>(context, listen: false);
      final userIdToFetch = widget.userId ?? authProvider.currentUserId;
      
      if (userIdToFetch != null) {
        authProvider.SuperfetchUserProfileProvider(userIdToFetch);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuperAdminauthprovider>(
      builder: (context, authProvider, _) {
        final userProfile = authProvider.userProfile;

        if (userProfile == null) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600], size: 24),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 10,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // User profile display
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        userProfile.profile.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.profile.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            userProfile.profile.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue[100]!,
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text(
                                  userProfile.profile.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                              // if (userProfile.profile.phoneNumber.isNotEmpty) ...[
                              //   SizedBox(width: 8),
                              //   Container(
                              //     decoration: BoxDecoration(
                              //       color: Colors.grey[100],
                              //       borderRadius: BorderRadius.circular(12),
                              //       border: Border.all(
                              //         color: Colors.grey[300]!,
                              //         width: 1,
                              //       ),
                              //     ),
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 12,
                              //       vertical: 4,
                              //     ),
                              //     child: Row(
                              //       mainAxisSize: MainAxisSize.min,
                              //       children: [
                              //         Icon(
                              //           Icons.phone,
                              //           size: 12,
                              //           color: Colors.grey[600],
                              //         ),
                              //         SizedBox(width: 4),
                              //         Text(
                              //           userProfile.profile.phoneNumber,
                              //           style: TextStyle(
                              //             fontSize: 12,
                              //             color: Colors.grey[600],
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ],
                            ],
                          ),
                        ],
                      ),
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
}