// import 'package:flutter/material.dart';
// import 'package:lms/screens/admin/widgets/bottom.dart';
// import 'package:lms/screens/admin/widgets/mainmenu.dart';
// import 'package:lms/screens/admin/widgets/searchfiled.dart';
// import 'package:lms/screens/admin/widgets/usercard.dart';

// class AdminSidebar extends StatelessWidget {
//   final Function(String) onMenuItemSelected;
//   final TextEditingController searchController;
//   final bool isLargeScreen;

//   AdminSidebar({
//     required this.onMenuItemSelected,
//     required this.searchController,
//     required this.isLargeScreen,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final sidebarWidth = isLargeScreen ? 300.0 : MediaQuery.of(context).size.width * 0.8;

//     return Card(
//       elevation: 4,
//       child: Container(
//         color: Colors.white,
//         width: sidebarWidth,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: CustomScrollView(
//             physics: const ClampingScrollPhysics(),
//             slivers: [
//               SliverFillRemaining(
//                 hasScrollBody: false,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AdminUserCard(userId: 'userId'),
//                     const SizedBox(height: 20),
//                     AdminSearchField(searchController: searchController),
//                     const SizedBox(height: 20),
//                     Container(
//                       constraints: BoxConstraints(
//                         maxHeight: MediaQuery.of(context).size.height * 0.5,
//                       ),
//                       child: AdminMainMenu(
//                         isLargeScreen: isLargeScreen,
//                         onMenuItemSelected: onMenuItemSelected,
//                       ),
//                     ),
//                     const SizedBox(height: 90),
//                     Divider(),
//                     AdminBottom(
//                       onMenuItemSelected: onMenuItemSelected,
//                       isLargeScreen: isLargeScreen,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

