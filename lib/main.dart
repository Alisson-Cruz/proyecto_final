// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// void main() {
//   runApp(MyApp());
// }

// class Task {
//   String title;
//   bool isDone;

//   Task({required this.title, this.isDone = false});
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: TaskScreen(),
//     );
//   }
// }

// class TaskScreen extends StatefulWidget {
//   @override
//   _TaskScreenState createState() => _TaskScreenState();
// }

// class _TaskScreenState extends State<TaskScreen> {
//   List<Task> tasks = [];
//   late SpeechToText _speech;
//   bool _isListening = false;
//   TextEditingController _textEditingController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _speech = SpeechToText();
//     _speech.initialize(onStatus: (status) {
//       // if (status == stt.SpeechToTextStatus.error) {
//       //   print('Error de inicialización');
//       if (status == SpeechToTextStatus.error) {
//   print('Error de inicialización');
// }

      
//     }, onError: (error) => print('Error: $error'));
//   }

//   void addTask(String newTaskTitle) {
//     setState(() {
//       tasks.add(Task(title: newTaskTitle));
//     });
//   }

//   void toggleTask(int index) {
//     setState(() {
//       tasks[index].isDone = !tasks[index].isDone;
//     });
//   }

//   void startListening() {
//     _speech.listen(
//       onResult: (result) {
//         if (result.finalResult) {
//           setState(() {
//             _textEditingController.text = result.recognizedWords;
//           });
//         }
//       },
//     );
//     setState(() {
//       _isListening = true;
//     });
//   }

//   void stopListening() {
//     _speech.stop();
//     setState(() {
//       _isListening = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tareas'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Expanded(
//             child: TaskList(tasks: tasks, onToggle: toggleTask),
//           ),
//           TaskInput(
//             onAddTask: addTask,
//             textEditingController: _textEditingController,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isListening ? stopListening : startListening,
//         tooltip: 'Agregar tarea por voz',
//         child: Icon(_isListening ? Icons.stop : Icons.mic),
//       ),
//     );
//   }
// }

// class TaskList extends StatelessWidget {
//   final List<Task> tasks;
//   final Function(int) onToggle;

//   TaskList({required this.tasks, required this.onToggle});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: tasks.length,
//       itemBuilder: (context, index) {
//         final task = tasks[index];
//         return TaskTile(
//           title: task.title,
//           isDone: task.isDone,
//           onToggle: () {
//             onToggle(index);
//           },
//         );
//       },
//     );
//   }
// }

// class TaskTile extends StatelessWidget {
//   final String title;
//   final bool isDone;
//   final VoidCallback onToggle;

//   TaskTile({required this.title, required this.isDone, required this.onToggle});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(
//         title,
//         style: TextStyle(
//           decoration: isDone ? TextDecoration.lineThrough : null,
//         ),
//       ),
//       trailing: Checkbox(
//         value: isDone,
//         onChanged: (newValue) {
//           onToggle();
//         },
//       ),
//     );
//   }
// }

// class TaskInput extends StatelessWidget {
//   final Function(String) onAddTask;
//   final TextEditingController textEditingController;

//   TaskInput({
//     required this.onAddTask,
//     required this.textEditingController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: <Widget>[
//           Expanded(
//             child: TextField(
//               controller: textEditingController,
//               decoration: InputDecoration(
//                 hintText: 'Ingrese una nueva tarea',
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               onAddTask(textEditingController.text);
//               textEditingController.clear();
//             },
//             child: Text('Agregar'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
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
      // Puedes usar SpeechToTextStatus directamente aquí
      if (status == SpeechToText.notifyErrorMethod) {
        print('Error de inicialización');
        //SpeechToTextStatus.error
      }
    }, onError: (error) => print('Error: $error'));
  }

  void addTask(String newTaskTitle) {
    setState(() {
      tasks.add(Task(title: newTaskTitle));
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  void startListening() {
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            addTask(result.recognizedWords);
          });
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
          Expanded(
            child: TaskList(tasks: tasks, onToggle: toggleTask),
          ),
          TaskInput(onAddTask: addTask),
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
  final Function(int) onToggle;

  TaskList({required this.tasks, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          title: task.title,
          isDone: task.isDone,
          onToggle: () {
            onToggle(index);
          },
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onToggle;

  TaskTile({required this.title, required this.isDone, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Checkbox(
        value: isDone,
        onChanged: (newValue) {
          onToggle();
        },
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
