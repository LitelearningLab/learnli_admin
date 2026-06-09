import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/curriculum_models.dart';
import '../models/chapter_content_model.dart';
import '../models/career_models.dart';
import '../services/database_service.dart';

class AdminProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isInitializing = true;
  
  // Curriculum state
  Map<String, Grade> _curriculum = {};
  bool _isLoadingCurriculum = false;

  // Active selections
  String? _selectedGradeKey; // e.g. "grade_7"
  String? _selectedSubjectId; // e.g. "science" or "SCI"
  int? _selectedChapterNumber;

  // Chapter content state
  ChapterContent? _activeContent;
  bool _isLoadingContent = false;
  String _jsonString = '';

  // Careers state
  Map<String, Career> _careers = {};
  bool _isLoadingCareers = false;
  String? _selectedCareerId;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;
  Map<String, Grade> get curriculum => _curriculum;
  bool get isLoadingCurriculum => _isLoadingCurriculum;
  
  String? get selectedGradeKey => _selectedGradeKey;
  String? get selectedSubjectId => _selectedSubjectId;
  int? get selectedChapterNumber => _selectedChapterNumber;

  ChapterContent? get activeContent => _activeContent;
  bool get isLoadingContent => _isLoadingContent;
  String get jsonString => _jsonString;

  Map<String, Career> get careers => _careers;
  bool get isLoadingCareers => _isLoadingCareers;
  String? get selectedCareerId => _selectedCareerId;
  Career? get selectedCareer => _selectedCareerId != null ? _careers[_selectedCareerId] : null;

  // Constructor - triggers auto login check
  AdminProvider() {
    _checkSavedLogin();
  }

  // ==========================================
  // AUTHENTICATION LOGIC
  // ==========================================

  Future<void> _checkSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLogin = prefs.getBool('admin_logged_in') ?? false;
      if (savedLogin) {
        final success = await DatabaseService.authenticateFirebase();
        if (success) {
          _isAuthenticated = true;
          // Preload curriculum & careers
          await loadCurriculum();
          await loadCareers();
        }
      }
    } catch (e) {
      print('Auto login check failed: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().toLowerCase() == 'admin@gmail.com' && password == 'password') {
      final success = await DatabaseService.authenticateFirebase();
      if (success) {
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('admin_logged_in', true);
        notifyListeners();
        // Load curriculum & careers
        await loadCurriculum();
        await loadCareers();
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _selectedGradeKey = null;
    _selectedSubjectId = null;
    _selectedChapterNumber = null;
    _activeContent = null;
    _curriculum = {};
    _careers = {};
    _selectedCareerId = null;
    _isLoadingCareers = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_logged_in');
    
    await DatabaseService.signOut();
    notifyListeners();
  }

  // ==========================================
  // CURRICULUM ACTIONS
  // ==========================================

  Future<void> loadCurriculum() async {
    _isLoadingCurriculum = true;
    notifyListeners();

    try {
      _curriculum = await DatabaseService.fetchCurriculum();
    } catch (e) {
      print('Error loading curriculum in provider: $e');
    } finally {
      _isLoadingCurriculum = false;
      notifyListeners();
    }
  }

  Future<void> saveCurriculum() async {
    _isLoadingCurriculum = true;
    notifyListeners();

    try {
      await DatabaseService.saveCurriculum(_curriculum);
    } catch (e) {
      print('Error saving curriculum in provider: $e');
      rethrow;
    } finally {
      _isLoadingCurriculum = false;
      notifyListeners();
    }
  }

  void addGrade(String key, Grade grade) {
    _curriculum[key] = grade;
    notifyListeners();
  }

  void updateGrade(String key, Grade grade) {
    if (_curriculum.containsKey(key)) {
      _curriculum[key] = grade;
      notifyListeners();
    }
  }

  void removeGrade(String key) {
    _curriculum.remove(key);
    if (_selectedGradeKey == key) {
      _selectedGradeKey = null;
      _selectedSubjectId = null;
      _selectedChapterNumber = null;
      _activeContent = null;
    }
    notifyListeners();
  }

  void addSubject(String gradeKey, Subject subject) {
    final grade = _curriculum[gradeKey];
    if (grade != null) {
      final updatedSubjects = List<Subject>.from(grade.subjects)..add(subject);
      _curriculum[gradeKey] = Grade(
        name: grade.name,
        description: grade.description,
        emoji: grade.emoji,
        subjects: updatedSubjects,
      );
      notifyListeners();
    }
  }

  void updateSubject(String gradeKey, String subjectId, Subject subject) {
    final grade = _curriculum[gradeKey];
    if (grade != null) {
      final updatedSubjects = grade.subjects.map((s) => s.id == subjectId ? subject : s).toList();
      _curriculum[gradeKey] = Grade(
        name: grade.name,
        description: grade.description,
        emoji: grade.emoji,
        subjects: updatedSubjects,
      );
      notifyListeners();
    }
  }

  void removeSubject(String gradeKey, String subjectId) {
    final grade = _curriculum[gradeKey];
    if (grade != null) {
      final updatedSubjects = grade.subjects.where((s) => s.id != subjectId).toList();
      _curriculum[gradeKey] = Grade(
        name: grade.name,
        description: grade.description,
        emoji: grade.emoji,
        subjects: updatedSubjects,
      );
      if (_selectedGradeKey == gradeKey && _selectedSubjectId == subjectId) {
        _selectedSubjectId = null;
        _selectedChapterNumber = null;
        _activeContent = null;
      }
      notifyListeners();
    }
  }

  void addChapter(String gradeKey, String subjectId, Chapter chapter) {
    final grade = _curriculum[gradeKey];
    if (grade != null) {
      final subjectIndex = grade.subjects.indexWhere((s) => s.id == subjectId);
      if (subjectIndex != -1) {
        final subject = grade.subjects[subjectIndex];
        final updatedChapters = List<Chapter>.from(subject.chapters)..add(chapter);
        
        final updatedSubject = Subject(
          id: subject.id,
          name: subject.name,
          emoji: subject.emoji,
          color: subject.color,
          chapters: updatedChapters,
        );
        
        final updatedSubjects = List<Subject>.from(grade.subjects);
        updatedSubjects[subjectIndex] = updatedSubject;

        _curriculum[gradeKey] = Grade(
          name: grade.name,
          description: grade.description,
          emoji: grade.emoji,
          subjects: updatedSubjects,
        );
        notifyListeners();
      }
    }
  }

  void updateChapter(String gradeKey, String subjectId, int oldNumber, Chapter chapter) {
    final grade = _curriculum[gradeKey];
    if (grade != null) {
      final subjectIndex = grade.subjects.indexWhere((s) => s.id == subjectId);
      if (subjectIndex != -1) {
        final subject = grade.subjects[subjectIndex];
        final updatedChapters = subject.chapters.map((c) => c.number == oldNumber ? chapter : c).toList();
        
        final updatedSubject = Subject(
          id: subject.id,
          name: subject.name,
          emoji: subject.emoji,
          color: subject.color,
          chapters: updatedChapters,
        );
        
        final updatedSubjects = List<Subject>.from(grade.subjects);
        updatedSubjects[subjectIndex] = updatedSubject;

        _curriculum[gradeKey] = Grade(
          name: grade.name,
          description: grade.description,
          emoji: grade.emoji,
          subjects: updatedSubjects,
        );
        notifyListeners();
      }
    }
  }

  void removeChapter(String gradeKey, String subjectId, int chapterNum) {
    final grade = _curriculum[gradeKey];
    if (grade != null) {
      final subjectIndex = grade.subjects.indexWhere((s) => s.id == subjectId);
      if (subjectIndex != -1) {
        final subject = grade.subjects[subjectIndex];
        final updatedChapters = subject.chapters.where((c) => c.number != chapterNum).toList();
        
        final updatedSubject = Subject(
          id: subject.id,
          name: subject.name,
          emoji: subject.emoji,
          color: subject.color,
          chapters: updatedChapters,
        );
        
        final updatedSubjects = List<Subject>.from(grade.subjects);
        updatedSubjects[subjectIndex] = updatedSubject;

        _curriculum[gradeKey] = Grade(
          name: grade.name,
          description: grade.description,
          emoji: grade.emoji,
          subjects: updatedSubjects,
        );
        
        if (_selectedGradeKey == gradeKey && 
            _selectedSubjectId == subjectId && 
            _selectedChapterNumber == chapterNum) {
          _selectedChapterNumber = null;
          _activeContent = null;
        }
        notifyListeners();
      }
    }
  }

  // ==========================================
  // ACTIVE CONTENT MANAGEMENT
  // ==========================================

  void selectGrade(String? key) {
    _selectedGradeKey = key;
    _selectedSubjectId = null;
    _selectedChapterNumber = null;
    _activeContent = null;
    _jsonString = '';
    notifyListeners();
  }

  void selectSubject(String? id) {
    _selectedSubjectId = id;
    _selectedChapterNumber = null;
    _activeContent = null;
    _jsonString = '';
    notifyListeners();
  }

  Future<void> selectChapter(int? number) async {
    _selectedChapterNumber = number;
    _activeContent = null;
    _jsonString = '';
    notifyListeners();

    if (_selectedGradeKey != null && _selectedSubjectId != null && number != null) {
      await loadChapterContent();
    }
  }

  Future<void> loadChapterContent() async {
    if (_selectedGradeKey == null || _selectedSubjectId == null || _selectedChapterNumber == null) return;
    
    _isLoadingContent = true;
    notifyListeners();

    final gradeStr = _selectedGradeKey!.replaceFirst('grade_', '');
    final gradeVal = int.tryParse(gradeStr) ?? 7;

    try {
      final content = await DatabaseService.fetchChapterContent(
        gradeVal,
        _selectedSubjectId!,
        _selectedChapterNumber!,
      );

      if (content != null) {
        _activeContent = content;
        _jsonString = const JsonEncoder.withIndent('  ').convert(content.toJson());
      } else {
        // Create an empty configuration ready for upload
        final grade = _curriculum[_selectedGradeKey];
        final subject = grade?.subjects.firstWhere((s) => s.id == _selectedSubjectId);
        final chapter = subject?.chapters.firstWhere((c) => c.number == _selectedChapterNumber);
        
        _activeContent = ChapterContent.empty(
          gradeVal,
          _selectedSubjectId!,
          _selectedChapterNumber!,
          chapter?.title ?? 'Chapter $_selectedChapterNumber',
        );
        _jsonString = const JsonEncoder.withIndent('  ').convert(_activeContent!.toJson());
      }
    } catch (e) {
      print('Error loading chapter content: $e');
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  void updateActiveContent(ChapterContent content) {
    _activeContent = content;
    _jsonString = const JsonEncoder.withIndent('  ').convert(content.toJson());
    notifyListeners();
  }

  Future<void> saveChapterContent() async {
    if (_selectedGradeKey == null || _selectedSubjectId == null || _selectedChapterNumber == null || _activeContent == null) return;

    _isLoadingContent = true;
    notifyListeners();

    final gradeStr = _selectedGradeKey!.replaceFirst('grade_', '');
    final gradeVal = int.tryParse(gradeStr) ?? 7;

    try {
      await DatabaseService.saveChapterContent(
        gradeVal,
        _selectedSubjectId!,
        _selectedChapterNumber!,
        _activeContent!,
      );
    } catch (e) {
      print('Error saving chapter content in provider: $e');
      rethrow;
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  Future<void> deleteActiveChapterContent() async {
    if (_selectedGradeKey == null || _selectedSubjectId == null || _selectedChapterNumber == null) return;

    _isLoadingContent = true;
    notifyListeners();

    final gradeStr = _selectedGradeKey!.replaceFirst('grade_', '');
    final gradeVal = int.tryParse(gradeStr) ?? 7;

    try {
      await DatabaseService.deleteChapterContent(
        gradeVal,
        _selectedSubjectId!,
        _selectedChapterNumber!,
      );
      _activeContent = null;
      _jsonString = '';
    } catch (e) {
      print('Error deleting chapter content: $e');
      rethrow;
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  // ==========================================
  // JSON IMPORT / EXPORT
  // ==========================================

  void updateJsonString(String val) {
    _jsonString = val;
    notifyListeners();
  }

  /// Returns error string if invalid, or null if successful
  String? validateAndImportJson(String rawJson) {
    try {
      final decoded = json.decode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return 'JSON must be a key-value object.';
      }
      
      // Basic schema validations
      if (!decoded.containsKey('metadata')) {
        return 'Missing required top-level key: "metadata"';
      }
      if (!decoded.containsKey('sections')) {
        return 'Missing required top-level key: "sections"';
      }

      final parsed = ChapterContent.fromJson(decoded);
      _activeContent = parsed;
      _jsonString = const JsonEncoder.withIndent('  ').convert(_activeContent!.toJson());
      notifyListeners();
      return null;
    } catch (e) {
      return 'Syntax or structure error: ${e.toString()}';
    }
  }

  // ==========================================
  // CAREERS STATE METHODS
  // ==========================================

  Future<void> loadCareers() async {
    _isLoadingCareers = true;
    notifyListeners();

    try {
      _careers = await DatabaseService.fetchCareers();
    } catch (e) {
      print('Error loading careers in provider: $e');
    } finally {
      _isLoadingCareers = false;
      notifyListeners();
    }
  }

  void selectCareer(String? id) {
    _selectedCareerId = id;
    notifyListeners();
  }

  void updateCareer(String id, Career career) {
    _careers[id] = career;
    notifyListeners();
  }

  void addCareer(String id, Career career) {
    _careers[id] = career;
    _selectedCareerId = id;
    notifyListeners();
  }

  void removeCareer(String id) {
    _careers.remove(id);
    if (_selectedCareerId == id) {
      _selectedCareerId = null;
    }
    notifyListeners();
  }

  Future<void> saveCareers() async {
    _isLoadingCareers = true;
    notifyListeners();

    try {
      await DatabaseService.saveCareers(_careers);
    } catch (e) {
      print('Error saving careers in provider: $e');
      rethrow;
    } finally {
      _isLoadingCareers = false;
      notifyListeners();
    }
  }

  Future<void> saveSingleCareer(String id) async {
    final career = _careers[id];
    if (career == null) return;

    _isLoadingCareers = true;
    notifyListeners();

    try {
      await DatabaseService.saveCareer(id, career);
    } catch (e) {
      print('Error saving career $id in provider: $e');
      rethrow;
    } finally {
      _isLoadingCareers = false;
      notifyListeners();
    }
  }

  Future<void> deleteCareer(String id) async {
    _isLoadingCareers = true;
    notifyListeners();

    try {
      await DatabaseService.deleteCareer(id);
      _careers.remove(id);
      if (_selectedCareerId == id) {
        _selectedCareerId = null;
      }
    } catch (e) {
      print('Error deleting career $id in provider: $e');
      rethrow;
    } finally {
      _isLoadingCareers = false;
      notifyListeners();
    }
  }

  // ==========================================
  // BULK SEED DATABASE
  // ==========================================

  Future<void> seedDatabase(Map<String, dynamic> seedData) async {
    _isLoadingCurriculum = true;
    _isLoadingContent = true;
    _isLoadingCareers = true;
    notifyListeners();

    try {
      // 1. Seed Careers (if present)
      if (seedData.containsKey('careers') && seedData['careers'] is Map) {
        final Map<String, dynamic> careersMap = Map<String, dynamic>.from(seedData['careers']);
        final Map<String, Career> parsedCareers = {};
        careersMap.forEach((key, value) {
          if (value is Map) {
            parsedCareers[key] = Career.fromJson(Map<String, dynamic>.from(value));
          }
        });
        await DatabaseService.saveCareers(parsedCareers);
        _careers = parsedCareers;
      }

      // 2. Seed Content chapters (if present)
      if (seedData.containsKey('content') && seedData['content'] is Map) {
        final Map<String, dynamic> contentMap = Map<String, dynamic>.from(seedData['content']);
        for (var gradeKey in contentMap.keys) {
          final gradeVal = contentMap[gradeKey];
          if (gradeVal is Map) {
            final gradeStr = gradeKey.replaceFirst('grade_', '');
            final gradeInt = int.tryParse(gradeStr);
            if (gradeInt == null) continue;

            for (var subjectKey in gradeVal.keys) {
              final subjectVal = gradeVal[subjectKey];
              if (subjectVal is Map) {
                for (var chapterIdKey in subjectVal.keys) {
                  final chapterVal = subjectVal[chapterIdKey];
                  if (chapterVal is Map) {
                    final contentObj = ChapterContent.fromJson(Map<String, dynamic>.from(chapterVal));
                    final chNum = contentObj.metadata.chapterNumber;
                    await DatabaseService.saveChapterContent(
                      gradeInt,
                      subjectKey,
                      chNum,
                      contentObj,
                    );
                  }
                }
              }
            }
          }
        }
      }
      
      // Reload curriculum and careers to keep state in sync
      await loadCurriculum();
      await loadCareers();
    } catch (e) {
      print('Seeding database failed: $e');
      rethrow;
    } finally {
      _isLoadingCurriculum = false;
      _isLoadingContent = false;
      _isLoadingCareers = false;
      notifyListeners();
    }
  }
}
