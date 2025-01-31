import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/contants/super_admingtec_token.dart';
import 'package:gtecgolsuperadmin/models/super_admin_model.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/login/super_admin_login.dart';
import 'package:gtecgolsuperadmin/screens/super_admin/super_admin_dashboard.dart';
import 'package:gtecgolsuperadmin/services/super_adminwebservice.dart';

class SuperAdminauthprovider with ChangeNotifier {

   final Map<int, SuperAdminLiveLinkResponse> _liveBatch = {};

  SuperAdminLiveLinkResponse? getLiveSessionForBatch(int batchId) {
    return _liveBatch[batchId];
  }
  String? _token;
  String? deleteMessage;
  bool isLoading = false;
  String? message;
  int? _currentUserId;
  List<SuperAdmincoursemodel> _course = []; // Correctly store courses

  int? courseId;

  int? assignmentId;
  final Map<int, List<SuperSubmission>> _submissions = {};

  List<SuperSubmission> get submissionsForAssignment =>
      _submissions[assignmentId] ?? [];
  List<dynamic> SupergetSubmissionsForAssignment(int assignmentId) {
    return _submissions[assignmentId] ?? [];
  }

  List<SuperAdmincoursemodel> get course => _course;

  Map<int, List<SuperQuizSubmission>> _quizsubmissions = {};
  Map<int, List<SuperQuizSubmission>> get quizsubmissions => _quizsubmissions;


  String? get token => _token;

  SuperBatchStudentModel? _batchData;

  // Getter for the batch data
  SuperBatchStudentModel? get batchData => _batchData;
  List<SuperStudent> get students => _batchData?.students ?? [];

  SuperUserProfileResponse? _userProfile;
  SuperUserProfileResponse? get userProfile => _userProfile;

  int? get currentUserId => _currentUserId;

  final SuperAdminAPI _apiService = SuperAdminAPI();

  Map<int, List<SuperAdminModulemodel>> _courseModules = {};

  Map<int, List<SuperAdminLessonmodel>> _moduleLessons = {};

  Map<int, List<SuperAdminLiveLinkResponse>> _livebatch = {};

  Map<int, List<SuperAdminQuizModel>> _moduleQuizzes = {};

  final Map<int, List<SuperAssignmentModel>> _moduleassignments = {};

  final Map<int, List<SuperAdminQuizModel>> _moduleQuiz = {};

  List<SuperAdminQuizModel> getQuizForModule(int moduleId) {
    return _moduleQuiz[moduleId] ?? [];
  }

  List<SuperAdminQuizModel> _quizzes = [];

  bool _isLoading = false;

  List<SuperAdminAllusersmodel> _users =
      []; // Add this line to define the _users variable

  List<SuperAdminAllusersmodel>? get users => _users;

  List<SuperUnapprovedUser> _unapprovedUsers = [];
  List<SuperUnapprovedUser>? get unapprovedUsers => _unapprovedUsers;

  final Map<int, List<SuperAdminCourseBatch>> _courseBatches =
      {}; // Map for storing course batches

  // Loading state

  Map<int, List<SuperAdminCourseBatch>> get courseBatches => _courseBatches;

  int? get batchId => null;

  get studentUsers => null;

  get getusers => null;
  List<SuperAdminModulemodel> SupergetModulesForCourse(courseId) {
    return _courseModules[courseId] ?? [];
  }

  List<SuperAdminLessonmodel> SupergetLessonsForModule(int moduleId) {
    return _moduleLessons[moduleId] ?? [];
  }

  List<SuperAssignmentModel> SupergetAssignmentsForModule(int moduleId) {
    return _moduleassignments[moduleId] ?? [];
  }

// Modify this method to return a Future<List<AdminLiveLinkResponse>> instead of just a list
  Future<List<SuperAdminLiveLinkResponse>> SupergetLiveForbatch(int batchId) async {
    if (_livebatch[batchId] == null) {
      await SuperadminfetchLiveAdmin(
          batchId); // Make sure the data is fetched
    }
    return _livebatch[batchId] ?? []; // Return the list of live links
  }

  // Superadmin login
  Future<void> Superadminloginprovider(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await _apiService.SuperloginAdminAPI(email, password);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];
        _currentUserId = responseData['userId'];

        // Save the token
        await saveToken(_token!);

        // Only fetch profile if we have a valid userId
        if (_currentUserId != null) {
          await SuperfetchUserProfileProvider(_currentUserId!);
        }

        // Rest of your login logic...
        await SuperAdminfetchCoursesprovider();
        await SuperAdminfetchUnApprovedusersProvider();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );

        notifyListeners();
      }
      // Rest of your error handling...
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred. Please check your details.')),
      );
    }
  }

  Future<void> SuperAdminregisterprovider(String email, String password, String name,
      String role, String phoneNumber) async {
    try {
      await _apiService.SuperAdminRegisterAPI(
          email, password, name, role, phoneNumber);
    } catch (e) {
      print('Error creating register: $e');
      throw Exception('Failed to create register');
    }
  }

  // Logout method
  Future<void> Superlogout() async {
    await clearToken();
    _token = null;
    notifyListeners();
  }

  // Check authentication and automatically fetch courses if authenticated
  Future<void> SuperAdmincheckAuthprovider(BuildContext context) async {
  _token = await getToken();

    // Check if the token exists (indicating the user is logged in)
    if (_token != null) {
      // Navigate to StudentLMSHomePage if the user is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
      );
    } else {
      // Navigate to UserLogin page if the user is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminLoginScreen()),
      );
    }
    notifyListeners();
  }

  // Fetch courses from the API
  Future<void> SuperAdminfetchCoursesprovider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      _course = await _apiService.SuperAdminfetchCoursesAPI(
          _token!); // Fetch courses correctly

      // Print the fetched courses to the terminal
      print('Fetched courses: $_course');

      notifyListeners(); // Notify listeners that courses are fetched
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  // Create a new course
  Future<void> SuperAdmincreateCourseprovider(
      String title, String description) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.SuperAdmincreateCourseAPI(title, description, _token!);
      await SuperAdminfetchCoursesprovider(); // Refresh the course list after creation
    } catch (e) {
      print('Error creating course: $e');
      throw Exception('Failed to create course');
    }
  }

  Future<void> SuperAdmindeleteCourseprovider(int courseId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.SuperdeleteAdminCourse(courseId, _token!);
      print(result); // Optionally print success message

      // After successful deletion, re-fetch the courses to update the list
      await SuperAdminfetchCoursesprovider();
    } catch (e) {
      print('Error deleting course: $e');
    }
  }

  Future<void> SuperAdminupdateCourse(
      int courseId, String title, String description) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.SuperAdminupdateCourseAPI(
        _token!,
        courseId,
        title,
        description,
      );
      await SuperAdminfetchCoursesprovider(); // Refresh the course list after update
    } catch (e) {
      print('Error updating course: $e');
      throw Exception('Failed to update course');
    }
  }

  Future<void> SuperAdminfetchModulesForCourseProvider(
      int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final modules = await _apiService.SuperAdminfetchModulesForCourseAPI(
          _token!, courseId, batchId);
      _courseModules[courseId] = modules;
      _courseModules[batchId] = modules;
      notifyListeners();
    } catch (e) {
      print('Error fetching modules for course: $e');
      throw Exception('Failed to fetch modules for course');
    }
  }

  Future<void> SuperAdmincreatemoduleprovider(
      String title, String content, int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating module for courseId: $courseId,$batchId');

      // Call API to create the module
      await _apiService.SuperAdmincreatemoduleAPI(
          _token!, courseId, batchId, title, content);

      print('Module creation successful. Fetching updated modules...');

      // Fetch updated modules after creation
      await SuperAdminfetchModulesForCourseProvider(courseId, batchId);

      print('Modules fetched successfully.');
    } catch (e) {
      print('Error creating module: $e');
      throw Exception('Failed to create module');
    }
  }

  Future<void> Superadmindeletemoduleprovider(
      int courseId, int batchId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.SuperdeleteAdminmodule(
          courseId, batchId, _token!, moduleId);
      print(result); // Optionally print success message

      if (_courseModules.containsKey(courseId)) {
        _courseModules[courseId]
            ?.removeWhere((module) => module.moduleId == moduleId);
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await SuperAdminfetchModulesForCourseProvider(courseId, batchId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> SuperAdminUpdatemoduleprovider(int courseId, int batchId,
      String title, String content, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.SuperAdminupdateModuleAPI(
          _token!, courseId, batchId, title, content, moduleId);
      await SuperAdminfetchModulesForCourseProvider(
          courseId, batchId); // Refresh the course list after update
    } catch (e) {
      print('Error updating module: $e');
      throw Exception('Failed to update module');
    }
  }

  Future<void> SuperAdminfetchLessonsForModuleProvider(
      int courseId, int batchId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final lessons = await _apiService.SuperAdminfetchLessonsForModuleAPI(
          _token!, courseId, batchId, moduleId);
      _moduleLessons[moduleId] = lessons;
      notifyListeners();
    } catch (e) {
      print('Error fetching lessons for module: $e');
      rethrow;
    }
  }

  Future<void> SuperAdmincreatelessonprovider(
    int courseId,
    int batchId,
    int moduleId,
    String content,
    String title,
    String videoLink,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating lesson for courseId: $courseId');
      print('Creating lesson for moduleId: $moduleId');

      // Call API to create the lesson
      await _apiService.SuperAdmincreatelessonseAPI(
        _token!,
        courseId,
        batchId,
        moduleId,
        content,
        title,
        videoLink,
      );

      print('Lesson creation successful. Fetching updated lessons...');

      // Fetch updated lessons after creation
      await SuperAdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);

      print('Lessons fetched successfully.');
    } catch (e) {
      print('Error creating lesson: $e');
      throw Exception('Failed to create lesson: $e');
    }
  }

  Future<void> Superadmindeletelessonprovider(
      int courseId, int batchId, int moduleId, int lessonId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.SuperdeleteAdminlesson(
          courseId, batchId, _token!, moduleId, lessonId);
      print(result); // Optionally print success message

      if (_courseModules.containsKey(courseId)) {
        _moduleLessons[moduleId]
            ?.removeWhere((lesson) => lesson.lessonId == lessonId);
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await SuperAdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> SuperAdminUpdatelessonprovider(int courseId, int batchId,
      String title, String content, int lessonId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.SuperAdminupdateLessonAPI(
        _token!,
        courseId,
        batchId,
        title,
        content,
        moduleId,
        lessonId,
      );

      // Refresh the lessons list
      await SuperAdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error updating lesson: $e');
      throw Exception('Failed to update lesson: $e');
    }
  }

  Future<void> SuperAdmincreateBatchprovider(String batchName, int courseId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating Batch for courseId: $courseId');

      // Call API to create the module
      await _apiService.SuperAdmincreatebatch(_token!, courseId, batchName);

      print('Batch creation successful. Fetching updated modules...');

      // Fetch updated modules after creation
      await SuperAdminfetchBatchForCourseProvider(courseId);

      print('Batch created successfully.');
    } catch (e) {
      print('Error creating Batch: $e');
      throw Exception('Failed to create Batch');
    }
  }

  Future<void> SuperAdminfetchBatchForCourseProvider(int courseId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      _isLoading = true; // Set loading to true
      notifyListeners(); // Notify listeners that the loading state has changed

      final Batches =
          await _apiService.SuperAdminfetctBatchForCourseAPI(_token!, courseId);
      _courseBatches[courseId] = Batches; // Store fetched batches

      _isLoading = false; // Set loading to false once data is fetched
      notifyListeners(); // Notify listeners that the loading state has changed
    } catch (e) {
      _isLoading = false; // Set loading to false if there’s an error
      notifyListeners(); // Notify listeners that the loading state has changed
      print('Error fetching batch for course: $e');
      throw Exception('Failed to fetch batch for course');
    }
  }

  Future<void> SuperAdminUpdatebatchprovider(
      int courseId, int batchId, String batchName) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.SuperAdminupdateBatchAPI(
          _token!, courseId, batchId, batchName);
      await SuperAdminfetchBatchForCourseProvider(
          courseId); // Refresh the course list after update
    } catch (e) {
      print('Error updating batch: $e');
      throw Exception('Failed to update batch');
    }
  }

  Future<void> SuperAdmindeleteBatchprovider(int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result =
          await _apiService.SuperdeleteAdminBatch(courseId, _token!, batchId);
      print(result); // Optionally print success message

      if (_courseBatches.containsKey(courseId)) {
        _courseBatches[courseId]
            ?.removeWhere((Batche) => Batche.batchId == batchId);
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await SuperAdminfetchModulesForCourseProvider(courseId, batchId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> SuperAdminfetchallusersProvider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      _users = await _apiService.SuperAdminfetchUsersAPI(_token!);

      // Print the fetched users to the terminal
      print('Fetched users: $_users');

      notifyListeners(); // Notify listeners that users are fetched
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> SuperassignUserToBatchProvider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.SuperAdminassignUserToBatch(
        token: _token!,
        courseId: courseId,
        batchId: batchId,
        userId: userId,
      );

      if (isSuccess) {
        print('User successfully assigned to batch.');
        notifyListeners(); // Notify listeners if needed
      }
    } catch (e) {
      print('Error assigning user to batch: $e');
    }
  }

  Future<void> SuperAdmindeleteUserFromBatchprovider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.SuperAdmindeleteUserFromBatch(
        token: _token!,
        courseId: courseId,
        batchId: batchId,
        userId: userId,
      );

      if (isSuccess) {
        print('User successfully assigned to batch.');
        notifyListeners(); // Notify listeners if needed
      }
    } catch (e) {
      print('Error assigning user to batch: $e');
    }
  }

  Future<void> SuperadminApproveUserprovider({
    required int userId,
    required String role,
    required String action, // 'approve' or 'reject'
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.SuperadminApproveUser(
        token: _token!,
        userId: userId,
        role: role,
        action: action,
      );

      if (isSuccess) {
        print('User successfully ${action}ed.');
        notifyListeners();
      }
    } catch (e) {
      print('Error processing user approval/rejection: $e');
      rethrow; // Rethrow to handle in UI
    }
    await SuperAdminfetchallusersProvider();
  }

  Future<void> SuperAdminUploadlessonprovider(int courseId, int batchId,
      String title, String content, int lessonId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.SuperAdminuploadLessonFile(
        _token!,
        courseId,
        batchId,
        title,
        content,
        moduleId,
        lessonId,
      );

      // Refresh the lessons list
      await SuperAdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error uploading lesson: $e');
      throw Exception('Failed to upload lesson: $e');
    }
  }

 
  // Future<SuperAdminLiveLinkResponse?> SuperAdminfetchLivelinkForModuleProvider(
  //     int courseId, int batchId) async {
  //   if (_token == null) throw Exception('Token is missing');
  //   try {
  //     // Fetch the live link using the API
  //     final live = await _apiService.SuperAdminfetchgetLiveLinkbatchAPI(
  //         _token!, courseId, batchId);

  //     // Store the live link in the _livebatch map
  //     _livebatch[batchId] = [live]; // Wrap the single response in a list
  //     notifyListeners();

  //     return live; // Return the single live link
  //   } catch (e) {
  //     print('Error fetching lessons for module: $e');
  //     rethrow;
  //   }
  // }

  Future<void> SupercreateQuizProvider({
    required int batchId,
    required int courseId,
    required int moduleId,
    required String name,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    // Validate input data
    if (name.isEmpty) throw Exception('Quiz name cannot be empty');
    if (description.isEmpty)
      throw Exception('Quiz description cannot be empty');
    if (questions.isEmpty)
      throw Exception('Quiz must have at least one question');

    // Validate each question
    for (var question in questions) {
      if (!question.containsKey('text') || question['text'].isEmpty) {
        throw Exception('Question text cannot be empty');
      }

      if (!question.containsKey('answers') ||
          !(question['answers'] is List) ||
          (question['answers'] as List).isEmpty) {
        throw Exception('Each question must have answers');
      }

      var hasCorrectAnswer = false;
      for (var answer in question['answers']) {
        if (!answer.containsKey('text') || answer['text'].isEmpty) {
          throw Exception('Answer text cannot be empty');
        }
        if (answer['isCorrect'] == true) {
          hasCorrectAnswer = true;
        }
      }

      if (!hasCorrectAnswer) {
        throw Exception('Each question must have at least one correct answer');
      }
    }

    try {
      // print('Creating quiz with following data:');
      // print('Course ID: $courseId');
      // print('Module ID: $moduleId');
      // print('Batch ID: $batchId');
      // print('Name: $name');
      // print('Description: $description');
      // print('Number of questions: ${questions.length}');

      await _apiService.SupercreateQuizAPI(
        token: _token!,
        batchId: batchId,
        courseId: courseId,
        moduleId: moduleId,
        data: {
          'name': name,
          'description': description,
          'questions': questions,
        },
      );

      notifyListeners();
    } catch (e) {
      print('Error in createQuizProvider: $e');
      throw Exception('Failed to create quiz: $e');
    }
  }

  Future<void> SuperfetchQuizzesForModuleProvider(int courseId, int moduleId) async {
    if (_token == null) {
      throw Exception('Token is missing');
    }

    try {
      print('Fetching quizzes for Course: $courseId, Module: $moduleId');

      // Fetch quizzes from the API service
      final quizzes = await _apiService.SuperfetchQuizzes(
        _token!,
        courseId,
        moduleId,
      );

      // Update the local quiz map
      _moduleQuiz[moduleId] = quizzes;

      print('Fetched ${quizzes.length} quizzes for Module $moduleId');
      notifyListeners();
    } catch (e, stackTrace) {
      print('Error in provider while fetching quizzes: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Rethrow the exception for further handling
    }
  }

  Future<void> SupercreateAssignmentProvider({
    required int courseId,
    required int moduleId,
    required String title,
    required String description,
    required String dueDate,
  }) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.SupercreateAssignmentAPI(
        token: _token!,
        courseId: courseId,
        moduleId: moduleId,
        title: title,
        description: description,
        dueDate: dueDate,
      );

      // Optionally, fetch updated data or provide UI feedback
      notifyListeners();
    } catch (e) {
      print('Error creating assignment: $e');
      throw Exception('Failed to create assignment');
    }
    await SuperfetchAssignmentForModuleProvider(courseId, moduleId);
  }

  Future<void> SuperfetchAssignmentForModuleProvider(
      int courseId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      print('Fetching assignments for Course: $courseId, Module: $moduleId');
      final assignments = await _apiService.SuperfetchAssignmentForModuleAPI(
          _token!, courseId, moduleId);

      _moduleassignments[moduleId] = assignments;
      print('Fetched ${assignments.length} assignments');
      notifyListeners();
    } catch (e, stackTrace) {
      print('Error in provider while fetching assignments: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> Superadmindeleteassignmentprovider(
    int courseId,
    int moduleId,
    int assignmentId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      // Call the API to delete the assignment
      final result = await _apiService.SuperdeletesuperAdminAssignmntAPI(
          _token!, courseId, moduleId, assignmentId);
      print(result);

      // Update the local state
      if (_moduleassignments.containsKey(moduleId)) {
        _moduleassignments[moduleId]?.removeWhere(
            (assignment) => assignment.assignmentId == assignmentId);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting Assignment: $e');
      throw Exception('Failed to delete Assignment');
    }
  }

  Future<void> SuperAdminUpdateAssignment(int courseId, String title,
      String description, int assignmentId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.SuperadminupdateAssignmentAPI(
        // Corrected function name
        _token!,
        courseId,
        title,
        description,
        moduleId,
        assignmentId,
      );

      // Update this to fetch assignments instead of lessons
      await SuperfetchAssignmentForModuleProvider(courseId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error updating assignment: $e');
      throw Exception('Failed to update assignment: $e');
    }
  }

  Future<void> SuperAdminfetchallusersBatchProvider(
      int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.SuperAdminfetchUsersBatchAPI(
        _token!,
        courseId,
        batchId,
      );

      _batchData = response as SuperBatchStudentModel?;
      print('Fetched batch data: $_batchData');
      print('Number of students: ${_batchData?.students.length}');

      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<void> SuperAdminfetchUnApprovedusersProvider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      // Update the list with fetched data
      _unapprovedUsers =
          await _apiService.SuperAdminfetchUnApprovedUsersAPI(_token!);
      print('Fetched unapproved users: $_unapprovedUsers');
      notifyListeners();
    } catch (e) {
      print('Error fetching unapproved users: $e');
      // In case of error, keep the list empty but not null
      _unapprovedUsers = [];
      notifyListeners();
    }
  }

  Future<void> SuperfetchUserProfileProvider(int userId) async {
    if (_token == null) {
      print('Token is missing');
      return;
    }

    try {
      final response = await _apiService.SuperfetchUserProfile(_token!, userId);
      _userProfile = response;
      print('Fetched user profile: ${_userProfile?.profile.name}');
      notifyListeners();
    } catch (e) {
      print('Error fetching user profile: $e');
      _userProfile = null;
      notifyListeners();
    }
  }

  Future<void> SuperfetchSubmissions(int assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final submissions =
          await _apiService.SuperfetchSubmission(assignmentId, _token!);
      _submissions[assignmentId] = submissions;
    } catch (e) {
      print('Error fetching submissions: $e');
      _submissions[assignmentId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> SuperfetchQuizSubmissions(int quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final quizsubmissions = await _apiService.SuperfetchQuizAnswers(quizId, _token!);
      _quizsubmissions[quizId] = quizsubmissions;
    } catch (e) {
      _quizsubmissions[quizId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
Future<SuperAdminLiveLinkResponse> SuperadminfetchLiveAdmin(int batchId) async {
  if (_token == null) {
    throw Exception('Token is null. Please authenticate first.');
  }

  try {
    final liveData = await _apiService.SuperadminfetchLiveAdmin(_token!, batchId);
    _liveBatch[batchId] = liveData;
    notifyListeners();  // Trigger UI rebuild
    return liveData;
  } catch (error) {
   // print('Failed to fetch live data: $error');
    rethrow;
  }
}

Future<void> SuperAdmincreateLivelinkprovider(
  int batchId,
  String liveLink,
  DateTime liveStartTime,
) async {
  if (_token == null) throw Exception('Token is missing');
  try {
    print('Creating LiveLink for courseId: $courseId and batchId: $batchId');

    // Call API to create the live link
    await _apiService.SuperAdminpostLiveLink(
      _token!, 
      batchId, 
      liveLink, 
      liveStartTime
    );

    print('LiveLink creation successful. Fetching updated live data...');

    // Fetch updated live data after creation
    await SuperadminfetchLiveAdmin(batchId);

    print('LiveLink created and data refreshed successfully.');
  } catch (e) {
    print('Error creating LiveLink: $e');
    if (e.toString().contains("Course not found")) {
      throw Exception('Course ID $courseId not found. Please verify.');
    } else {
      throw Exception('Failed to create LiveLink: $e');
    }
  }
}

Future<void> SuperAdmincreateUsers(List<Map<String, dynamic>> usersData) async {
    isLoading = true;
    message = '';
    notifyListeners();

    try {
      final currentToken = token;
      if (currentToken == null || currentToken.isEmpty) {
        throw Exception('Authentication token is not available');
      }

      final response = await _apiService.SuperAdmincreateUserApi(usersData, currentToken);
      print('Response: $response');

      if (response['createdUsers'] != null) {
        _users = List<SuperAdminAllusersmodel>.from(response['createdUsers']
            .map((user) => SuperAdminAllusersmodel.fromJson(user)));
        message = response['message'] ?? 'Users created successfully';

        // Check for any errors in the response
        final errors = response['errors'] as List<dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          message = 'Some users were created with errors: ${errors.join(', ')}';
        }
      } else {
        message = 'No users were created';
      }
    } catch (e) {
      message = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
}
}


Future<void> SuperAdminupdateLive(
      int batchId, String liveLink, DateTime startTime) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.SuperAdminupdateLIveAPI(
        _token!,
        batchId,
        liveLink,
        startTime
        
   
      );
      await SuperadminfetchLiveAdmin(batchId); // Refresh the course list after update
    } catch (e) {
      print('Error updating course: $e');
      throw Exception('Failed to update course');
    }
  }

Future<void> SuperAdmindeleteLiveprovider(int batchId, int courseId) async {
  if (_token == null || _token!.isEmpty) {
    throw Exception('Invalid or missing token');
  }
  
  try {
    final result = await _apiService.SuperAdmindeleteAdminLive(batchId, _token!,courseId);
    print("Delete result: $result");
    notifyListeners();
  } catch (e) {
    print('Error in provider while deleting: $e');
    rethrow;
  }
}
}

