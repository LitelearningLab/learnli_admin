import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/curriculum_models.dart';
import '../models/chapter_content_model.dart';
import '../models/career_models.dart';

class DatabaseService {
  static final FirebaseDatabase _db = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Authenticate with Firebase using standard credentials behind the scenes
  static Future<bool> authenticateFirebase() async {
    try {
      if (_auth.currentUser != null) {
        return true;
      }
      await _auth.signInWithEmailAndPassword(
        email: 'litelearninglab@gmail.com',
        password: 'password',
      );
      print('✅ Authenticated with Firebase');
      return true;
    } catch (e) {
      print('❌ Firebase authentication error: $e');
      // If sign in fails, attempt to create
      try {
        await _auth.createUserWithEmailAndPassword(
          email: 'litelearninglab@gmail.com',
          password: 'password',
        );
        print('✅ Created and authenticated Firebase user');
        return true;
      } catch (createErr) {
        print('❌ Failed to create Firebase user: $createErr');
        return false;
      }
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Map subject identifier to subject code/prefix (e.g. 'science_7' -> 'SCI', 'mathematics_7' -> 'MATHS')
  static String getSubjectPrefix(String subject) {
    final s = subject.trim().toLowerCase();
    if (s.startsWith('sci')) {
      return 'SCI';
    } else if (s.startsWith('math') || s.startsWith('mat')) {
      return 'MATHS';
    } else if (s.startsWith('social') || s.startsWith('sst') || s.startsWith('soc')) {
      return 'SST';
    } else if (s.startsWith('eng')) {
      return 'ENG';
    } else if (s.startsWith('hin')) {
      return 'HIN';
    } else if (s.startsWith('comp') || s.startsWith('com')) {
      return 'COMP';
    }
    // Fallback: use first 3 chars capitalized or whatever
    return s.length >= 3 ? s.substring(0, 3).toUpperCase() : s.toUpperCase();
  }

  /// Map subject code to Firebase folder name
  static String getSubjectFolder(String subject) {
    final prefix = getSubjectPrefix(subject);
    final subjectMap = {
      'SCI': 'science',
      'MATHS': 'math',
      'ENG': 'english',
      'SST': 'social',
      'HIN': 'hindi',
      'COMP': 'computer',
    };

    return subjectMap[prefix] ?? subject.toLowerCase();
  }

  /// Get database path for a chapter
  static String getChapterPath(int grade, String subjectCode, int chapterNumber) {
    final gradeFolder = 'grade_$grade';
    final subjectFolder = getSubjectFolder(subjectCode);
    final prefix = getSubjectPrefix(subjectCode);
    final chapterStr = chapterNumber.toString().padLeft(2, '0');
    final idPattern = 'G${grade}_${prefix}_CH$chapterStr';
    
    return 'content/$gradeFolder/$subjectFolder/$idPattern';
  }

  // ==========================================
  // CURRICULUM API
  // ==========================================

  /// Fetch full curriculum
  static Future<Map<String, Grade>> fetchCurriculum() async {
    try {
      await authenticateFirebase();
      final snapshot = await _db.ref('curriculum').get();
      if (!snapshot.exists || snapshot.value == null) {
        return {};
      }

      final Map<String, Grade> curriculum = {};
      final rawData = _toStringDynamicMap(snapshot.value);

      rawData.forEach((key, value) {
        if (value is Map) {
          try {
            curriculum[key] = Grade.fromJson(_toStringDynamicMap(value));
          } catch (e) {
            print('Error parsing grade $key: $e');
          }
        }
      });

      return curriculum;
    } catch (e) {
      print('Error fetching curriculum: $e');
      rethrow;
    }
  }

  /// Save full curriculum and initialize/update chapter contents
  static Future<void> saveCurriculum(
    Map<String, Grade> curriculum,
    Map<String, Grade> originalCurriculum,
  ) async {
    try {
      await authenticateFirebase();
      final Map<String, dynamic> dataToSave = {};
      curriculum.forEach((key, value) {
        dataToSave[key] = value.toJson();
      });

      // 1. Write the main curriculum node
      await _db.ref('curriculum').set(dataToSave);
      print('✅ Curriculum saved successfully');

      // 2. Compare and sync corresponding chapter content nodes
      for (var gradeEntry in curriculum.entries) {
        final gradeKey = gradeEntry.key;
        final grade = gradeEntry.value;
        final gradeStr = gradeKey.replaceFirst('grade_', '');
        final gradeVal = int.tryParse(gradeStr) ?? 7;

        final originalGrade = originalCurriculum[gradeKey];

        for (var subject in grade.subjects) {
          final originalSubject = originalGrade?.subjects.firstWhere(
            (s) => s.id == subject.id,
            orElse: () => Subject(id: '', name: '', emoji: '', color: '', chapters: []),
          );

          for (var chapter in subject.chapters) {
            final originalChapter = originalSubject?.chapters.firstWhere(
              (c) => c.number == chapter.number,
              orElse: () => Chapter(number: -1, title: ''),
            );

            final path = getChapterPath(gradeVal, subject.id, chapter.number);

            if (originalChapter == null || originalChapter.number == -1) {
              // This is a newly added chapter!
              // Double check if it already exists in the database to prevent overwriting
              final existingSnap = await _db.ref(path).get();
              if (!existingSnap.exists) {
                final prefix = getSubjectPrefix(subject.id);
                final chapterStr = chapter.number.toString().padLeft(2, '0');
                final idPattern = 'G${gradeVal}_${prefix}_CH$chapterStr';
                print('Initializing empty chapter content for new chapter $idPattern at $path');
                final newContent = ChapterContent.empty(
                  gradeVal,
                  subject.id,
                  chapter.number,
                  chapter.title,
                  interactiveLessonUrl: chapter.interactiveLessonUrl,
                  interactiveDiagrams: chapter.interactiveDiagrams != null
                      ? chapter.interactiveDiagrams!.map((d) => InteractiveDiagram(
                          id: d.id,
                          title: d.title,
                          thumbnail: d.thumbnail,
                          url: d.url,
                        )).toList()
                      : null,
                );
                await _db.ref(path).set(newContent.toJson());
              } else {
                // If it already exists, just make sure the name matches
                final existingContent = ChapterContent.fromJson(
                  _toStringDynamicMap(existingSnap.value),
                );
                if (existingContent.metadata.chapterName != chapter.title) {
                  print('Updating title of existing chapter content at $path');
                  await _db.ref('$path/metadata/chapter_name').set(chapter.title);
                }
              }
            } else if (originalChapter.title != chapter.title) {
              // The chapter exists but its title was renamed!
              print('Updating chapter title from "${originalChapter.title}" to "${chapter.title}" at $path');
              await _db.ref('$path/metadata/chapter_name').set(chapter.title);
            }
          }
        }
      }
      print('✅ All chapters synced successfully in DatabaseService.saveCurriculum');
    } catch (e) {
      print('Error saving curriculum: $e');
      rethrow;
    }
  }

  // ==========================================
  // CHAPTER CONTENT API
  // ==========================================

  /// Fetch chapter content
  static Future<ChapterContent?> fetchChapterContent(
    int grade,
    String subjectCode,
    int chapterNumber,
  ) async {
    try {
      await authenticateFirebase();
      final path = getChapterPath(grade, subjectCode, chapterNumber);
      print('Fetching chapter from path: $path');
      final snapshot = await _db.ref(path).get();

      if (!snapshot.exists || snapshot.value == null) {
        print('Chapter content does not exist at $path');
        return null;
      }

      final rawData = _toStringDynamicMap(snapshot.value);
      return ChapterContent.fromJson(rawData);
    } catch (e) {
      print('Error fetching chapter content: $e');
      rethrow;
    }
  }

  /// Save chapter content
  static Future<void> saveChapterContent(
    int grade,
    String subjectCode,
    int chapterNumber,
    ChapterContent content,
  ) async {
    try {
      await authenticateFirebase();
      final path = getChapterPath(grade, subjectCode, chapterNumber);
      print('Saving chapter to path: $path');
      final data = content.toJson();
      await _db.ref(path).set(data);
      print('✅ Chapter content saved successfully at $path');
    } catch (e) {
      print('Error saving chapter content: $e');
      rethrow;
    }
  }

  /// Delete chapter content
  static Future<void> deleteChapterContent(
    int grade,
    String subjectCode,
    int chapterNumber,
  ) async {
    try {
      await authenticateFirebase();
      final path = getChapterPath(grade, subjectCode, chapterNumber);
      print('Deleting chapter at path: $path');
      await _db.ref(path).remove();
      print('✅ Chapter content deleted successfully');
    } catch (e) {
      print('Error deleting chapter content: $e');
      rethrow;
    }
  }

  /// Upload HTML file to Firebase Storage and return its download URL
  static Future<String?> uploadHtmlFile(String fileName, Uint8List fileBytes) async {
    try {
      await authenticateFirebase();
      final storageRef = FirebaseStorage.instance.ref().child('lessons/$fileName');
      final uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: 'text/html'),
      );
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ HTML file uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading HTML file: $e');
      rethrow;
    }
  }

  /// Upload image file to Firebase Storage and return its download URL
  static Future<String?> uploadImageFile(String fileName, Uint8List fileBytes) async {
    try {
      await authenticateFirebase();
      String contentType = 'image/png';
      if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (fileName.toLowerCase().endsWith('.gif')) {
        contentType = 'image/gif';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      }

      final storageRef = FirebaseStorage.instance.ref().child('thumbnails/$fileName');
      final uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(contentType: contentType),
      );
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('✅ Image file uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image file: $e');
      rethrow;
    }
  }

  // ==========================================
  // CAREERS API
  // ==========================================

  /// Fetch all careers
  static Future<Map<String, Career>> fetchCareers() async {
    try {
      await authenticateFirebase();
      final snapshot = await _db.ref('careers').get();
      if (!snapshot.exists || snapshot.value == null) {
        return {};
      }

      final Map<String, Career> result = {};
      final rawData = _toStringDynamicMap(snapshot.value);
      rawData.forEach((key, value) {
        if (value is Map) {
          result[key] = Career.fromJson(_toStringDynamicMap(value));
        }
      });
      return result;
    } catch (e) {
      print('Error fetching careers: $e');
      rethrow;
    }
  }

  /// Save all careers in bulk
  static Future<void> saveCareers(Map<String, Career> careers) async {
    try {
      await authenticateFirebase();
      final Map<String, dynamic> data = {};
      careers.forEach((key, value) {
        data[key] = value.toJson();
      });
      await _db.ref('careers').set(data);
      print('✅ Careers saved successfully');
    } catch (e) {
      print('Error saving careers: $e');
      rethrow;
    }
  }

  /// Save a single career
  static Future<void> saveCareer(String id, Career career) async {
    try {
      await authenticateFirebase();
      await _db.ref('careers/$id').set(career.toJson());
      print('✅ Career $id saved successfully');
    } catch (e) {
      print('Error saving career $id: $e');
      rethrow;
    }
  }

  /// Delete a single career
  static Future<void> deleteCareer(String id) async {
    try {
      await authenticateFirebase();
      await _db.ref('careers/$id').remove();
      print('✅ Career $id deleted successfully');
    } catch (e) {
      print('Error deleting career $id: $e');
      rethrow;
    }
  }

  // ==========================================
  // HELPERS
  // ==========================================

  static Map<String, dynamic> _toStringDynamicMap(dynamic raw) {
    if (raw is! Map) return {};

    final result = <String, dynamic>{};
    raw.forEach((key, value) {
      result[key.toString()] = _normalizeValue(value);
    });
    return result;
  }

  static dynamic _normalizeValue(dynamic value) {
    if (value is Map) {
      return _toStringDynamicMap(value);
    }
    if (value is List) {
      return value.map(_normalizeValue).toList();
    }
    return value;
  }
}
