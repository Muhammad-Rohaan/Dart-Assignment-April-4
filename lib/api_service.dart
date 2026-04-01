import 'dart:convert';
import 'package:assignment4/todo_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://apimocker.com/todos';

  // GET with Pagination
  // Note: limit is 10 as per requirements
  Future<List<Todo>> fetchTodos(int page, int limit) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Todo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST new Todo
  Future<Todo> addTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add todo');
    }
  }

  // PUT/PATCH to update status
  Future<void> updateTodoStatus(Todo todo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${todo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update todo');
    }
  }
}