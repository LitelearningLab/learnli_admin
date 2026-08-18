import 'package:flutter_test/flutter_test.dart';
import 'package:learnli_admin/models/chapter_content_model.dart';

List<dynamic>? parseDecoded(dynamic decoded, String mapKey, List<String> alternativeMapKeys) {
  List<dynamic>? list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map) {
    final possibleKeys = [mapKey, ...alternativeMapKeys, 'data', 'items'];
    for (var key in possibleKeys) {
      if (decoded.containsKey(key) && decoded[key] is List) {
        list = decoded[key] as List;
        break;
      }
    }
    if (list == null && decoded.containsKey('sub_topics') && decoded['sub_topics'] is List) {
      final subTopics = decoded['sub_topics'] as List;
      final flatList = <dynamic>[];
      for (var subTopic in subTopics) {
        if (subTopic is Map) {
          for (var key in possibleKeys) {
            if (subTopic.containsKey(key) && subTopic[key] is List) {
              flatList.addAll(subTopic[key] as List);
              break;
            }
          }
        }
      }
      if (flatList.isNotEmpty) {
        list = flatList;
      }
    }
  }
  return list;
}

void main() {
  group('PreRequisiteItem JSON Deserialization', () {
    test('should parse standard concept/explanation/connection format', () {
      final json = {
        'concept': 'Standard Concept',
        'explanation': 'Standard Explanation',
        'connection': 'Standard Connection',
      };

      final item = PreRequisiteItem.fromJson(json);

      expect(item.concept, 'Standard Concept');
      expect(item.explanation, 'Standard Explanation');
      expect(item.connection, 'Standard Connection');
    });

    test('should parse fallback prerequisite terminology and example keys', () {
      final json = {
        'prerequisite_terminology_concept_process': 'Fall back Terminology',
        'explanation': 'Explanation text',
        'formula_rule_example': 'Example details',
      };

      final item = PreRequisiteItem.fromJson(json);

      expect(item.concept, 'Fall back Terminology');
      expect(item.explanation, 'Explanation text');
      expect(item.connection, 'Example details');
    });

    test('should handle missing values gracefully', () {
      final json = <String, dynamic>{};
      final item = PreRequisiteItem.fromJson(json);

      expect(item.concept, '');
      expect(item.explanation, '');
      expect(item.connection, '');
    });
  });

  group('Hierarchical JSON Flattening Parser', () {
    test('should flatten nested prerequisites in sub_topics list', () {
      final mockJson = {
        "title": "Grade 12 CBSE Mathematics - Chapter 3: Matrices - Prerequisite Knowledge",
        "sub_topics": [
          {
            "sub_topic": "3.1 Introduction",
            "prerequisites": [
              {
                "prerequisite_terminology_concept_process": "Rows and Columns",
                "explanation": "A row is a horizontal arrangement...",
                "formula_rule_example": "Example 1"
              }
            ]
          },
          {
            "sub_topic": "3.2 Matrix and Order",
            "prerequisites": [
              {
                "prerequisite_terminology_concept_process": "Subscript Notation",
                "explanation": "A subscript indicates...",
                "formula_rule_example": "Example 2"
              }
            ]
          }
        ]
      };

      final parsed = parseDecoded(mockJson, 'pre_requisite', ['preRequisite', 'prerequisites']);
      expect(parsed, isNotNull);
      expect(parsed!.length, 2);
      
      final firstItem = PreRequisiteItem.fromJson(Map<String, dynamic>.from(parsed[0]));
      expect(firstItem.concept, "Rows and Columns");
      expect(firstItem.connection, "Example 1");

      final secondItem = PreRequisiteItem.fromJson(Map<String, dynamic>.from(parsed[1]));
      expect(secondItem.concept, "Subscript Notation");
      expect(secondItem.connection, "Example 2");
    });
  });
}
