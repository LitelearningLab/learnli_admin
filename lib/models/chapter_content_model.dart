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
  }
  return s.length >= 3 ? s.substring(0, 3).toUpperCase() : s.toUpperCase();
}

class ChapterContent {
  final ChapterMetadata metadata;
  final List<ConceptItem> simpleOverview;
  final List<ReadModeSection> readMode;
  final List<MustKnowTerm> mustKnow;
  final List<GoodToKnowInsight> goodToKnow;
  final List<PreRequisiteItem> preRequisite;
  final List<IndustryInsightItem> industryInsights;
  final List<ChipItem> chips;
  final List<PlusPointTopic> plusPoints;
  final QuizSection quiz;

  ChapterContent({
    required this.metadata,
    required this.simpleOverview,
    required this.readMode,
    required this.mustKnow,
    required this.goodToKnow,
    required this.preRequisite,
    required this.industryInsights,
    required this.chips,
    required this.plusPoints,
    required this.quiz,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    final metadataJson = Map<String, dynamic>.from(json['metadata'] ?? {});
    final sections = Map<String, dynamic>.from(json['sections'] ?? {});

    // Parse simple_overview
    final simpleOverviewJson = sections['simple_overview'] ?? {};
    final List<ConceptItem> simpleOverviewList = [];
    if (simpleOverviewJson['data'] is List) {
      for (var item in simpleOverviewJson['data']) {
        simpleOverviewList.add(ConceptItem.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse read_mode
    final readModeJson = sections['read_mode'] ?? {};
    final List<ReadModeSection> readModeList = [];
    if (readModeJson['data'] is List) {
      for (var item in readModeJson['data']) {
        readModeList.add(ReadModeSection.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse must_know
    final mustKnowJson = sections['must_know'] ?? {};
    final List<MustKnowTerm> mustKnowList = [];
    if (mustKnowJson['data'] is List) {
      for (var item in mustKnowJson['data']) {
        mustKnowList.add(MustKnowTerm.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    // Parse good_to_know
    final goodToKnowJson = sections['good_to_know'] ?? {};
    final List<GoodToKnowInsight> goodToKnowList = [];
    if (goodToKnowJson['data'] is List) {
      for (var item in goodToKnowJson['data']) {
        goodToKnowList.add(GoodToKnowInsight.fromJson(Map<String, dynamic>.from(item)));
      }
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

    return ChapterContent(
      metadata: ChapterMetadata.fromJson(metadataJson),
      simpleOverview: simpleOverviewList,
      readMode: readModeList,
      mustKnow: mustKnowList,
      goodToKnow: goodToKnowList,
      preRequisite: preRequisiteList,
      industryInsights: industryList,
      chips: chipsList,
      plusPoints: plusPointsList,
      quiz: quizSection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'sections': {
        'simple_overview': {
          'type': 'array_of_concepts',
          'data': simpleOverview.map((item) => item.toJson()).toList(),
        },
        'read_mode': {
          'type': 'array_of_sections',
          'data': readMode.map((item) => item.toJson()).toList(),
        },
        'must_know': {
          'type': 'array_of_terms',
          'data': mustKnow.map((item) => item.toJson()).toList(),
        },
        'good_to_know': {
          'type': 'array_of_insights',
          'data': goodToKnow.map((item) => item.toJson()).toList(),
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
      }
    };
  }

  // Helper factory to create empty content
  factory ChapterContent.empty(int grade, String subject, int chapterNum, String title) {
    final prefix = _getSubjectPrefix(subject);
    final subjectDisplayMap = {
      'SCI': 'Science',
      'MATHS': 'Maths',
      'SST': 'Social Studies',
      'ENG': 'English',
      'HIN': 'Hindi',
      'COMP': 'Computer',
    };
    final displaySubject = subjectDisplayMap[prefix] ?? subject;

    return ChapterContent(
      metadata: ChapterMetadata(
        grade: grade,
        subject: displaySubject,
        chapterId: 'G${grade}_${prefix}_CH${chapterNum.toString().padLeft(2, '0')}',
        chapterName: title,
        chapterNumber: chapterNum,
      ),
      simpleOverview: [],
      readMode: [],
      mustKnow: [],
      goodToKnow: [],
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
    );
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

  ChapterMetadata({
    required this.grade,
    required this.subject,
    required this.chapterId,
    required this.chapterName,
    required this.chapterNumber,
    this.formatVersion = '2.0',
    this.outputType = 'structured_json',
    this.interactiveLessonUrl,
  });

  factory ChapterMetadata.fromJson(Map<String, dynamic> json) {
    return ChapterMetadata(
      grade: json['grade'] ?? 7,
      subject: json['subject'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      chapterName: json['chapter_name'] ?? '',
      chapterNumber: json['chapter_number'] ?? 0,
      formatVersion: json['format_version'] ?? '2.0',
      outputType: json['output_type'] ?? 'structured_json',
      interactiveLessonUrl: json['interactive_lesson_url'] ?? json['interactiveLessonUrl'],
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
      if (interactiveLessonUrl != null)
        'interactive_lesson_url': interactiveLessonUrl,
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

class ReadModeSection {
  String heading;
  List<String> paragraphs;
  List<String> keyPoints;
  String example;

  ReadModeSection({
    required this.heading,
    required this.paragraphs,
    required this.keyPoints,
    required this.example,
  });

  factory ReadModeSection.fromJson(Map<String, dynamic> json) {
    return ReadModeSection(
      heading: json['heading'] ?? '',
      paragraphs: List<String>.from(json['paragraphs'] ?? []),
      keyPoints: List<String>.from(json['key_points'] ?? []),
      example: json['example'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'paragraphs': paragraphs,
      'key_points': keyPoints,
      'example': example,
    };
  }
}

class MustKnowTerm {
  String term;
  String definition;
  String importance;

  MustKnowTerm({required this.term, required this.definition, required this.importance});

  factory MustKnowTerm.fromJson(Map<String, dynamic> json) {
    return MustKnowTerm(
      term: json['term'] ?? '',
      definition: json['definition'] ?? '',
      importance: json['importance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'definition': definition,
      'importance': importance,
    };
  }
}

class GoodToKnowInsight {
  String title;
  String content;
  String connection;

  GoodToKnowInsight({required this.title, required this.content, required this.connection});

  factory GoodToKnowInsight.fromJson(Map<String, dynamic> json) {
    return GoodToKnowInsight(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      connection: json['connection'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'connection': connection,
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

class PlusPointTopic {
  String id;
  String title;
  String summary;
  List<String> keyFacts;
  String commonMistake;
  bool aiEnabled;
  bool evaluationReady;

  PlusPointTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.keyFacts,
    required this.commonMistake,
    required this.aiEnabled,
    required this.evaluationReady,
  });

  factory PlusPointTopic.fromJson(Map<String, dynamic> json) {
    final content = Map<String, dynamic>.from(json['content'] ?? {});
    return PlusPointTopic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: content['summary'] ?? '',
      keyFacts: List<String>.from(content['key_facts'] ?? []),
      commonMistake: content['common_mistake'] ?? '',
      aiEnabled: json['ai_enabled'] ?? true,
      evaluationReady: json['evaluation_ready'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': {
        'summary': summary,
        'key_facts': keyFacts,
        'common_mistake': commonMistake,
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
