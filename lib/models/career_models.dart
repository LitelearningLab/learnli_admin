// Models for Career Exploration Feature
class Career {
  final String id;
  final String title;
  final String icon;
  final String subtitle;
  final String color;
  final List<CareerStep> steps;

  Career({
    required this.id,
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.color,
    required this.steps,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    final stepsRaw = json['steps'];
    final stepsList = stepsRaw is List ? stepsRaw : const [];

    return Career(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      steps: stepsList
          .whereType<Map>()
          .map((step) =>
              CareerStep.fromJson(Map<String, dynamic>.from(step as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'subtitle': subtitle,
      'color': color,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}

class CareerStep {
  final String id;
  final String title;
  final String icon;
  final String color;
  final String bgColor;
  final Map<String, dynamic> data;

  CareerStep({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.data,
  });

  factory CareerStep.fromJson(Map<String, dynamic> json) {
    return CareerStep(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      bgColor: (json['bgColor'] ?? '').toString(),
      data: _toStringDynamicMap(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'color': color,
      'bgColor': bgColor,
      'data': data,
    };
  }

  static Map<String, dynamic> _toStringDynamicMap(dynamic raw) {
    if (raw is! Map) return {};

    final result = <String, dynamic>{};
    raw.forEach((key, value) {
      result[key.toString()] = _normalize(value);
    });
    return result;
  }

  static dynamic _normalize(dynamic value) {
    if (value is Map) {
      final normalized = <String, dynamic>{};
      value.forEach((k, v) {
        normalized[k.toString()] = _normalize(v);
      });
      return normalized;
    }
    if (value is List) {
      return value.map(_normalize).toList();
    }
    return value;
  }
}
