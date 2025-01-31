class SuperAdmincoursemodel {
  final int courseId;
  final String name;
  final String description;

  SuperAdmincoursemodel({
    required this.courseId,
    required this.name,
    required this.description,
  });

  factory SuperAdmincoursemodel.fromJson(Map<String, dynamic> json) {
    return SuperAdmincoursemodel(
      courseId: json['courseId'], // Matches the field in the API response
      name: json['name'],
      description: json['description'],
    );
  }
}

class SuperAdminModulemodel {
  final int batchId;
  final int moduleId;
  final String title;
  final String content;

  SuperAdminModulemodel({
    required this.batchId,
    required this.moduleId,
    required this.title,
    required this.content,
  });

  // Factory constructor to create a Course instance from JSON
  factory SuperAdminModulemodel.fromJson(Map<String, dynamic> json) {
    return SuperAdminModulemodel(
      batchId: json['batchId'],
      moduleId: json['moduleId'],
      content: json['content'],
      title: json['title'],
    );
  }
}

class SuperAdminLessonmodel {
  final int lessonId;
  final int moduleId;
  final int courseId;
  final int batchId;
  final String title;
  final String content;
  final String videoLink;
  final String? pdfPath; // Nullable
  final String status;

  SuperAdminLessonmodel({
    required this.lessonId,
    required this.moduleId,
    required this.courseId,
    required this.batchId,
    required this.title,
    required this.content,
    required this.videoLink,
    this.pdfPath, // Nullable
    required this.status,
  });

  factory SuperAdminLessonmodel.fromJson(Map<String, dynamic> json) {
    return SuperAdminLessonmodel(
      lessonId: int.parse(json['lessonId']?.toString() ?? '0'),
      moduleId: int.parse(json['moduleId']?.toString() ?? '0'),
      courseId: int.parse(json['courseId']?.toString() ?? '0'),
      batchId: int.parse(json['batchId']?.toString() ?? '0'),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      videoLink: json['videoLink'] ?? '',
      pdfPath: json['pdfPath'],
      status: json['status'] ?? '',
    );
  }
}

class SuperAdminCourseBatch {
  final int batchId;
  final String batchName;

  SuperAdminCourseBatch({
    required this.batchId,
    required this.batchName,
  });

  factory SuperAdminCourseBatch.fromJson(Map<String, dynamic> json) {
    return SuperAdminCourseBatch(
      batchId: json['batchId'],
      batchName: json['batchName'],
    );
  }
}

class SuperAdminAllusersmodel {
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final int userId;

  SuperAdminAllusersmodel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.userId,
  });

  factory SuperAdminAllusersmodel.fromJson(Map<String, dynamic> json) {
    return SuperAdminAllusersmodel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      userId: json['userId'],
    );
  }
}

class SuperAdminLiveLinkResponse {
  final String message;
  final String liveLink;
  final DateTime liveStartTime;

  SuperAdminLiveLinkResponse({
    required this.message,
    required this.liveLink,
    required this.liveStartTime,
  });

  factory SuperAdminLiveLinkResponse.fromJson(Map<String, dynamic> json) {
    return SuperAdminLiveLinkResponse(
      message: json['message'] as String,
      liveLink: json['liveLink'] as String,
      liveStartTime: DateTime.parse(json['liveStartTime'] as String),
    );
  }
}

class SuperAdminQuizModel {
  final int quizId;
  final String name;
  final String description;
  final int courseId;
  final int moduleId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Question> questions;

  SuperAdminQuizModel({
    required this.quizId,
    required this.name,
    required this.description,
    required this.courseId,
    required this.moduleId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.questions,
  });

  factory SuperAdminQuizModel.fromJson(Map<String, dynamic> json) {
    return SuperAdminQuizModel(
      quizId: json['quizId'],
      name: json['name'],
      description: json['description'],
      courseId: json['courseId'],
      moduleId: json['moduleId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      questions: (json['questions'] as List)
          .map((question) => Question.fromJson(question))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'name': name,
      'description': description,
      'courseId': courseId,
      'moduleId': moduleId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}

class Question {
  final int questionId;
  final String text;
  final List<Answer> answers;

  Question({
    required this.questionId,
    required this.text,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['questionId'],
      text: json['text'],
      answers: (json['answers'] as List)
          .map((answer) => Answer.fromJson(answer))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'text': text,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class Answer {
  final int answerId;
  final String text;
  final bool? isCorrect; // Make this field nullable

  Answer({
    required this.answerId,
    required this.text,
    this.isCorrect, // Default to null if not provided
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answerId: json['answerId'],
      text: json['text'],
      isCorrect: json['isCorrect'], // This can now be null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answerId': answerId,
      'text': text,
      'isCorrect': isCorrect, // This can be null as well
    };
  }
}

class SuperAssignmentModel {
  final int assignmentId;
  final int courseId;
  final int moduleId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String submissionLink;

  SuperAssignmentModel({
    required this.assignmentId,
    required this.courseId,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.submissionLink,
  });

  factory SuperAssignmentModel.fromJson(Map<String, dynamic> json) {
    return SuperAssignmentModel(
      assignmentId: json['assignmentId'] ?? 0,
      courseId: json['courseId'] ?? 0,
      moduleId: json['moduleId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      submissionLink: json['submissionLink'] ?? '',
    );
  }
}

class SuperBatchStudentModel {
  final String message;
  final int courseId;
  final String courseName;
  final int batchId;
  final String batchName;
  final List<SuperStudent> students;

  SuperBatchStudentModel({
    required this.message,
    required this.courseId,
    required this.courseName,
    required this.batchId,
    required this.batchName,
    required this.students,
  });

  factory SuperBatchStudentModel.fromJson(Map<String, dynamic> json) {
    return SuperBatchStudentModel(
      message: json['message'] as String,
      courseId: json['courseId'] as int,
      courseName: json['courseName'] as String,
      batchId: json['batchId'] as int,
      batchName: json['batchName'] as String,
      students: (json['students'] as List<dynamic>)
          .map((student) => SuperStudent.fromJson(student as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SuperStudent {
  final int studentId;
  final String name;
  final String email;

  SuperStudent({
    required this.studentId,
    required this.name,
    required this.email,
  });

  factory SuperStudent.fromJson(Map<String, dynamic> json) {
    return SuperStudent(
      studentId: json['studentId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'email': email,
    };
  }
}

class SuperUnapprovedUser {
  final int userId;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber; // Added optional phone number field

  SuperUnapprovedUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber, // Optional field
  });

  factory SuperUnapprovedUser.fromJson(Map<String, dynamic> json) {
    return SuperUnapprovedUser(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phoneNumber: json['phoneNumber'], // Parse phone number from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
    };
  }
}

class SuperUserProfileResponse {
  final String message;
  final SuperUserProfile profile;

  SuperUserProfileResponse({required this.message, required this.profile});

  factory SuperUserProfileResponse.fromJson(Map<String, dynamic> json) {
    return SuperUserProfileResponse(
      message: json['message'],
      profile: SuperUserProfile.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'profile': profile.toJson(),
    };
  }
}

class SuperUserProfile {
  final int userId; // Changed from id to userId to match API response
  final String name;
  final String email;
  final String role;
  final String phoneNumber;

  SuperUserProfile({
    required this.userId, // Updated parameter name
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
  });

  factory SuperUserProfile.fromJson(Map<String, dynamic> json) {
    return SuperUserProfile(
      userId: json['userId'], // Updated to match API response
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // Updated field name
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
    };
  }
}

class SuperSubmission {
  final int submissionId;
  final int assignmentId;
  final int studentId;
  final String status;
  final String content;
  final DateTime submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String studentName;
  final String studentEmail;

  SuperSubmission({
    required this.submissionId,
    required this.assignmentId,
    required this.studentId,
    required this.status,
    required this.content,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.studentName,
    required this.studentEmail,
  });

  factory SuperSubmission.fromJson(Map<String, dynamic> json) {
    return SuperSubmission(
      submissionId: json['submissionId'] ?? 0,
      assignmentId: json['assignmentId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      status: json['status'] ?? '',
      content: json['content'] ?? '',
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      studentName: json['Student']?['name'] ?? 'Unknown',
      studentEmail: json['Student']?['email'] ?? 'No email',
    );
  }
}

class SuperQuizSubmission {
  final int submissionId;
  final String studentName;
  final String studentEmail;
  final int quizId;
  final String questionText;
  final String selectedAnswer;
  final bool isCorrect;
  final String status;
  final DateTime submittedAt;

  SuperQuizSubmission({
    required this.submissionId,
    required this.studentName,
    required this.studentEmail,
    required this.quizId,
    required this.questionText,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.status,
    required this.submittedAt,
  });

  factory SuperQuizSubmission.fromMap(Map<String, dynamic> json) {
    return SuperQuizSubmission(
      submissionId: json['submissionId'],
      studentName: json['student']['name'],
      studentEmail: json['student']['email'],
      quizId: json['quizId'],
      questionText: json['question']['text'],
      selectedAnswer: json['selectedAnswer']['text'],
      isCorrect: json['selectedAnswer']['isCorrect'],
      status: json['status'],
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }
}
