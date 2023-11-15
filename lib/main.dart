

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String id;
  String title;
  bool isDone;
  DateTime? dateTime;
  String description;

  Task({required this.id, required this.title, this.isDone = false, this.dateTime, this.description = ''});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> tasks = [];
  late SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _speech.initialize(onStatus: (status) {
      if (status == SpeechToText.notifyErrorMethod) {
        print('Error de inicialización');
      }
    }, onError: (error) => print('Error: $error'));

    // Cargar tareas desde Firestore
    loadTasks();
  }

  Future<void> loadTasks() async {
    final tasksSnapshot = await FirebaseFirestore.instance.collection('tasks').get();
    setState(() {
      tasks = tasksSnapshot.docs
          .map((doc) => Task(
                id: doc.id,
                title: doc['title'],
                isDone: doc['isDone'],
                dateTime: (doc['dateTime'] as Timestamp?)?.toDate(),
                description: doc['description'],
              ))
          .toList();
    });
  }

  Future<void> addTask(String newTaskTitle) async {
    // Añadir tarea a Firestore
    await FirebaseFirestore.instance.collection('tasks').add({
      'title': newTaskTitle,
      'isDone': false,
      'dateTime': null,
      'description': '',
    });

    // Recargar tareas desde Firestore
    loadTasks();
  }

  Future<void> toggleTask(String taskId, bool isDone) async {
    // Actualizar estado de la tarea en Firestore
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'isDone': isDone});

    // Recargar tareas desde Firestore
    loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    // Eliminar tarea de Firestore
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

    // Recargar tareas desde Firestore
    loadTasks();
  }

  Future<void> editTaskDetails(String taskId, String title, DateTime? dateTime, String description) async {
    // Actualizar detalles de la tarea en Firestore
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'title': title,
      'dateTime': dateTime,
      'description': description,
    });

    // Recargar tareas desde Firestore
    loadTasks();
  }

  void viewTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(
          task: task,
          onEditDetails: (String title, DateTime? dateTime, String description) {
            editTaskDetails(task.id, title, dateTime, description);
          },
        ),
      ),
    );
  }

  void startListening() {
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          addTask(result.recognizedWords);
        }
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TaskInput(onAddTask: addTask),
          TaskList(
            tasks: tasks,
            onToggle: toggleTask,
            onDelete: deleteTask,
            onViewDetails: viewTaskDetails,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? stopListening : startListening,
        tooltip: 'Agregar tarea por voz',
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String, bool) onToggle;
  final Function(String) onDelete;
  final Function(Task) onViewDetails;

  TaskList({required this.tasks, required this.onToggle, required this.onDelete, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(
            title: task.title,
            isDone: task.isDone,
            onToggle: (isDone) {
              onToggle(task.id, isDone);
            },
            onDelete: () {
              onDelete(task.id);
            },
            onViewDetails: () {
              onViewDetails(task);
            },
          );
        },
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final Function(bool) onToggle;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  TaskTile({required this.title, required this.isDone, required this.onToggle, required this.onDelete, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: onViewDetails,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onViewDetails,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
          Checkbox(
            value: isDone,
            onChanged: (newValue) {
              onToggle(newValue ?? false);
            },
          ),
        ],
      ),
    );
  }
}

class TaskInput extends StatelessWidget {
  final Function(String) onAddTask;

  TaskInput({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    String newTaskTitle = '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onChanged: (value) {
                newTaskTitle = value;
              },
              decoration: InputDecoration(
                hintText: 'Ingrese una nueva tarea',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onAddTask(newTaskTitle);
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final Function(String, DateTime?, String) onEditDetails;

  TaskDetailsScreen({required this.task, required this.onEditDetails});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _dateTimeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _dateTimeController = TextEditingController(text: widget.task.dateTime?.toLocal().toString() ?? '');
    _descriptionController = TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tarea'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });

              if (!_isEditing) {
                widget.onEditDetails(
                  widget.task.title,
                  widget.task.dateTime,
                  _descriptionController.text,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarea: ${widget.task.title}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateTimeController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDateTime = await showDatePicker(
                          context: context,
                          initialDate: widget.task.dateTime ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDateTime != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            pickedDateTime = DateTime(
                              pickedDateTime.year,
                              pickedDateTime.month,
                              pickedDateTime.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            setState(() {
                              widget.task.dateTime = pickedDateTime;
                              _dateTimeController.text = pickedDateTime!.toLocal().toString();
                            });
                          }
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Fecha y Hora',
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Fecha y Hora: ${widget.task.dateTime?.toLocal().toString() ?? 'No seleccionada'}',
              ),
            SizedBox(height: 10),
            if (_isEditing)
              TextField(
                controller: _descriptionController,
                onChanged: (value) {
                  widget.task.description = value;
                },
                decoration: InputDecoration(
                  hintText: 'Descripción',
                ),
              )
            else
              Text(
                'Descripción: ${widget.task.description}',
              ),
            SizedBox(height: 10),
            Text(
              'Estado: ${widget.task.isDone ? 'Completada' : 'Pendiente'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
