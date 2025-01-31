import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gtecgolsuperadmin/models/super_admin_model.dart';

class SuperAdminAPI {
  final String baseUrl = 'https://api.portfoliobuilders.in/api';

  Future<http.Response> SuperloginAdminAPI(String email, String password) async {
    final url = Uri.parse('$baseUrl/superadmin/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> SuperAdminRegisterAPI(
    String email,
    String password,
    String name,
    String role,
    String phoneNumber,
  ) async {
    final url = Uri.parse('$baseUrl/registerUser');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return response; // Return the response object for further handling
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred during registration: $e');
    }
  }

  Future<List<SuperAdmincoursemodel>> SuperAdminfetchCoursesAPI(String token) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllCourses');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> courses = jsonDecode(response.body)['courses'];
        return courses.map((item) => SuperAdmincoursemodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch courses: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> SuperAdmincreateCourseAPI(
      String title, String description, String token) async {
    final url = Uri.parse('$baseUrl/superadmin/createCourse');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Failed to create course: ${response.reasonPhrase}');
    }
  }

  Future<String> SuperdeleteAdminCourse(int courseId, String token) async {
    final url = Uri.parse("$baseUrl/superadmin/$courseId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Course deleted successfully";
      } else {
        throw Exception(
            "Failed to delete course. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error deleting course: $e");
    }
  }

  Future<String> SuperAdminupdateCourseAPI(
      String token, int courseId, String title, String description) async {
    final url = Uri.parse(
        '$baseUrl/superadmin/updateCourse'); // Ensure this is the correct endpoint for updating a course

    // Prepare the request payload in the correct format
    final payload = jsonEncode({
      'courseId': courseId, // Ensure courseId is passed as a string if required
      'title': title,
      'description': description,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update course: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  Future<List<SuperAdminModulemodel>> SuperAdminfetchModulesForCourseAPI(
      String token, int courseId, int batchId) async {
    final url = Uri.parse('$baseUrl/superadmin/getAllModules/$courseId/$batchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> modules = jsonDecode(response.body)['modules'];
        // Filter modules for the specific course
        return modules.map((item) => SuperAdminModulemodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch modules: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> SuperAdmincreatemoduleAPI(
    String token,
    int courseId,
    int batchId,
    String title,
    String content,
  ) async {
    final url = Uri.parse('$baseUrl/superadmin/createModule');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'courseId': courseId,
        'batchId': batchId,
        'title': title,
        'content': content
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
          'Module created successfully: ${response.body}'); // Log the response body
      return response.body;
    } else {
      print(
          'Failed to create module: ${response.reasonPhrase}'); // Log failure reason
      throw Exception('Failed to create module: ${response.reasonPhrase}');
    }
  }

  Future<String> SuperdeleteAdminmodule(
      int courseId, int batchId, String token, int moduleId) async {
    final url =
        Uri.parse("$baseUrl/superadmin/deleteModule/$courseId/$moduleId/$batchId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Module deleted successfully";
      } else {
        throw Exception(
            "Failed to delete Module. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error deleting Module: $e");
    }
  }

  Future<String> SuperAdminupdateModuleAPI(String token, int courseId, int batchId,
      String title, String content, int moduleId) async {
    final url = Uri.parse(
        '$baseUrl/superadmin/updateModule'); // Ensure this is the correct endpoint for updating a course

    // Prepare the request payload in the correct format
    final payload = jsonEncode({
      'courseId': courseId,
      'batchId': batchId,
      'moduleId': moduleId, // Ensure courseId is passed as a string if required
      'title': title,
      'content': content,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update course: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  Future<List<SuperAdminLessonmodel>> SuperAdminfetchLessonsForModuleAPI(
      String token, int courseId, int batchId, int moduleId) async {
    final url =
        Uri.parse('$baseUrl/superadmin/getAllLessons/$courseId/$moduleId/$batchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> lessons = jsonDecode(response.body)['lessons'];
        return lessons.map((item) => SuperAdminLessonmodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch lessons: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> SuperAdmincreatelessonseAPI(String token, int courseId, int batchId,
      int moduleId, String content, String title, String videoLink) async {
    final url = Uri.parse('$baseUrl/superadmin/createLesson');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'batchId': batchId, // Convert to int for API
          'moduleId': moduleId, // Convert to int for API
          'title': title,
          'content': content,
          'videoLink': videoLink,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Lesson created successfully: ${response.body}');
        return response.body;
      } else {
        print('Failed to create Lesson: ${response.reasonPhrase}');
        throw Exception('Failed to create Lesson: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in createlessonseAPI: $e');
      throw Exception('Failed to create lesson: $e');
    }
  }

  Future<String> SuperAdminuploadLessonFile(String token, int courseId, int batchId,
      String title, String content, int moduleId, int lessonId) async {
    final url = Uri.parse(
        '$baseUrl/superadmin/uploadLessonFile$courseId/$moduleId/$lessonId/$batchId');

    final payload = jsonEncode({
      'lessonId': lessonId,
      'courseId': courseId,
      'batchId': batchId,
      'moduleId': moduleId,
      'title': title,
      'content': content,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      print(
          'Upload Lesson Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception(
            'Failed to upload lesson: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error uploading lesson: $e');
      rethrow;
    }
  }

  Future<String> SuperdeleteAdminlesson(int courseId, int batchId, String token,
      int moduleId, int lessonId) async {
    final url = Uri.parse(
        "$baseUrl/superadmin/deleteLesson/$courseId/$moduleId/$lessonId/$batchId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Lesson deleted successfull";
      } else {
        throw Exception(
            "Failed to delete Lesson. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error deleting Lesson: $e");
    }
  }

  Future<String> SuperAdminupdateLessonAPI(String token, int courseId, int batchId,
      String title, String content, int moduleId, int lessonId) async {
    final url = Uri.parse('$baseUrl/superadmin/updateLesson');

    final payload = jsonEncode({
      'lessonId': lessonId,
      'courseId': courseId,
      'batchId': batchId,
      'moduleId': moduleId,
      'title': title,
      'content': content,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      print(
          'Update Lesson Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception(
            'Failed to update lesson: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating lesson: $e');
      rethrow;
    }
  }

  Future<String> SuperAdmincreatebatch(
      String token, int courseId, String batchName) async {
    final url = Uri.parse('$baseUrl/superadmin/createBatch');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'courseId': courseId,
        'name': batchName,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
          'Batch created successfully: ${response.body}'); // Log the response body
      return response.body;
    } else {
      print(
          'Failed to create Batch: ${response.reasonPhrase}'); // Log failure reason
      throw Exception('Failed to create Batch: ${response.reasonPhrase}');
    }
  }

  Future<List<SuperAdminCourseBatch>> SuperAdminfetctBatchForCourseAPI(
      String token, int courseId) async {
    final url = Uri.parse('$baseUrl/superadmin/getBatchesByCourseId/$courseId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> Batches = jsonDecode(response.body)['batches'];
        // Filter modules for the specific course
        return Batches.map((item) => SuperAdminCourseBatch.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch modules: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<String> SuperAdminupdateBatchAPI(
      String token, int courseId, int batchId, String batchName) async {
    final url = Uri.parse(
        '$baseUrl/superadmin/updateBatch'); // Ensure this is the correct endpoint for updating a course

    // Prepare the request payload in the correct format
    final payload = jsonEncode({
      'courseId': courseId,
      'batchId': batchId,
      'name': batchName, // Ensure courseId is passed as a string if required
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );
      print("___________________");
      print(response.body);
      print("___________________");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update batch: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating batch: $e');
      rethrow;
    }
  }

  Future<String> SuperdeleteAdminBatch(
      int courseId, String token, int batchId) async {
    final url = Uri.parse("$baseUrl/superadmin/$courseId/$batchId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Module deleted successfully";
      } else {
        throw Exception(
            "Failed to delete Module. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error deleting Module: $e");
    }
  }

  Future<List<SuperAdminAllusersmodel>> SuperAdminfetchUsersAPI(String token) async {
    final url = Uri.parse('$baseUrl/superadmin/dashboard');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body)['users'];
        return users.map((item) => SuperAdminAllusersmodel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> SuperAdminassignUserToBatch({
    required String token,
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/assignUserToBatch');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'batchId': batchId,
          'userId': userId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Indicates success
      } else {
        throw Exception('Failed to assign user to batch: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> SuperAdmindeleteUserFromBatch({
    required String token,
    required int courseId,
    required int batchId,
    required int userId,
  }) async {
    final url = Uri.parse(
        '$baseUrl/superadmin/deleteUserFromBatch/$courseId/$batchId/$userId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'batchId': batchId,
          'userId': userId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true; // Indicates success
      } else {
        throw Exception('Failed to delete user to batch: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<bool> SuperadminApproveUser({
  required String token,
  required int userId,
  required String role,
  required String action,
}) async {
  final url = Uri.parse('$baseUrl/superadmin/approve');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'role': role,
        'action': action.toLowerCase(), // Ensure consistent casing
      }),
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      return true;
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error occurred';
      throw Exception('Failed to process user: $errorMessage');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

  
  Future<SuperAdminLiveLinkResponse> SuperAdminfetchgetLiveLinkbatchAPI(
      String token, int courseId, int batchId) async {
    final url = Uri.parse('$baseUrl/superadmin/getLiveLinkbatch/$batchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SuperAdminLiveLinkResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to fetch live link: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<void> SupercreateQuizAPI({
    required String token,
    required int batchId,
    required int courseId,
    required int moduleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('Creating quiz with data: ${jsonEncode(data)}');

      final url = Uri.parse('$baseUrl/superadmin/createQuiz/$courseId/$moduleId');
      print('Making request to: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          ...data,
          'batchId': batchId, // Include batchId in the request body
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to create quiz. Status: ${response.statusCode}, Body: ${response.body}');
      }

      // Try to parse the response to verify it's valid JSON
      final responseData = jsonDecode(response.body);
      print('Parsed response: $responseData');
    } catch (e, stackTrace) {
      print('Error creating quiz: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create quiz: $e');
    }
  }

  Future<List<SuperAdminQuizModel>> SuperfetchQuizzes(String token, int courseId, int moduleId) async {
  final url = Uri.parse('$baseUrl/superadmin/viewQuiz/$courseId/$moduleId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 404) {
      // Handle 404 (No quizzes found for the module)
      print('No quizzes found for Course $courseId, Module $moduleId');
      return [];
    } else if (response.statusCode == 200) {
      // Parse the quizzes from the response body
      final responseBody = json.decode(response.body);
      final List<dynamic> quizList = responseBody['quizzes'];
      return quizList.map((item) => SuperAdminQuizModel.fromJson(item)).toList();
    } else {
      // Handle unexpected status codes
      throw Exception('Failed to fetch quizzes: ${response.body}');
    }
  } catch (e) {
    print('Error while fetching quizzes: $e');
    throw Exception('An error occurred while fetching quizzes');
  }
}

  Future<http.Response> Superget(String endpoint,
      {required Map<String, String> headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('Making GET request to: $url');

      final response = await http.get(url, headers: headers);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (e) {
      print('Error in GET request: $e');
      throw Exception('Failed to make GET request: $e');
    }
  }

  Future<void> SupercreateAssignmentAPI({
    required String token,
    required int courseId,
    required int moduleId,
    required String title,
    required String description,
    required String dueDate,
  }) async {
    final url = Uri.parse('$baseUrl/superadmin/createAssignment');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseId': courseId,
          'moduleId': moduleId,
          'title': title,
          'description': description,
          'dueDate': dueDate,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Assignment created successfully: ${response.body}');
      } else {
        print('Failed to create assignment: ${response.body}');
        throw Exception(
            'Failed to create assignment: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in createAssignmentAPI: $e');
      throw Exception('Failed to create assignment: $e');
    }
  }

  Future<List<SuperAssignmentModel>> SuperfetchAssignmentForModuleAPI(
      String token, int courseId, int moduleId) async {
    final url = Uri.parse('$baseUrl/superadmin/getAssignments/$courseId/$moduleId');
    try {
      print('Fetching assignments from: $url'); // Debug URL

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('Decoded response: $decodedResponse'); // Debug decoded JSON

        if (decodedResponse['assignments'] == null) {
          print('No assignments key in response');
          return [];
        }

        final List<dynamic> assignments = decodedResponse['assignments'];
        return assignments
            .map((item) => SuperAssignmentModel.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch assignments: ${response.statusCode}\n${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error fetching assignments: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String> SuperdeletesuperAdminAssignmntAPI(
      String token, int assignmentId, int courseId, int moduleId) async {
    final url = Uri.parse(
        "$baseUrl/superadmin/deleteAssignment/$assignmentId/$courseId/$moduleId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? "Assignment deleted successfully";
      } else if (response.statusCode == 404) {
        throw Exception("Assignment not found. Status Code: 404");
      } else {
        throw Exception(
            "Failed to delete Assignment. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error deleting Assignment: $e");
    }
  }

  Future<String> SuperadminupdateAssignmentAPI(String token, int courseId,
      String title, String description, int moduleId, int assignmentId) async {
    final url = Uri.parse('$baseUrl/superadmin/updateAssignment/$assignmentId');

    final payload = jsonEncode({
      'assignmentId': assignmentId,
      'courseId': courseId,
      'moduleId': moduleId,
      'title': title,
      'description': description,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      print(
          'Update assignment Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception(
            'Failed to assignment lesson: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating lesson: $e');
      rethrow;
    }
  }

  Future<SuperBatchStudentModel> SuperAdminfetchUsersBatchAPI(
    String token,
    int courseId,
    int batchId,
  ) async {
    final url =
        Uri.parse('$baseUrl/superadmin/getStudentsByBatchId/$courseId/$batchId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SuperBatchStudentModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<SuperUnapprovedUser>> SuperAdminfetchUnApprovedUsersAPI(String token) async {
  final url = Uri.parse('$baseUrl/superadmin/getUnapprovedUsers');
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Changed from 'unapprovedusers' to 'unapprovedUsers' to match API response
      final List<dynamic> unapprovedUsers = responseData['unapprovedUsers'] ?? [];
      return unapprovedUsers.map((item) => SuperUnapprovedUser.fromJson(item)).toList();
    } else {
      print('Failed to fetch users: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error in API call: $e');
    return [];
  }
}

Future<SuperUserProfileResponse> SuperfetchUserProfile(String token, int userId) async {
    final url = Uri.parse('$baseUrl/getProfile/$userId');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SuperUserProfileResponse.fromJson(data);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error in API call: $e');
      rethrow;
    }
  }


  Future<List<SuperSubmission>> SuperfetchSubmission(int assignmentId, String token) async {
  final url = Uri.parse('$baseUrl/superadmin/getSubmittedAssignments/$assignmentId');
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Extract the submissions array from the response
      final List<dynamic> submissions = responseData['submissions'];
      print('Submissions array: $submissions'); // Debug print
      return submissions.map((item) => SuperSubmission.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load submissions: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}

Future<List<SuperQuizSubmission>> SuperfetchQuizAnswers(int quizId, String token) async {
    final url = Uri.parse('$baseUrl/superadmin/getAnswerquiz/$quizId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> quizSubmissions = responseData['quizSubmissions'];
        return quizSubmissions.map((item) => SuperQuizSubmission.fromMap(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load quiz answers: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

   Future<SuperAdminLiveLinkResponse> SuperadminfetchLiveAdmin(String token, int batchId) async {
    final url = Uri.parse('$baseUrl/superadmin/getLiveLinkbatch/$batchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched live data: $data');
        return SuperAdminLiveLinkResponse.fromJson(data);
      } else {
        throw Exception('Failed to load live link');
      }
    } catch (e) {
      print('Error fetching live data: $e');
      throw Exception('Error fetching live link');
    }
  }


  Future<String> SuperAdminpostLiveLink(
    String token,
    int batchId,
    String liveLink,
    DateTime? liveStartTime,
  ) async {
    final url = Uri.parse('$baseUrl/admin/$batchId/postLiveLink');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'liveLink': liveLink,
        'liveStartTime': liveStartTime
            ?.add(const Duration(hours: 5, minutes: 30)) // Convert to IST
            .toIso8601String(), // Send IST time
      }),
    );

    print('Token: $token');
    print('Batch ID: $batchId');
    print('Live Start Time Sent (IST): ${liveStartTime?.add(const Duration(hours: 5, minutes: 30))}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Live link posted successfully: ${response.body}');
      return response.body;
    } else {
      print('Failed to create Live link: ${response.reasonPhrase}');
      throw Exception('Failed to create Live link: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> SuperAdmincreateUserApi(List<Map<String, dynamic>> users, String token) async {
  final url = Uri.parse('$baseUrl/superadmin/createUser');
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  final body = jsonEncode({
    'users': users.map((user) => {
      'name': user['name']?.trim(),
      'email': user['email']?.trim().toLowerCase(),
      'role': user['role']?.trim(),
      'password': user['password'],
      'phoneNumber': user['phoneNumber']?.trim(),
    }).toList(),
  });

  try {
    print("API Request URL: $url");
    print("Request Headers: $headers");
    print("Request Body: $body");

    final response = await http.post(url, headers: headers, body: body);
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    // Accept both 200 and 201 as success status codes
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process users. Status code: ${response.statusCode}, Response: ${response.body}');
    }
  } catch (e) {
    print("Error in createUserApi: $e");
    throw Exception('Network or server error: $e');
}
}

Future<String> SuperAdminupdateLIveAPI(
      String token, int batchId, String liveLink, DateTime startTime) async {
    final url = Uri.parse(
        '$baseUrl/superadmin/updateLiveLink/$batchId'); // Ensure this is the correct endpoint for updating a course

    // Prepare the request payload in the correct format
    final payload = jsonEncode({
      'liveLink': liveLink,
      'startTime': startTime,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to update live: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating live: $e');
      rethrow;
    }
  }

Future<String> SuperAdmindeleteAdminLive(int batchId, String token, int courseId) async {
  final url = Uri.parse("$baseUrl/superadmin/deleteLiveLink/$courseId/$batchId");
  print("Delete URL: $url"); // Log the URL
  print("Token being used: $token"); // Log the token (be careful with this in production)
  
  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? "Live deleted successfully";
    } else {
      print("Headers sent: ${response.request?.headers}"); // Log request headers
      throw Exception("Failed to delete live course. Status Code: ${response.statusCode}. Response: ${response.body}");
    }
  } catch (e) {
    print("Exception details: $e");
    throw Exception("Error deleting Live: $e");
  }
}

Future<void> SuperadmindeleteQuizAPI({
    required String token,
    required int courseId,
    required int moduleId,
    required int quizId,
  }) async {
    try {
      final url =
          Uri.parse('$baseUrl/superadmin/deleteQuiz/$courseId/$moduleId/$quizId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Parse the response body
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return; // Successful deletion
      } else if (response.statusCode == 404) {
        throw Exception('Quiz not found');
      } else {
        throw Exception(responseData['message'] ?? 'Failed to delete quiz');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid server response');
      } else if (e is SocketException) {
        throw Exception('Network error occurred');
      } else {
        throw Exception('Failed to delete quiz: $e');
      }
    }
  }

   Future<CourseCountsResponse> fetchCourseCounts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/superadmin/getCount'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return CourseCountsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load course counts: ${response.statusCode}');
    }
  }
}
