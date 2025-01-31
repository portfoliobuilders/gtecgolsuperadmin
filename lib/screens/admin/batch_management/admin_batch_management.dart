//  import 'package:flutter/material.dart';
// import 'package:lms/provider/authprovider.dart';
// import 'package:lms/screens/admin/batch_management/admin_batch_add.dart';
// import 'package:provider/provider.dart';
// class AdminAddBatch extends StatefulWidget {
//   const AdminAddBatch({Key? key}) : super(key: key);

//   @override
//   State<AdminAddBatch> createState() => _AdminAddBatchState();
// }

// class _AdminAddBatchState extends State<AdminAddBatch> {
//   int? selectedCourseId; 

//  // Variable to store selected course ID
//   void _showAddCourseDialog(BuildContext context) {
//     final TextEditingController _nameController = TextEditingController();
//     final TextEditingController _descriptionController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add Course'),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: 'Course Name'),
//                 ),
//                 TextField(
//                   controller: _descriptionController,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                   maxLines: 3,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String courseName = _nameController.text;
//                 String courseDescription = _descriptionController.text;

//                 if (courseName.isNotEmpty && courseDescription.isNotEmpty) {
//                   try {
//                     await Provider.of<AdminAuthProvider>(context, listen: false)
//                         .AdmincreateCourseprovider(courseName, courseDescription);
//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Course added successfully!')) ,
//                     );
//                   } catch (error) {
//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Failed to add course: $error')) ,
//                     );
//                   }
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please fill in all fields!')) ,
//                   );
//                 }
//               },
//               child: const Text('Add Course'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final courseProvider = Provider.of<AdminAuthProvider>(context);

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             bool isDesktop = constraints.maxWidth >= 1024;

//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Courses',
//                             style: Theme.of(context).textTheme.headlineSmall,
//                           ),
//                           Text(
//                             'Manage your courses here.',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium
//                                 ?.copyWith(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                       ElevatedButton(
//                         onPressed: () => _showAddCourseDialog(context),
//                         child: const Text('Create Course', style: TextStyle(color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Wrap(
//   spacing: 16,
//   runSpacing: 16,
//   children: courseProvider.course.map((course) {
//     return GestureDetector(
//       onTap: () {
//         // Navigate to the ModuleAddScreen with the selected courseId
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AdminBatchAddScreen(courseId: course.courseId, courseName: '',),
//           ),
//         );
//       },
//       child: Container(
//         width: 200,
//         child: Card(
//           elevation: 6,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(15),
//                   topRight: Radius.circular(15),
//                 ),
//                 child: Image.asset(
//                   'assets/golblack.png', // Placeholder image
//                   width: double.infinity,
//                   height: 100,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       course.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       course.description,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }).toList(),
// )

//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }