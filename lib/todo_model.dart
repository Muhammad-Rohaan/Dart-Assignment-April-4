class Todo {
  final String? id;
  final String title;
  final String description;
  final bool isDone;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  // Manual Serialization: From JSON Map to Object
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isDone: json['isDone'] == true || json['isDone'] == 1,
    );
  }

  // Manual Serialization: From Object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
    };
  }

  // Helper to copy object with new values (useful for toggling isDone)
  Todo copyWith({bool? isDone}) {
    return Todo(
      id: id,
      title: title,
      description: description,
      isDone: isDone ?? this.isDone,
    );
  }
}