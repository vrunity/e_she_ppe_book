import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeadProtectionPage extends StatefulWidget {
  @override
  _HeadProtectionPageState createState() => _HeadProtectionPageState();
}

class _HeadProtectionPageState extends State<HeadProtectionPage> {
  bool isCompleted = false;
  int quizScore = -1;
  bool hasTakenQuiz = false;
  Map<int, String> userAnswers = {};
  final String topicName = "HeadProtection";

  final Map<int, String> correctAnswers = {
    1: "To prevent head injuries from falling objects or bumps",
    2: "Hard hats",
    3: "To absorb shock and provide penetration resistance",
    4: "Should be worn at all times in hazard-prone areas",
    5: "Check for cracks, dents, or wear and replace if damaged",
  };

  final List<Map<String, dynamic>> quizQuestions = [
    {
      "question": "Why is head protection important?",
      "options": [
        "For stylish appearance",
        "To prevent head injuries from falling objects or bumps",
        "To protect hair from dust",
        "To avoid wearing caps"
      ]
    },
    {
      "question": "Which equipment is used for head protection?",
      "options": [
        "Goggles",
        "Ear plugs",
        "Hard hats",
        "Face mask"
      ]
    },
    {
      "question": "What is the purpose of the suspension system in a hard hat?",
      "options": [
        "To look attractive",
        "To store tools",
        "To absorb shock and provide penetration resistance",
        "To make it heavier"
      ]
    },
    {
      "question": "When should hard hats be worn?",
      "options": [
        "Only during inspections",
        "During lunchtime",
        "Should be worn at all times in hazard-prone areas",
        "Only in office cabins"
      ]
    },
    {
      "question": "How should hard hats be maintained?",
      "options": [
        "Paint them often",
        "Check for cracks, dents, or wear and replace if damaged",
        "Use as a seat",
        "Keep in sunlight"
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTopicStatus();
  }

  Future<void> _loadTopicStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCompleted = prefs.getBool('Completed_$topicName') ?? false;
      quizScore = prefs.getInt('QuizScore_$topicName') ?? -1;
      hasTakenQuiz = prefs.getBool('QuizTaken_$topicName') ?? false;
    });
  }

  Future<void> _saveTopicCompletion(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Completed_$topicName', value);
    setState(() {
      isCompleted = value;
    });
    if (value) {
      _showQuizDialog();
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Head Protection Quiz"),
              content: SingleChildScrollView(
                child: Column(
                  children: quizQuestions.map((question) {
                    int index = quizQuestions.indexOf(question) + 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question["question"],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...question["options"].map<Widget>((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: userAnswers[index],
                            onChanged: (String? value) {
                              setState(() {
                                userAnswers[index] = value!;
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
                      Navigator.of(context).pop();
                      _evaluateQuiz();
                    }
                  },
                )
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
          content: Text("You scored $score out of ${quizQuestions.length}.",),
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

  Widget _buildQuestionAnswer(String question, String answer) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Head Protection")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildQuestionAnswer("🪖 Why is head protection important?", "Head injuries are often serious and can be caused by falling objects or accidental bumps in industrial or construction areas."),
                  _buildQuestionAnswer("🪖 What type of PPE is used for the head?", "Hard hats or safety helmets are used to protect the head. They are designed with suspension systems to absorb shock."),
                  _buildQuestionAnswer("🪖 How should head protection be maintained?", "Regularly inspect for cracks or damage. Replace helmets if they are dented or after any major impact."),
                  _buildQuestionAnswer("🪖 Where should head protection be used?", "Construction sites, warehouses, and places where there is risk of falling objects or overhead hazards."),
                ],
              ),
            ),
            CheckboxListTile(
              title: Text("Mark as Completed"),
              value: isCompleted,
              onChanged: (value) => _saveTopicCompletion(value ?? false),
            ),
            if (hasTakenQuiz)
              Text("Last Quiz Score: $quizScore / ${quizQuestions.length}"),
            if (hasTakenQuiz)
              ElevatedButton(
                onPressed: _showQuizDialog,
                child: Text("Retest"),
              )
          ],
        ),
      ),
    );
  }
}
