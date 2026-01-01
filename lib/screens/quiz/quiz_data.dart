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
  // Physical symptoms
  QuizQuestion(
    question: "How is your sleep quality recently?",
    options: ["Restful and consistent", "Okay, but could be better", "Poor or irregular", "I struggle to sleep"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you experience physical tension (headaches, tight shoulders) due to stress?",
    options: ["Rarely", "Occasionally", "Frequently", "Almost constantly"],
    scores: [4, 3, 2, 1],
  ),

  // Negative Thoughts (CBT)
  QuizQuestion(
    question: "When things go wrong, do you tend to blame yourself?",
    options: ["Rarely", "Sometimes", "Often", "Always"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you find yourself worrying about the future?",
    options: ["Rarely", "Occasionally", "Frequently", "Constantly"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you find it hard to stop negative thoughts once they start?",
    options: ["No, I can distract myself", "Sometimes", "Often", "Yes, it's very difficult"],
    scores: [4, 3, 2, 1],
  ),

  // Motivation & Focus
  QuizQuestion(
    question: "How easy is it for you to focus on a task right now?",
    options: ["Very easy", "Somewhat easy", "Hard", "Very hard"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you look forward to the day when you wake up?",
    options: ["Usually", "Sometimes", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),

  // Detailed Emotional State
  QuizQuestion(
    question: "Have you lost interest in hobbies or activities you used to enjoy?",
    options: ["No, I still enjoy them", "A little bit", "Significantly", "Yes, completely"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel irritable or easily annoyed?",
    options: ["Rarely", "Sometimes", "Often", "Very often"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel like you are 'running on empty'?",
    options: ["Rarely", "Sometimes", "Often", "All the time"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How do you handle unexpected changes?",
    options: ["I adapt easily", "I manage", "I get stressed", "I feel overwhelmed"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel like you have someone to turn to when things get tough?",
    options: ["Yes, definitely", "Probably", "Not really", "No one"],
    scores: [4, 3, 2, 1],
  ),
];
