class Chapter {
  final int number;
  final String title;
  final String? interactiveLessonUrl;

  Chapter({
    required this.number,
    required this.title,
    this.interactiveLessonUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      number: json['number'] ?? 0,
      title: json['title'] ?? '',
      interactiveLessonUrl: json['interactiveLessonUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      if (interactiveLessonUrl != null && interactiveLessonUrl!.isNotEmpty)
        'interactiveLessonUrl': interactiveLessonUrl,
    };
  }
}

class Subject {
  final String id;
  final String name;
  final String emoji;
  final String color;
  final List<Chapter> chapters;

  Subject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.chapters,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    List<Chapter> chaptersList = [];

    if (json['chapters'] is List) {
      chaptersList = (json['chapters'] as List)
          .map((c) => Chapter.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    } else if (json['chapters'] is Map) {
      final chaptersMap = Map<String, dynamic>.from(json['chapters']);
      chaptersList = chaptersMap.values
          .map((c) => Chapter.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '',
      color: json['color'] ?? '#FFFFFF',
      chapters: chaptersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }
}

class Grade {
  final String name;
  final String description;
  final String emoji;
  final List<Subject> subjects;

  Grade({
    required this.name,
    required this.description,
    required this.emoji,
    required this.subjects,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    List<Subject> subjectsList = [];

    if (json['subjects'] is List) {
      subjectsList = (json['subjects'] as List)
          .map((s) => Subject.fromJson(Map<String, dynamic>.from(s)))
          .toList();
    } else if (json['subjects'] is Map) {
      final subjectsMap = Map<String, dynamic>.from(json['subjects']);
      subjectsList = subjectsMap.entries.map((entry) {
        final subjectData = Map<String, dynamic>.from(entry.value);
        return Subject.fromJson({
          ...subjectData,
          'id': entry.key,
        });
      }).toList();
    }

    return Grade(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🎓',
      subjects: subjectsList,
    );
  }

  Map<String, dynamic> toJson() {
    // Map subjects back to a key-value structure where key is the subject ID
    final subjectsMap = <String, dynamic>{};
    for (var subject in subjects) {
      subjectsMap[subject.id] = subject.toJson();
    }

    return {
      'name': name,
      'description': description,
      'emoji': emoji,
      'subjects': subjectsMap,
    };
  }
}
