import '../../models/quiz_question.dart';

final List<QuizQuestion> quizQuestions = [
  //emotional and mental state questions
  QuizQuestion(
    question: "How do you feel most of the time these days?",
    options: ["Happy", "Neutral", "Sad", "Anxious or stressed"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question:
        "How often do you feel overwhelmed by your studies or responsibilities?",
    options: ["Rarely", "Sometimes", "Often", "Almost always"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel motivated to do your daily tasks?",
    options: ["Almost everyday", "Sometimes", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),

  //Academic stress and time management questions
  QuizQuestion(
    question: "Do you often worry about grades or assignments?",
    options: ["Not at all", "A little", "Quite often", "All the time"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How do you rate your ability to manage time and meet deadlines?",
    options: ["Excellent", "Good", "Fair", "Poor"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "When facing academic pressure, what do you usually do?",
    options: [
      "Take a break and relax",
      "Talk to someone",
      "Ignore it and continue",
      "Feel stuck and panicked",
    ],
    scores: [4, 3, 2, 1],
  ),

  //Social relationships and support system questions
  QuizQuestion(
    question: "How comfortable are you sharing your feelings with others?",
    options: [
      "Very comfortable",
      "Somewhat comfortable",
      "Not really comfortable",
      "I prefer to keep it to myself",
    ],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel supported by those around you?",
    options: ["Always", "Sometimes", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),

  //Lifestyle and coping habits questions
  QuizQuestion(
    question: "How often do you engage in activities that help you relax?",
    options: ["Daily", "A few times a week", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question:
        "How healthy would you say your current lifestyle is (sleep, diet, rest)?",
    options: [
      "Very healthy",
      "Somewhat healthy",
      "Not very healthy",
      "Unhealthy",
    ],
    scores: [4, 3, 2, 1],
  ),

  //Self-perception and Emotions questions
  QuizQuestion(
    question: "How often do you feel confident about yourself?",
    options: ["Almost", "Sometimes", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel lonely even when you're with others?",
    options: ["Never", "Rarely", "Sometimes", "Often"],
    scores: [4, 3, 2, 1],
  ),
];
