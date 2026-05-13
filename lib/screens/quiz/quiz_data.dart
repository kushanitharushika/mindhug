import '../../models/quiz_question.dart';

final List<QuizQuestion> quizQuestions = [
  // --- ORIGINAL QUESTIONS (1-32) ---
  QuizQuestion(
    question: "How do you feel most of the time these days?",
    options: ["Happy", "Neutral", "Sad", "Anxious or stressed"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel overwhelmed by your studies or responsibilities?",
    options: ["Rarely", "Sometimes", "Often", "Almost always"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel motivated to do your daily tasks?",
    options: ["Almost everyday", "Sometimes", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),
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
    options: ["Take a break and relax", "Talk to someone", "Ignore it and continue", "Feel stuck and panicked"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How comfortable are you sharing your feelings with others?",
    options: ["Very comfortable", "Somewhat comfortable", "Not really comfortable", "I prefer to keep it to myself"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel supported by those around you?",
    options: ["Always", "Sometimes", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you engage in activities that help you relax?",
    options: ["Daily", "A few times a week", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How healthy would you say your current lifestyle is (sleep, diet, rest)?",
    options: ["Very healthy", "Somewhat healthy", "Not very healthy", "Unhealthy"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel confident about yourself?",
    options: ["Almost always", "Sometimes", "Rarely", "Never"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel lonely even when you're with others?",
    options: ["Never", "Rarely", "Sometimes", "Often"],
    scores: [4, 3, 2, 1],
  ),
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
  QuizQuestion(
    question: "Do you feel pressured to figure out your future career or academic path?",
    options: ["Not at all", "A little bit", "Quite a lot", "It constantly worries me"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How much does financial stress or student debt affect your peace of mind?",
    options: ["Rarely affects me", "Sometimes", "Often", "It's a major distraction"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you compare your achievements or lifestyle to peers on social media?",
    options: ["Rarely", "Sometimes", "Often", "Almost every day"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel pressure to fit in or meet expectations set by friend groups or classmates?",
    options: ["Never", "Occasionally", "Frequently", "All the time"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How well do you balance your academics/work with personal downtime?",
    options: ["Very well", "Reasonably well", "Struggling", "I have no personal time"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel guilty when you take time off to rest instead of studying or working?",
    options: ["Rarely", "Sometimes", "Often", "Always"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How overwhelming is managing day-to-day responsibilities alongside your studies?",
    options: ["Not overwhelming", "Manageable", "Somewhat overwhelming", "Very overwhelming"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How easily can you ask professors, teachers, or mentors for help when you are struggling?",
    options: ["Very easily", "Somewhat easily", "It is difficult", "I never ask for help"],
    scores: [4, 3, 2, 1],
  ),

  // --- NEW ADDITIONS (33-50) ---
  // Cognitive / Imposter Syndrome
  QuizQuestion(
    question: "How often do you feel like you are 'faking' your knowledge or skills?",
    options: ["Never", "Rarely", "Often", "Almost every day"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "When you succeed, do you feel it was mostly due to luck rather than your hard work?",
    options: ["Not at all", "Sometimes", "Often", "Always"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you feel 'paralyzed' by the fear of making a mistake in your work?",
    options: ["Rarely", "Sometimes", "Frequently", "Always"],
    scores: [4, 3, 2, 1],
  ),

  // Digital Wellness
  QuizQuestion(
    question: "How often do you use your phone as a way to escape from academic stress?",
    options: ["Rarely", "Occasionally", "Frequently", "Almost constantly"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel anxious or 'FOMO' (Fear Of Missing Out) if you stay offline for a day?",
    options: ["Not at all", "A little bit", "Quite a lot", "It’s very distressing"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How often do you lose sleep because you are scrolling on your phone or computer?",
    options: ["Never", "Rarely", "Sometimes", "Almost every night"],
    scores: [4, 3, 2, 1],
  ),

  // Social & Environment
  QuizQuestion(
    question: "Do you feel like you have to put on a 'mask' to fit in with your classmates?",
    options: ["Never", "Rarely", "Often", "All the time"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How much time do you spend in nature or outdoors each week?",
    options: ["Plenty of time", "A moderate amount", "Very little", "None at all"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel that your parents/family have realistic expectations of you?",
    options: ["Yes, very realistic", "Mostly", "They are a bit high", "They are crushing me"],
    scores: [4, 3, 2, 1],
  ),

  // Burnout & Purpose
  QuizQuestion(
    question: "How often do you find yourself questioning if your degree/career path is worth it?",
    options: ["Rarely", "Occasionally", "Frequently", "All the time"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How much energy do you have for social interactions after a day of classes/study?",
    options: ["Plenty", "A decent amount", "Very little", "I’m completely drained"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel that your current routine allows you to grow as a person, not just a student?",
    options: ["Definitely", "Somewhat", "Not really", "Not at all"],
    scores: [4, 3, 2, 1],
  ),

  // Focus & Productivity
  QuizQuestion(
    question: "How often do you procrastinate until the very last minute?",
    options: ["Never", "Rarely", "Often", "Every single time"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "When you try to study, how easily are you distracted by notifications or people?",
    options: ["I stay focused", "Slightly distracted", "Easily distracted", "I can't focus at all"],
    scores: [4, 3, 2, 1],
  ),

  // Physical/Emotional Connection
  QuizQuestion(
    question: "How often do you experience a racing heart or 'butterflies' due to anxiety?",
    options: ["Rarely", "Sometimes", "Often", "Almost every day"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Do you feel like you are living life on 'autopilot' recently?",
    options: ["Not at all", "Occasionally", "Often", "Completely"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "How kind are you to yourself when you fail a test or miss a deadline?",
    options: ["Very kind/forgiving", "A bit hard on myself", "Very critical", "I hate myself for it"],
    scores: [4, 3, 2, 1],
  ),
  QuizQuestion(
    question: "Overall, how hopeful do you feel about the next 6 months of your life?",
    options: ["Very hopeful", "Somewhat hopeful", "Indifferent/Unsure", "Not hopeful at all"],
    scores: [4, 3, 2, 1],
  ),
];