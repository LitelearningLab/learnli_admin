import 'dart:convert';

String _getSubjectPrefix(String subject) {
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
  } else if (s.startsWith('chem') || s.startsWith('che')) {
    return 'CHE';
  } else if (s.startsWith('phys') || s.startsWith('phy')) {
    return 'PHY';
  } else if (s.startsWith('biol') || s.startsWith('bio')) {
    return 'BIO';
  }
  return s.length >= 3 ? s.substring(0, 3).toUpperCase() : s.toUpperCase();
}

class ChapterContent {
  final ChapterMetadata metadata;
  String? simpleOverviewUrl;
  final List<PreRequisiteItem> preRequisite;
  final List<IndustryInsightItem> industryInsights;
  final List<ChipItem> chips;
  final List<PlusPointTopic> plusPoints;
  final QuizSection quiz;
  final List<PronunciationWord> pronunciationLab;
  final PlusPointQuestionBank plusPointQuestionBank;

  ChapterContent({
    required this.metadata,
    this.simpleOverviewUrl,
    required this.preRequisite,
    required this.industryInsights,
    required this.chips,
    required this.plusPoints,
    required this.quiz,
    required this.pronunciationLab,
    required this.plusPointQuestionBank,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    final metadataJson = Map<String, dynamic>.from(json['metadata'] ?? {});
    final sections = Map<String, dynamic>.from(json['sections'] ?? {});

    // Parse simple_overview
    final simpleOverviewJson = sections['simple_overview'] ?? {};
    String? simpleOverviewUrl;
    if (simpleOverviewJson is Map) {
      simpleOverviewUrl = simpleOverviewJson['url'] as String?;
    }



    // Parse pre_requisite
    final prerequisiteJson = sections['pre_requisite'] ?? {};
    final List<PreRequisiteItem> preRequisiteList = [];
    if (prerequisiteJson['data'] is List) {
      for (var item in prerequisiteJson['data']) {
        preRequisiteList.add(PreRequisiteItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse industry_insights
    final industryJson = sections['industry_insights'] ?? {};
    final List<IndustryInsightItem> industryList = [];
    if (industryJson['data'] is List) {
      for (var item in industryJson['data']) {
        industryList.add(IndustryInsightItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse chips
    final chipsJson = sections['chips'] ?? sections['ai_chips'] ?? {};
    final List<ChipItem> chipsList = [];
    final chipsData = chipsJson['items'] ?? chipsJson['data'];
    if (chipsData is List) {
      for (var item in chipsData) {
        chipsList.add(ChipItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse plus_points
    final plusPointsJson = sections['plus_points'] ?? {};
    final List<PlusPointTopic> plusPointsList = [];
    final plusPointsData = plusPointsJson['items'] ?? plusPointsJson['data'];
    if (plusPointsData is List) {
      for (var item in plusPointsData) {
        plusPointsList.add(PlusPointTopic.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse quiz
    final quizJson = sections['quiz'] ?? {};
    final quizSection = QuizSection.fromJson(Map<String, dynamic>.from(quizJson));

    // Parse pronunciation_lab
    final pronunciationJson = sections['pronunciation_lab'] ?? {};
    final List<PronunciationWord> pronunciationList = [];
    final pronunciationData = pronunciationJson['data'] ?? pronunciationJson['items'];
    if (pronunciationData is List) {
      for (var item in pronunciationData) {
        pronunciationList.add(PronunciationWord.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse plus_point_question_bank
    final ppbJson = sections['plus_point_question_bank'] ?? {};
    final plusPointQB = PlusPointQuestionBank.fromJson(Map<String, dynamic>.from(ppbJson));

    return ChapterContent(
      metadata: ChapterMetadata.fromJson(metadataJson),
      simpleOverviewUrl: simpleOverviewUrl,
      preRequisite: preRequisiteList,
      industryInsights: industryList,
      chips: chipsList,
      plusPoints: plusPointsList,
      quiz: quizSection,
      pronunciationLab: pronunciationList,
      plusPointQuestionBank: plusPointQB,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'sections': {
        'simple_overview': {
          'type': 'html',
          'url': simpleOverviewUrl,
        },

        'pre_requisite': {
          'type': 'array_of_prerequisites',
          'data': preRequisite.map((item) => item.toJson()).toList(),
        },
        'industry_insights': {
          'type': 'array_of_applications',
          'data': industryInsights.map((item) => item.toJson()).toList(),
        },
        'chips': {
          'type': 'array_of_chips',
          'items': chips.map((item) => item.toJson()).toList(),
        },
        'plus_points': {
          'type': 'array_of_topics',
          'items': plusPoints.map((item) => item.toJson()).toList(),
        },
        'quiz': quiz.toJson(),
        'pronunciation_lab': {
          'type': 'array_of_words',
          'data': pronunciationLab.map((item) => item.toJson()).toList(),
        },
        'plus_point_question_bank': plusPointQuestionBank.toJson(),
      }
    };
  }

  // Helper factory to create empty content
  factory ChapterContent.empty(int grade, String subject, int chapterNum, String title, {String? interactiveLessonUrl, List<InteractiveDiagram>? interactiveDiagrams}) {
    final prefix = _getSubjectPrefix(subject);
    final subjectDisplayMap = {
      'SCI': 'Science',
      'MATHS': 'Maths',
      'SST': 'Social Studies',
      'ENG': 'English',
      'HIN': 'Hindi',
      'COMP': 'Computer',
      'CHE': 'Chemistry',
      'PHY': 'Physics',
      'BIO': 'Biology',
    };
    final displaySubject = subjectDisplayMap[prefix] ?? subject;

    return ChapterContent(
      metadata: ChapterMetadata(
        grade: grade,
        subject: displaySubject,
        chapterId: 'G${grade}_${prefix}_CH${chapterNum.toString().padLeft(2, '0')}',
        chapterName: title,
        chapterNumber: chapterNum,
        interactiveLessonUrl: interactiveLessonUrl,
        interactiveDiagrams: interactiveDiagrams,
      ),
      simpleOverviewUrl: null,
      preRequisite: [],
      industryInsights: [],
      chips: [],
      plusPoints: [],
      quiz: QuizSection(
        title: 'Chapter Quiz',
        instructions: 'Choose the correct answer for each question.',
        timeLimitMinutes: 15,
        passingScore: 60,
        questions: [],
      ),
      pronunciationLab: [],
      plusPointQuestionBank: PlusPointQuestionBank(
        chapterNumber: chapterNum.toString(),
        chapterName: title,
        patterns: [],
      ),
    );
  }
}

class InteractiveDiagram {
  String id;
  String title;
  String thumbnail;
  String url;

  InteractiveDiagram({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.url,
  });

  factory InteractiveDiagram.fromJson(Map<String, dynamic> json) {
    return InteractiveDiagram(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'url': url,
    };
  }
}

class ChapterMetadata {
  int grade;
  String subject;
  String chapterId;
  String chapterName;
  int chapterNumber;
  String formatVersion;
  String outputType;
  String? interactiveLessonUrl;
  List<InteractiveDiagram>? interactiveDiagrams;

  ChapterMetadata({
    required this.grade,
    required this.subject,
    required this.chapterId,
    required this.chapterName,
    required this.chapterNumber,
    this.formatVersion = '2.1',
    this.outputType = 'structured_json',
    this.interactiveLessonUrl,
    this.interactiveDiagrams,
  });

  factory ChapterMetadata.fromJson(Map<String, dynamic> json) {
    var diagramsJson = json['interactiveDiagrams'] as List?;
    List<InteractiveDiagram>? diagramsList;
    if (diagramsJson != null) {
      diagramsList = diagramsJson
          .map((d) => InteractiveDiagram.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    } else if (json['interactive_diagram_url'] != null || json['interactiveDiagramUrl'] != null) {
      final singleUrl = json['interactive_diagram_url'] ?? json['interactiveDiagramUrl'];
      if (singleUrl != null && singleUrl.toString().isNotEmpty) {
        diagramsList = [
          InteractiveDiagram(
            id: 'diagram_001',
            title: 'Interactive Diagram',
            thumbnail: '',
            url: singleUrl.toString(),
          )
        ];
      }
    }

    return ChapterMetadata(
      grade: json['grade'] ?? 7,
      subject: json['subject'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      chapterName: json['chapter_name'] ?? '',
      chapterNumber: json['chapter_number'] ?? 0,
      formatVersion: json['format_version'] ?? '2.1',
      outputType: json['output_type'] ?? 'structured_json',
      interactiveLessonUrl: json['interactive_lesson_url'] ?? json['interactiveLessonUrl'],
      interactiveDiagrams: diagramsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grade': grade,
      'subject': subject,
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'chapter_number': chapterNumber,
      'format_version': formatVersion,
      'output_type': outputType,
      if (interactiveLessonUrl != null) ...{
        'interactive_lesson_url': interactiveLessonUrl,
        'interactiveLessonUrl': interactiveLessonUrl,
      },
      if (interactiveDiagrams != null) ...{
        'interactiveDiagrams': interactiveDiagrams!.map((d) => d.toJson()).toList(),
      }
    };
  }
}

class ConceptItem {
  String title;
  String explanation;

  ConceptItem({required this.title, required this.explanation});

  factory ConceptItem.fromJson(Map<String, dynamic> json) {
    return ConceptItem(
      title: json['title'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'explanation': explanation,
    };
  }
}


class PreRequisiteItem {
  String concept;
  String explanation;
  String connection;

  PreRequisiteItem({required this.concept, required this.explanation, required this.connection});

  factory PreRequisiteItem.fromJson(Map<String, dynamic> json) {
    return PreRequisiteItem(
      concept: json['concept'] ?? '',
      explanation: json['explanation'] ?? '',
      connection: json['connection'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'concept': concept,
      'explanation': explanation,
      'connection': connection,
    };
  }
}

class IndustryInsightItem {
  String field;
  String application;
  String exampleRole;

  IndustryInsightItem({required this.field, required this.application, required this.exampleRole});

  factory IndustryInsightItem.fromJson(Map<String, dynamic> json) {
    return IndustryInsightItem(
      field: json['field'] ?? '',
      application: json['application'] ?? '',
      exampleRole: json['example_role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'application': application,
      'example_role': exampleRole,
    };
  }
}

class ChipItem {
  String id;
  String title;
  String preview;
  List<String> paragraphs;
  List<String> keyPoints;
  bool aiEnabled;

  ChipItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.paragraphs,
    required this.keyPoints,
    required this.aiEnabled,
  });

  factory ChipItem.fromJson(Map<String, dynamic> json) {
    final explanation = Map<String, dynamic>.from(json['explanation'] ?? {});
    return ChipItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      preview: json['preview'] ?? '',
      paragraphs: List<String>.from(explanation['paragraphs'] ?? []),
      keyPoints: List<String>.from(explanation['key_points'] ?? []),
      aiEnabled: json['ai_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'explanation': {
        'paragraphs': paragraphs,
        'key_points': keyPoints,
      },
      'ai_enabled': aiEnabled,
    };
  }
}

class KeyFact {
  String? id;
  String title;

  KeyFact({this.id, required this.title});

  factory KeyFact.fromJson(dynamic json) {
    if (json is String) {
      return KeyFact(title: json);
    } else if (json is Map) {
      return KeyFact(
        id: json['id']?.toString(),
        title: json['title']?.toString() ?? '',
      );
    }
    return KeyFact(title: '');
  }

  dynamic toJson() {
    if (id == null || id!.trim().isEmpty) {
      return title;
    }
    return {
      'id': id,
      'title': title,
    };
  }
}

class PlusPointTopic {
  String id;
  String title;
  List<KeyFact> keyFacts;
  bool aiEnabled;
  bool evaluationReady;

  PlusPointTopic({
    required this.id,
    required this.title,
    required this.keyFacts,
    required this.aiEnabled,
    required this.evaluationReady,
  });

  factory PlusPointTopic.fromJson(Map<String, dynamic> json) {
    final content = Map<String, dynamic>.from(json['content'] ?? {});
    final rawFacts = content['key_facts'] ?? [];
    final List<KeyFact> parsedFacts = [];
    if (rawFacts is List) {
      for (var item in rawFacts) {
        parsedFacts.add(KeyFact.fromJson(item));
      }
    }
    return PlusPointTopic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      keyFacts: parsedFacts,
      aiEnabled: json['ai_enabled'] ?? true,
      evaluationReady: json['evaluation_ready'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': {
        'key_facts': keyFacts.map((e) => e.toJson()).toList(),
      },
      'ai_enabled': aiEnabled,
      'evaluation_ready': evaluationReady,
    };
  }
}

class QuizSection {
  String title;
  String instructions;
  int timeLimitMinutes;
  int passingScore;
  List<QuizQuestion> questions;

  QuizSection({
    required this.title,
    required this.instructions,
    required this.timeLimitMinutes,
    required this.passingScore,
    required this.questions,
  });

  factory QuizSection.fromJson(Map<String, dynamic> json) {
    final List<QuizQuestion> questionsList = [];
    if (json['questions'] is List) {
      for (var item in json['questions']) {
        questionsList.add(QuizQuestion.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return QuizSection(
      title: json['title'] ?? 'Chapter Quiz',
      instructions: json['instructions'] ?? '',
      timeLimitMinutes: json['time_limit_minutes'] ?? 15,
      passingScore: json['passing_score'] ?? 60,
      questions: questionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'instructions': instructions,
      'time_limit_minutes': timeLimitMinutes,
      'passing_score': passingScore,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class QuizQuestion {
  dynamic id;
  String questionText;
  List<QuizOption> options;
  String correctAnswer;
  String explanation;
  String difficulty;
  String concept;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.concept,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final List<QuizOption> optionsList = [];

    // The quiz question options in DB might be structured as a list of options:
    // "options": [ {"key": "A", "text": "value"}, ... ]
    // or as a map: "options": { "A": "value", ... } (sometimes handled in ChapterContentService)
    // We should support BOTH structures!
    if (json['options'] is List) {
      for (var opt in json['options']) {
        optionsList.add(QuizOption.fromJson(Map<String, dynamic>.from(opt)));
      }
    } else if (json['options'] is Map) {
      final optMap = Map<String, dynamic>.from(json['options']);
      optMap.forEach((key, value) {
        optionsList.add(QuizOption(key: key, text: value.toString()));
      });
    }

    return QuizQuestion(
      id: json['id'] ?? 0,
      questionText: json['question_text'] ?? json['question'] ?? '',
      options: optionsList,
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      concept: json['concept'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'options': options.map((o) => o.toJson()).toList(),
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'concept': concept,
    };
  }
}

class QuizOption {
  String key;
  String text;

  QuizOption({required this.key, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      key: json['key'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'text': text,
    };
  }
}

class PronunciationWord {
  String file;
  String isPriority;
  String syllables;
  String text;
  String pronun;
  bool downloadStatus;
  String localPath;
  List<String> sentenceSamples;
  List<String> meaningSamples;

  PronunciationWord({
    this.file = '',
    this.isPriority = 'false',
    this.syllables = '',
    this.text = '',
    this.pronun = '',
    this.downloadStatus = false,
    this.localPath = '',
    required this.sentenceSamples,
    required this.meaningSamples,
  });

  factory PronunciationWord.fromJson(Map<String, dynamic> json) {
    return PronunciationWord(
      file: json['file'] ?? '',
      isPriority: json['isPriority']?.toString() ?? 'false',
      syllables: json['syllables']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      pronun: json['pronun']?.toString() ?? '',
      downloadStatus: json['downloadStatus'] == 1 || json['downloadStatus'] == true,
      localPath: json['localPath'] ?? '',
      sentenceSamples: json['sentenceSamples'] is List
          ? List<String>.from(json['sentenceSamples'])
          : json['sentenceSamples'] is String && json['sentenceSamples'].toString().isNotEmpty
              ? List<String>.from(jsonDecode(json['sentenceSamples']))
              : [],
      meaningSamples: json['meaningSamples'] is List
          ? List<String>.from(json['meaningSamples'])
          : json['meaningSamples'] is String && json['meaningSamples'].toString().isNotEmpty
              ? List<String>.from(jsonDecode(json['meaningSamples']))
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'isPriority': isPriority,
      'syllables': syllables,
      'text': text,
      'pronun': pronun,
      'downloadStatus': downloadStatus,
      'localPath': localPath,
      'sentenceSamples': sentenceSamples,
      'meaningSamples': meaningSamples,
    };
  }
}

class PlusPointQuestionBank {
  String? chapterNumber;
  String? chapterName;
  List<PlusPointPattern> patterns;

  PlusPointQuestionBank({
    this.chapterNumber,
    this.chapterName,
    required this.patterns,
  });

  factory PlusPointQuestionBank.fromJson(Map<String, dynamic> json) {
    final List<PlusPointPattern> patternList = [];
    if (json['patterns'] is List) {
      for (var item in json['patterns']) {
        patternList.add(PlusPointPattern.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return PlusPointQuestionBank(
      chapterNumber: json['chapter_number']?.toString(),
      chapterName: json['chapter_name']?.toString(),
      patterns: patternList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'plus_point_question_bank',
      'chapter_number': chapterNumber,
      'chapter_name': chapterName,
      'patterns': patterns.map((p) => p.toJson()).toList(),
    };
  }
}

class PlusPointPattern {
  String id;
  String conceptId;
  String conceptName;
  String patternNumber;
  String patternName;
  int? marks;
  List<PlusPointQuestion> questions;

  PlusPointPattern({
    required this.id,
    required this.conceptId,
    required this.conceptName,
    required this.patternNumber,
    required this.patternName,
    this.marks,
    required this.questions,
  });

  factory PlusPointPattern.fromJson(Map<String, dynamic> json) {
    final List<PlusPointQuestion> questionList = [];
    if (json['questions'] is List) {
      for (var item in json['questions']) {
        questionList.add(PlusPointQuestion.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return PlusPointPattern(
      id: json['id']?.toString() ?? '',
      conceptId: json['concept_id']?.toString() ?? '',
      conceptName: json['concept_name']?.toString() ?? '',
      patternNumber: json['pattern_number']?.toString() ?? '',
      patternName: json['pattern_name']?.toString() ?? '',
      marks: json['marks'] != null ? int.tryParse(json['marks'].toString()) : null,
      questions: questionList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concept_id': conceptId,
      'concept_name': conceptName,
      'pattern_number': patternNumber,
      'pattern_name': patternName,
      'questions': questions.map((q) => q.toJson()).toList(),
      if (marks != null) 'marks': marks,
    };
  }
}

class PlusPointQuestion {
  int questionNumber;
  String instruction;
  String equationLatex;
  String source;

  PlusPointQuestion({
    required this.questionNumber,
    required this.instruction,
    required this.equationLatex,
    required this.source,
  });

  factory PlusPointQuestion.fromJson(Map<String, dynamic> json) {
    return PlusPointQuestion(
      questionNumber: int.tryParse(json['question_number']?.toString() ?? '') ?? 0,
      instruction: json['instruction']?.toString() ?? '',
      equationLatex: json['equation_latex']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_number': questionNumber,
      'instruction': instruction,
      'equation_latex': equationLatex,
      'source': source,
    };
  }
}
