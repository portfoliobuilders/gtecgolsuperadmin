import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gtecgolsuperadmin/contants/super_admingtec_token.dart';
import 'package:gtecgolsuperadmin/models/admin_model.dart';
import 'package:gtecgolsuperadmin/screens/admin/admin_dashboard.dart';
import 'package:gtecgolsuperadmin/screens/admin/login/admin_login.dart';
import 'package:gtecgolsuperadmin/services/webservice.dart';

class AdminAuthProvider with ChangeNotifier {
  void clearModuleData() {
    _courseModules = {};
    notifyListeners();
  }

  String? _token;
  String? deleteMessage;
  bool isLoading = false;
  String? message;
  int? _currentUserId;
  List<Admincoursemodel> _course = []; // Correctly store courses

  int? courseId;

  String? _error;
  CourseCountsResponse? _courseCounts;
  CourseCountsResponse? get courseCounts => _courseCounts;
  String? get error=>_error;

  int? assignmentId;
  final Map<int, List<Submission>> _submissions = {};

  List<Submission> get submissionsForAssignment =>
      _submissions[assignmentId] ?? [];
  List<dynamic> getSubmissionsForAssignment(int assignmentId) {
    return _submissions[assignmentId] ?? [];
  }

  List<Admincoursemodel> get course => _course;

  Map<int, List<QuizSubmission>> _quizsubmissions = {};
  Map<int, List<QuizSubmission>> get quizsubmissions => _quizsubmissions;

  Map<int, List<AdminLiveLinkResponse>> _livebatch = {};

  final Map<int, AdminLiveLinkResponse> _liveBatch = {};

  Future<List<AdminLiveLinkResponse>> SupergetLiveForbatch(int batchId) async {
    if (_livebatch[batchId] == null) {
      await AdminfetchLiveAdmin(batchId); // Make sure the data is fetched
    }
    return _livebatch[batchId] ?? []; // Return the list of live links
  }

  String? get token => _token;

  BatchStudentModel? _batchData;

  // Getter for the batch data
  BatchStudentModel? get batchData => _batchData;
  List<Student> get students => _batchData?.students ?? [];

  UserProfileResponse? _userProfile;
  UserProfileResponse? get userProfile => _userProfile;

  int? get currentUserId => _currentUserId;

  final SuperAdminAPI _apiService = SuperAdminAPI();

  Map<int, List<AdminModulemodel>> _courseModules = {};

  Map<int, List<AdminLessonmodel>> _moduleLessons = {};

  Map<int, List<AdminQuizModel>> _moduleQuizzes = {};

  final Map<int, List<AssignmentModel>> _moduleassignments = {};

  final Map<int, List<AdminQuizModel>> _moduleQuiz = {};

  List<AdminQuizModel> getQuizForModule(int moduleId) {
    return _moduleQuiz[moduleId] ?? [];
  }

  List<AdminQuizModel> _quizzes = [];

  bool _isLoading = false;

  List<AdminAllusersmodel> _users =
      []; // Add this line to define the _users variable

  List<AdminAllusersmodel>? get users => _users;

  List<UnapprovedUser> _unapprovedUsers = [];
  List<UnapprovedUser>? get unapprovedUsers => _unapprovedUsers;

  final Map<int, List<AdminCourseBatch>> _courseBatches =
      {}; // Map for storing course batches

  // Loading state

  Map<int, List<AdminCourseBatch>> get courseBatches => _courseBatches;

  int? get batchId => null;

  get studentUsers => null;

  get getusers => null;
  List<AdminModulemodel> getModulesForCourse(courseId) {
    return _courseModules[courseId] ?? [];
  }

  List<AdminLessonmodel> getLessonsForModule(int moduleId) {
    return _moduleLessons[moduleId] ?? [];
  }

  List<AssignmentModel> getAssignmentsForModule(int moduleId) {
    return _moduleassignments[moduleId] ?? [];
  }

// Modify this method to return a Future<List<AdminLiveLinkResponse>> instead of just a list
  Future<List<AdminLiveLinkResponse>> getLiveForbatch(int batchId) async {
    if (_livebatch[batchId] == null) {
      await AdminfetchLiveAdmin(batchId); // Make sure the data is fetched
    }
    return _livebatch[batchId] ?? []; // Return the list of live links
  }

  // Superadmin login
  Future<void> adminloginprovider(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await _apiService.loginAdminAPI(email, password);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];
        _currentUserId = responseData['userId'];

        // Save the token
        await saveToken(_token!);

        // Only fetch profile if we have a valid userId
        if (_currentUserId != null) {
          await fetchUserProfileProvider(_currentUserId!);
        }

        // Rest of your login logic...
        await AdminfetchCoursesprovider();
        await AdminfetchUnApprovedusersProvider();

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

  Future<void> Adminregisterprovider(String email, String password, String name,
      String role, String phoneNumber) async {
    try {
      await _apiService.AdminRegisterAPI(
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
  Future<void> AdmincheckAuthprovider(BuildContext context) async {
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
  Future<void> AdminfetchCoursesprovider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      _course = await _apiService.AdminfetchCoursesAPI(
          _token!); // Fetch courses correctly

      // Print the fetched courses to the terminal
      print('Fetched courses: $_course');

      notifyListeners(); // Notify listeners that courses are fetched
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  // Create a new course
  Future<void> AdmincreateCourseprovider(
      String title, String description) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.AdmincreateCourseAPI(title, description, _token!);
      await AdminfetchCoursesprovider(); // Refresh the course list after creation
    } catch (e) {
      print('Error creating course: $e');
      throw Exception('Failed to create course');
    }
  }

  Future<void> AdmindeleteCourseprovider(int courseId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminCourse(courseId, _token!);
      print(result); // Optionally print success message

      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchCoursesprovider();
    } catch (e) {
      print('Error deleting course: $e');
    }
  }

  Future<void> AdminupdateCourse(
      int courseId, String title, String description) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateCourseAPI(
        _token!,
        courseId,
        title,
        description,
      );
      await AdminfetchCoursesprovider(); // Refresh the course list after update
    } catch (e) {
      print('Error updating course: $e');
      throw Exception('Failed to update course');
    }
  }

  Future<void> AdminfetchModulesForCourseProvider(
      int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final modules = await _apiService.AdminfetchModulesForCourseAPI(
          _token!, courseId, batchId);
      _courseModules[courseId] = modules;
      _courseModules[batchId] = modules;
      notifyListeners();
    } catch (e) {
      print('Error fetching modules for course: $e');
      throw Exception('Failed to fetch modules for course');
    }
  }

  Future<void> Admincreatemoduleprovider(
      String title, String content, int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating module for courseId: $courseId,$batchId');

      // Call API to create the module
      await _apiService.AdmincreatemoduleAPI(
          _token!, courseId, batchId, title, content);

      print('Module creation successful. Fetching updated modules...');

      // Fetch updated modules after creation
      await AdminfetchModulesForCourseProvider(courseId, batchId);

      print('Modules fetched successfully.');
    } catch (e) {
      print('Error creating module: $e');
      throw Exception('Failed to create module');
    }
  }

  Future<void> admindeletemoduleprovider(
      int courseId, int batchId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminmodule(
          courseId, batchId, _token!, moduleId);
      print(result); // Optionally print success message

      if (_courseModules.containsKey(courseId)) {
        _courseModules[courseId]
            ?.removeWhere((module) => module.moduleId == moduleId);
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchModulesForCourseProvider(courseId, batchId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> AdminUpdatemoduleprovider(int courseId, int batchId,
      String title, String content, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateModuleAPI(
          _token!, courseId, batchId, title, content, moduleId);
      await AdminfetchModulesForCourseProvider(
          courseId, batchId); // Refresh the course list after update
    } catch (e) {
      print('Error updating module: $e');
      throw Exception('Failed to update module');
    }
  }

  Future<void> AdminfetchLessonsForModuleProvider(
      int courseId, int batchId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final lessons = await _apiService.AdminfetchLessonsForModuleAPI(
          _token!, courseId, batchId, moduleId);
      _moduleLessons[moduleId] = lessons;
      notifyListeners();
    } catch (e) {
      print('Error fetching lessons for module: $e');
      rethrow;
    }
  }

  Future<void> Admincreatelessonprovider(
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
      await _apiService.AdmincreatelessonseAPI(
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
      await AdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);

      print('Lessons fetched successfully.');
    } catch (e) {
      print('Error creating lesson: $e');
      throw Exception('Failed to create lesson: $e');
    }
  }

  Future<void> admindeletelessonprovider(
      int courseId, int batchId, int moduleId, int lessonId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result = await _apiService.deleteAdminlesson(
          courseId, batchId, _token!, moduleId, lessonId);
      print(result); // Optionally print success message

      if (_courseModules.containsKey(courseId)) {
        _moduleLessons[moduleId]
            ?.removeWhere((lesson) => lesson.lessonId == lessonId);
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> AdminUpdatelessonprovider(int courseId, int batchId,
      String title, String content, int lessonId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateLessonAPI(
        _token!,
        courseId,
        batchId,
        title,
        content,
        moduleId,
        lessonId,
      );

      // Refresh the lessons list
      await AdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error updating lesson: $e');
      throw Exception('Failed to update lesson: $e');
    }
  }

  Future<void> AdmincreateBatchprovider(String batchName, int courseId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating Batch for courseId: $courseId');

      // Call API to create the module
      await _apiService.Admincreatebatch(_token!, courseId, batchName);

      print('Batch creation successful. Fetching updated modules...');

      // Fetch updated modules after creation
      await AdminfetchBatchForCourseProvider(courseId);

      print('Batch created successfully.');
    } catch (e) {
      print('Error creating Batch: $e');
      throw Exception('Failed to create Batch');
    }
  }

  Future<void> AdminfetchBatchForCourseProvider(int courseId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      _isLoading = true; // Set loading to true
      notifyListeners(); // Notify listeners that the loading state has changed

      final Batches =
          await _apiService.AdminfetctBatchForCourseAPI(_token!, courseId);
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

  Future<void> AdminUpdatebatchprovider(
      int courseId, int batchId, String batchName) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateBatchAPI(
          _token!, courseId, batchId, batchName);
      await AdminfetchBatchForCourseProvider(
          courseId); // Refresh the course list after update
    } catch (e) {
      print('Error updating batch: $e');
      throw Exception('Failed to update batch');
    }
  }

  Future<void> AdmindeleteBatchprovider(int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      final result =
          await _apiService.deleteAdminBatch(courseId, _token!, batchId);
      print(result); // Optionally print success message

      if (_courseBatches.containsKey(courseId)) {
        _courseBatches[courseId]
            ?.removeWhere((Batche) => Batche.batchId == batchId);
        notifyListeners(); // Notify listeners immediately for UI update
      }
      // After successful deletion, re-fetch the courses to update the list
      await AdminfetchModulesForCourseProvider(courseId, batchId);
    } catch (e) {
      print('Error deleting module: $e');
    }
  }

  Future<void> AdminfetchallusersProvider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      _users = await _apiService.AdminfetchUsersAPI(_token!);

      // Print the fetched users to the terminal
      print('Fetched users: $_users');

      notifyListeners(); // Notify listeners that users are fetched
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> assignUserToBatchProvider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.AdminassignUserToBatch(
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

  Future<void> AdmindeleteUserFromBatchprovider({
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.AdmindeleteUserFromBatch(
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

  Future<void> adminApproveUserprovider({
    required int userId,
    required String role,
    required String action, // 'approve' or 'reject'
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final isSuccess = await _apiService.adminApproveUser(
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
    await AdminfetchallusersProvider();
  }

  Future<void> AdminUploadlessonprovider(int courseId, int batchId,
      String title, String content, int lessonId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminuploadLessonFile(
        _token!,
        courseId,
        batchId,
        title,
        content,
        moduleId,
        lessonId,
      );

      // Refresh the lessons list
      await AdminfetchLessonsForModuleProvider(courseId, batchId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error uploading lesson: $e');
      throw Exception('Failed to upload lesson: $e');
    }
  }

  Future<void> createQuizProvider({
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

      await _apiService.createQuizAPI(
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

  Future<void> fetchQuizzesForModuleProvider(int courseId, int moduleId) async {
    if (_token == null) {
      throw Exception('Token is missing');
    }

    try {
      print('Fetching quizzes for Course: $courseId, Module: $moduleId');

      // Fetch quizzes from the API service
      final quizzes = await _apiService.fetchQuizzes(
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

  Future<void> createAssignmentProvider({
    required int courseId,
    required int moduleId,
    required String title,
    required String description,
    required String dueDate,
  }) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      await _apiService.createAssignmentAPI(
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
    await fetchAssignmentForModuleProvider(courseId, moduleId);
  }

  Future<void> fetchAssignmentForModuleProvider(
      int courseId, int moduleId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      print('Fetching assignments for Course: $courseId, Module: $moduleId');
      final assignments = await _apiService.fetchAssignmentForModuleAPI(
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

  Future<void> superadmindeleteassignmentprovider(
    int courseId,
    int moduleId,
    int assignmentId,
  ) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      // Call the API to delete the assignment
      final result = await _apiService.deletesuperAdminAssignmntAPI(
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
      await _apiService.superadminupdateAssignmentAPI(
        // Corrected function name
        _token!,
        courseId,
        title,
        description,
        moduleId,
        assignmentId,
      );

      // Update this to fetch assignments instead of lessons
      await fetchAssignmentForModuleProvider(courseId, moduleId);

      notifyListeners();
    } catch (e) {
      print('Error updating assignment: $e');
      throw Exception('Failed to update assignment: $e');
    }
  }

  Future<void> AdminfetchallusersBatchProvider(
      int courseId, int batchId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      final response = await _apiService.AdminfetchUsersBatchAPI(
        _token!,
        courseId,
        batchId,
      );

      _batchData = response as BatchStudentModel?;
      print('Fetched batch data: $_batchData');
      print('Number of students: ${_batchData?.students.length}');

      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<void> AdminfetchUnApprovedusersProvider() async {
    if (_token == null) throw Exception('Token is missing');
    try {
      // Update the list with fetched data
      _unapprovedUsers =
          await _apiService.AdminfetchUnApprovedUsersAPI(_token!);
      print('Fetched unapproved users: $_unapprovedUsers');
      notifyListeners();
    } catch (e) {
      print('Error fetching unapproved users: $e');
      // In case of error, keep the list empty but not null
      _unapprovedUsers = [];
      notifyListeners();
    }
  }

  Future<void> fetchUserProfileProvider(int userId) async {
    if (_token == null) {
      print('Token is missing');
      return;
    }

    try {
      final response = await _apiService.fetchUserProfile(_token!, userId);
      _userProfile = response;
      print('Fetched user profile: ${_userProfile?.profile.name}');
      notifyListeners();
    } catch (e) {
      print('Error fetching user profile: $e');
      _userProfile = null;
      notifyListeners();
    }
  }

  Future<void> fetchSubmissions(int assignmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final submissions =
          await _apiService.fetchSubmission(assignmentId, _token!);
      _submissions[assignmentId] = submissions;
    } catch (e) {
      print('Error fetching submissions: $e');
      _submissions[assignmentId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizSubmissions(int quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final quizsubmissions =
          await _apiService.fetchQuizAnswers(quizId, _token!);
      _quizsubmissions[quizId] = quizsubmissions;
    } catch (e) {
      _quizsubmissions[quizId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuizProvider(
      int courseId, int moduleId, int quizId) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.deleteQuizAPI(
        token: _token!,
        courseId: courseId,
        moduleId: moduleId,
        quizId: quizId,
      );

      // Only remove from local state if API call was successful
      _moduleQuiz.forEach((key, quizzes) {
        _moduleQuiz[key] =
            quizzes.where((quiz) => quiz.quizId != quizId).toList();
      });

      notifyListeners();
    } catch (e) {
      // Log the error for debugging
      print('Error in deleteQuizProvider: $e');

      // Rethrow with a more user-friendly message
      if (e.toString().contains('Quiz not found')) {
        throw Exception('Quiz not found or already deleted');
      } else if (e.toString().contains('Network error')) {
        throw Exception('Please check your internet connection and try again');
      } else {
        throw Exception('Unable to delete quiz. Please try again later.');
      }
    }
  }

  Future<void> updateQuizProvider({
    required int quizId,
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

    try {
      await _apiService.updateQuizAPI(
        token: _token!,
        quizId: quizId,
        data: {
          'name': name,
          'description': description,
          'questions': questions,
        },
      );

      notifyListeners();
    } catch (e) {
      print('Error in updateQuizProvider: $e');
      throw Exception('Failed to update quiz: $e');
    }
  }

  Future<void> updateQuestionProvider({
    required int quizId,
    required int questionId,
    required String text,
    required List<Map<String, dynamic>> answers,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.updateQuestionAPI(
        token: _token!,
        quizId: quizId,
        questionId: questionId,
        data: {
          'text': text,
          'answers': answers,
        },
      );

      notifyListeners();
    } catch (e) {
      print('Error in updateQuestionProvider: $e');
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> deleteQuestionProvider({
    required int quizId,
    required int questionId,
  }) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.deleteQuestionAPI(
        token: _token!,
        quizId: quizId,
        questionId: questionId,
      );

      // Update local state if needed
      notifyListeners();
    } catch (e) {
      // Log the error for debugging
      print('Error in deleteQuestionProvider: $e');

      // Rethrow with a more user-friendly message
      if (e.toString().contains('Question not found')) {
        throw Exception('Question not found or already deleted');
      } else if (e.toString().contains('Network error')) {
        throw Exception('Please check your internet connection and try again');
      } else {
        throw Exception('Unable to delete question. Please try again later.');
      }
    }
  }

  Future<AdminLiveLinkResponse?> AdminfetchLiveAdmin(int batchId) async {
    if (_token == null) {
      print('Error: Token is null. Please authenticate first.');
      return null; // Return null instead of throwing an exception
    }

    try {
      final liveData = await _apiService.AdminfetchLiveAdmin(_token!, batchId);
      _liveBatch[batchId] = liveData!;
      notifyListeners(); // Trigger UI rebuild
      return liveData;
    } catch (error) {
      print('Failed to fetch live data: $error');
      return null; // Return null so UI can handle it gracefully
    }
  }

  Future<void> AdmincreateLivelinkprovider(
    int batchId,
    String liveLink,
    DateTime liveStartTime,
  ) async {
    if (_token == null) throw Exception('Token is missing');
    try {
      print('Creating LiveLink for courseId: $courseId and batchId: $batchId');

      // Call API to create the live link
      await _apiService.AdminpostLiveLink(
          _token!, batchId, liveLink, liveStartTime);

      print('LiveLink creation successful. Fetching updated live data...');

      // Fetch updated live data after creation
      await AdminfetchLiveAdmin(batchId);

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

  Future<void> AdminupdateLive(
      int batchId, String liveLink, DateTime startTime) async {
    if (_token == null) throw Exception('Token is missing');

    try {
      await _apiService.AdminupdateLIveAPI(
          _token!, batchId, liveLink, startTime);
      await AdminfetchLiveAdmin(
          batchId); // Refresh the course list after update
    } catch (e) {
      print('Error updating course: $e');
      throw Exception('Failed to update course');
    }
  }

  Future<void> AdmindeleteLiveprovider(int courseId, int batchId) async {
    if (_token == null || _token!.isEmpty) {
      throw Exception('Invalid or missing token');
    }

    try {
      final result =
          await _apiService.AdmindeleteAdminLive(courseId, batchId, _token!);
      print("Delete result: $result");
      notifyListeners();
    } catch (e) {
      print('Error in provider while deleting: $e');
      rethrow;
    }
  }

  Future<void> AdminfetchCourseCountsProvider() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courseCounts = await _apiService.AdminfetchCourseCounts( _token!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
}
}
