import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HandlingExtinguishersPage extends StatefulWidget {
  @override
  _HandlingExtinguishersPageState createState() =>
      _HandlingExtinguishersPageState();
}

class _HandlingExtinguishersPageState extends State<HandlingExtinguishersPage> {
  bool istopic_6_Completed = false;
  int quizScore = -1;
  bool hasTakenQuiz = false;
  Map<int, String> userAnswers = {};
  final String topicName = "HandlingExtinguishers"; // Unique identifier for this topic

  final Map<int, String> correctAnswers = {
    1: "After each use, even if not fully emptied",
    2: "In an accessible location, mounted on a wall, and away from direct heat",
    3: "To check for pressure, leaks, or expired chemicals",
    4: "Replace or service it immediately",
    5: "All employees and household members",
  };

  final List<Map<String, dynamic>> quizQuestions = [
    {
      "question": "When should a fire extinguisher be refilled?",
      "options": [
        "Once a year",
        "Only when it is fully empty",
        "After each use, even if not fully emptied",
        "Only during maintenance checks"
      ]
    },
    {
      "question": "How should a fire extinguisher be stored?",
      "options": [
        "In an accessible location, mounted on a wall, and away from direct heat",
        "In a locked cabinet",
        "Near heating sources for quick access",
        "On the floor, away from people"
      ]
    },
    {
      "question": "Why should fire extinguishers be regularly inspected?",
      "options": [
        "To check for pressure, leaks, or expired chemicals",
        "Only to make sure it's in the right place",
        "Because it's a legal requirement",
        "No need for regular inspections"
      ]
    },
    {
      "question": "What should be done if an extinguisher is damaged?",
      "options": [
        "Replace or service it immediately",
        "Ignore the damage if it still works",
        "Use it until it is empty",
        "Store it safely and not use it"
      ]
    },
    {
      "question": "Who should be trained to use a fire extinguisher?",
      "options": [
        "Only firefighters",
        "Only trained professionals",
        "All employees and household members",
        "Only emergency responders"
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadTopicCompletionStatus();
  }

  Future<void> _loadTopicCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      istopic_6_Completed = prefs.getBool('Completed_$topicName') ?? false;
      quizScore = prefs.getInt('QuizScore_$topicName') ?? -1;
      hasTakenQuiz = prefs.getBool('QuizTaken_$topicName') ?? false;
    });
  }

  Future<void> _saveTopicCompletionStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Completed_$topicName', value);
    setState(() {
      istopic_6_Completed = value;
    });

    if (value) {
      Future.delayed(Duration(milliseconds: 300), () {
        _showQuizDialog();
      });
    }
  }

  Future<void> _saveQuizScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('QuizScore_$topicName', score);
    await prefs.setBool('QuizTaken_$topicName', true);
    setState(() {
      quizScore = score;
      hasTakenQuiz = true;
    });
  }

  void _showQuizDialog() {
    userAnswers.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Handling Fire Extinguishers Quiz"),
              content: SingleChildScrollView(
                child: Column(
                  children: quizQuestions.map((question) {
                    int questionIndex = quizQuestions.indexOf(question) + 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question["question"],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ...question["options"].map<Widget>((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: userAnswers[questionIndex],
                            onChanged: (String? value) {
                              setState(() {
                                userAnswers[questionIndex] = value!;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Submit"),
                  onPressed: () {
                    if (userAnswers.length < quizQuestions.length) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please answer all questions")),
                      );
                    } else {
                      Navigator.pop(dialogContext);
                      _evaluateQuiz();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _evaluateQuiz() {
    int score = 0;
    userAnswers.forEach((key, value) {
      if (correctAnswers[key] == value) {
        score++;
      }
    });
    _saveQuizScore(score);
    _showQuizResult(score);
  }

  void _showQuizResult(int score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Quiz Result"),
          content: Text("You scored $score out of ${quizQuestions.length}."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Retest"),
              onPressed: () {
                Navigator.pop(context);
                _showQuizDialog();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Handling Fire Extinguishers")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildQuestionAnswer("🔥 When should a fire extinguisher be refilled?", "After each use, even if not fully emptied."),
                  _buildQuestionAnswer("🔥 How should a fire extinguisher be stored?", "In an accessible location, mounted on a wall, and away from direct heat."),
                  _buildQuestionAnswer("🔥 Why should fire extinguishers be regularly inspected?", "To check for pressure, leaks, or expired chemicals."),
                  _buildQuestionAnswer("🔥 What should be done if an extinguisher is damaged?", "Replace or service it immediately."),
                  _buildQuestionAnswer("🔥 Who should be trained to use a fire extinguisher?", "All employees and household members."),
                ],
              ),
            ),
            CheckboxListTile(
              title: Text("Mark as Completed"),
              value: istopic_6_Completed,
              onChanged: (value) {
                _saveTopicCompletionStatus(value ?? false);
              },
            ),
            if (hasTakenQuiz)
              Text("Last Quiz Score: $quizScore / ${quizQuestions.length}"),
            if (hasTakenQuiz)
              ElevatedButton(
                onPressed: _showQuizDialog,
                child: Text("Retest"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(answer, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
