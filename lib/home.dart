import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart';

class Home extends StatefulWidget {
  final String email;

  const Home({
    super.key,
    required this.email,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Color primaryColor = const Color(0xFF8E24AA);

  List<Map<String, dynamic>> todos = [];
  late Map userData;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('authBox');
    userData = box.get(widget.email) ?? {};

    todos = List<Map<String, dynamic>>.from(
      (userData['todos'] ?? []).map(
        (e) => Map<String, dynamic>.from(e),
      ),
    );
  }

  void _saveTodos() {
    final box = Hive.box('authBox');
    userData['todos'] = todos;
    box.put(widget.email, userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Todo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTaskPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    todos.add(Map<String, dynamic>.from(result));
                  });
                  _saveTodos();
                }
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              accountName: Text(
                "${userData['firstName']} ${userData['lastName']}",
              ),
              accountEmail: Text(widget.email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.purple),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: Text("DOB: ${userData['dob']}"),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text("Contact: ${userData['contact']}"),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text("Address: ${userData['address']}"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text(
                "No tasks added",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final updatedTask = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailPage(
                                  title: todos[index]["title"]!,
                                  desc: todos[index]["desc"]!,
                                ),
                              ),
                            );

                            if (updatedTask != null) {
                              setState(() {
                                todos[index] = updatedTask;
                              });
                              _saveTodos();
                            }
                          },
                          child: Text(
                            todos[index]["title"]!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            todos.removeAt(index);
                          });
                          _saveTodos();
                        },
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E24AA),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Task",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: () {
                if (titleController.text.isEmpty ||
                    descController.text.isEmpty) {
                  return;
                }

                Navigator.pop(context, {
                  "title": titleController.text,
                  "desc": descController.text,
                });
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: descController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskDetailPage extends StatefulWidget {
  final String title;
  final String desc;

  const TaskDetailPage({
    super.key,
    required this.title,
    required this.desc,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController titleController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    descController = TextEditingController(text: widget.desc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E24AA),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Task",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: () {
                Navigator.pop(context, {
                  "title": titleController.text,
                  "desc": descController.text,
                });
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: descController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
