
// import 'package:flutter/material.dart';
// import 'package:lms/screens/admin/widgets/sidebarbutton.dart';

// class AdminMainMenu extends StatefulWidget {
//   final Function(String) onMenuItemSelected;
//   final bool isLargeScreen;  // Accepting isLargeScreen

//   AdminMainMenu({required this.onMenuItemSelected, required this.isLargeScreen});

//   @override
//   _AdminMainMenuState createState() => _AdminMainMenuState();
// }

// class _AdminMainMenuState extends State<AdminMainMenu> {
//   String selectedMenu = '';

//   void updateSelectedMenu(String newMenu) {
//     setState(() {
//       selectedMenu = newMenu;
//     });
//     widget.onMenuItemSelected(newMenu);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(0, 0, 0, 9),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(
//           topRight: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//         color: const Color.fromARGB(255, 255, 255, 255),
//         boxShadow: [
//           BoxShadow(
//             color: const Color.fromARGB(255, 146, 218, 228).withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: Offset(2, 3),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
           
//             AdminSidebarButton(
//               icon: Icons.home,
//               text: 'Dashboard',
//               isSelected: selectedMenu == 'Dashboard',
//               onTap: () => updateSelectedMenu('Dashboard'),
//             ),
//               AdminSidebarButton(
//               icon: Icons.book,
//               text: 'Course Management',
//               isSelected: selectedMenu == 'Course Management',
//               onTap: () => updateSelectedMenu('Course Management'),
//             ),
//                 AdminSidebarButton(
//               icon: Icons.live_tv,
//               text: 'live',
//               isSelected: selectedMenu == 'live',
//               onTap: () => updateSelectedMenu('live'),
//             ),
//             AdminSidebarButton(
//               icon: Icons.people_sharp,
//               text: 'Students Manager',
//               isSelected: selectedMenu == 'Students Manager',
//               onTap: () => updateSelectedMenu('Students Manager'),
//             ),
//             AdminSidebarButton(
//               icon: Icons.person,
//               text: 'Our Centers',
//               isSelected: selectedMenu == 'Our Centers',
//               onTap: () => updateSelectedMenu('Our Centers'),
//             ),
//              AdminSidebarButton(
//             icon: Icons.settings,
//             text: 'Settings',
//             isSelected: selectedMenu == 'Settings',
//             onTap: () => updateSelectedMenu('Settings'),
//           ),
           
//           ],
//         ),
//       ),
//     );
//   }

//   ExpansionTile _buildExpandableTile({
//     required IconData icon,
//     required String title,
//     required bool isSelected,
//     required List<String> children,
//     required Function(String) onMenuItemSelected,
//     required bool isLargeScreen,
//   }) {
//     return ExpansionTile(
//       leading: Icon(icon, color: isSelected ? Colors.blue : Colors.blueGrey),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//           color: isSelected ? Colors.blue : const Color.fromARGB(136, 0, 0, 0),
//         ),
//       ),
//       initiallyExpanded: isLargeScreen || isSelected,
//       onExpansionChanged: (expanded) {
//         if (expanded) onMenuItemSelected(title);
//       },
//       tilePadding: EdgeInsets.symmetric(horizontal: 16),
//       children: children.map((item) {
//         return AdminSidebarButton(
//           icon: Icons.arrow_right,
//           text: item,
//           isSelected: false,
//           onTap: () => onMenuItemSelected(item),
//         );
//       }).toList(),
//     );
//   }
// }
