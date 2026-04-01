import 'package:assignment4/api_service.dart';
import 'package:assignment4/todo_model.dart';
import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const TodoListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  
  List<Todo> _todos = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });
    try {
      final items = await _apiService.fetchTodos(_currentPage, 10);
      setState(() {
        _todos = items;
        _isLoading = false;
        if (items.length < 10) _hasMore = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _fetchMoreData() async {
    setState(() => _isLoading = true);
    try {
      _currentPage++;
      final items = await _apiService.fetchTodos(_currentPage, 10);
      setState(() {
        _todos.addAll(items);
        _isLoading = false;
        if (items.length < 10) _hasMore = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isLoading = false);
  }

  // Add Todo Dialog
  void _showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Todo'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _addNewTodo(titleController.text, descController.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewTodo(String title, String desc) async {
    setState(() => _isPosting = true);
    try {
      final newTodo = Todo(title: title, description: desc);
      // final savedTodo = await _apiService.addTodo(newTodo);
      setState(() {
        _todos.insert(0, newTodo); // Add to top
        _isPosting = false;
      });
    } catch (e) {
      print(e);
      _showError('Could not save todo');
      setState(() => _isPosting = false);
    }
  }

  Future<void> _toggleTodo(int index) async {
    final updatedTodo = _todos[index].copyWith(isDone: !_todos[index].isDone);
    try {
      // await _apiService.updateTodoStatus(updatedTodo);
      setState(() {
        _todos[index] = updatedTodo;
      });
    } catch (e) {
      _showError('Update failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        bottom: _isPosting ? const PreferredSize(
          preferredSize: Size.fromHeight(4), 
          child: LinearProgressIndicator()
        ) : null,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInitialData,
        child: _todos.isEmpty && _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _todos.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _todos.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final todo = _todos[index];
                return ListTile(
                  title: Text(todo.title, style: TextStyle(
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  )),
                  subtitle: Text(todo.description),
                  trailing: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) => _toggleTodo(index),
                  ),
                );
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}