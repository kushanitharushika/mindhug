import '../models/exercise.dart';

final List<Exercise> mockExercises = [
  Exercise(
    id: '1', 
    title: 'Deep Breathing', 
    description: 'Slow, deep breaths to calm down.', 
    duration: '3 mins', 
    type: ExerciseType.breathing, 
    minScore: 0, 
    maxScore: 100,
    benefits: "Deep breathing activates your parasympathetic nervous system, effectively acting as a 'brake' for stress. It lowers cortisol levels, reduces blood pressure, and sends a signal to your brain that you are safe.",
    steps: [
      "Find a comfortable sitting position with your back straight.",
      "Place one hand on your chest and the other on your belly.",
      "Inhale deeply through your nose for 4 seconds, feeling your belly expand.",
      "Hold your breath gently for 2 seconds.",
      "Exhale slowly through your mouth for 6 seconds, like you're blowing out a candle.",
      "Repeat this cycle, focusing only on the rhythm of your breath."
    ]
  ),
  Exercise(
    id: '2', 
    title: 'Box Breathing', 
    description: 'Inhale 4s, hold 4s, exhale 4s, hold 4s.', 
    duration: '4 mins', 
    type: ExerciseType.breathing, 
    minScore: 0, 
    maxScore: 100,
    benefits: "Used by Navy SEALs, this technique heightens performance and concentration while being a powerful stress reliever. It regulates your autonomic nervous system and brings your mind to the present moment.",
    steps: [
      "Inhale through your nose for a count of 4.",
      "Hold that breath inside for a count of 4.",
      "Exhale smoothly through your mouth for a count of 4.",
      "Hold your lungs empty for a count of 4.",
      "Imagine tracing the sides of a square with each step.",
      "Continue for 4 minutes to reset your mind."
    ]
  ),
  Exercise(
    id: '3', 
    title: 'Body Scan', 
    description: 'Focus on each part of your body.', 
    duration: '10 mins', 
    type: ExerciseType.meditation, 
    minScore: 20, 
    maxScore: 80,
    benefits: "Reconnects your mind with your physical self, helping you identify where you hold tension. This practice reduces physical symptoms of stress and promotes a deep sense of relaxation.",
    steps: [
      "Lie down or sit comfortably and close your eyes.",
      "Take a few deep breaths to center yourself.",
      "Bring your attention to your toes. Notice any sensation there.",
      "Slowly move your focus up to your ankles, calves, and knees.",
      "Continue moving up through your thighs, hips, and stomach.",
      "Notice any tension and imagine releasing it with each exhale.",
      "Finish by focusing on your face, relaxing your jaw and forehead."
    ]
  ),
  Exercise(
    id: '4', 
    title: 'Quick Stretch', 
    description: 'Release tension in neck and shoulders.', 
    duration: '5 mins', 
    type: ExerciseType.physical, 
    minScore: 0, 
    maxScore: 100,
    benefits: "Physical tension often accumulates in the neck and shoulders during stress. Gentle stretching releases this stored energy, improves circulation to the brain, and provides an immediate mood boost.",
    steps: [
      "Sit or stand tall with your shoulders relaxed.",
      "Gently tilt your right ear toward your right shoulder. Hold for 15s.",
      "Return to center and repeat on the left side.",
      "Slowly roll your shoulders backward 5 times.",
      "Roll your shoulders forward 5 times.",
      "Clasp your hands behind your back and gently lift to open your chest.",
      "Shake out your hands and arms to release any lingering tension."
    ]
  ),
  Exercise(
    id: '5', 
    title: 'Jumping Jacks', 
    description: 'Get your heart rate up.', 
    duration: '2 mins', 
    type: ExerciseType.physical, 
    minScore: 50, 
    maxScore: 100,
    benefits: "A quick burst of cardio releases endorphins, the body's natural 'feel-good' chemicals. It breaks the cycle of lethargy and instantly boosts your energy and mental clarity.",
    steps: [
      "Stand upright with your legs together and arms at your sides.",
      "Bend your knees slightly and jump into the air.",
      "Spread your legs shoulder-width apart and stretch your arms out and over your head.",
      "Jump back to the starting position.",
      "Find a steady rhythm and keep going!",
      "Smile while you do it – it actually helps!"
    ]
  ),
  Exercise(
    id: '6', 
    title: 'Grounding 5-4-3-2-1', 
    description: 'Engage your five senses.', 
    duration: '5 mins', 
    type: ExerciseType.grounding, 
    minScore: 0, 
    maxScore: 50,
    benefits: "This is a classic anxiety-reduction technique. By engaging your five senses, you pull your brain out of spiraling thoughts and anchor yourself firmly in the present reality.",
    steps: [
      "Look around and name 5 things you can see.",
      "Notice 4 things you can physically feel (feet on floor, clothes on skin).",
      "Listen for 3 distinct sounds tailored to your environment.",
      "Identify 2 things you can smell (or recall 2 favorite scents).",
      "Name 1 thing you can taste (or a taste you like)."
    ]
  ),
  Exercise(
    id: '7', 
    title: 'Gratitude Journaling', 
    description: 'Write down 3 things you are grateful for.', 
    duration: '5 mins', 
    type: ExerciseType.other, 
    minScore: 30, 
    maxScore: 100,
    benefits: "Shift your focus from what's missing to what's present. Practicing gratitude is scientifically proven to improve sleep, mood, and immunity by rewiring your brain to scan for the positive.",
    steps: [
      "Grab a pen and paper or open a notes app.",
      "Take a moment to reflect on your day or week.",
      "Write down 3 things that made you smile or feel safe.",
      "They can be small: a warm coffee, a kind text, or the sunshine.",
      "Briefly write *why* you are grateful for each one.",
      "Read them back to yourself and feel the appreciation."
    ]
  ),
  Exercise(
    id: '8',
    title: 'Gentle Yoga',
    description: 'Slow movements to release body tension.',
    duration: '10 mins',
    type: ExerciseType.physical,
    minScore: 0,
    maxScore: 80,
    benefits: "Combines physical movement with breath awareness to lower cortisol levels. It releases stored physical tension, improves flexibility, and calms the nervous system.",
    steps: [
      "Start in Child's Pose: Kneel, sit back on heels, stretch arms forward.",
      "Move to Cat-Cow: On hands and knees, arch back (Cow) then round spine (Cat).",
      "Transition to Downward Dog: Lift hips high, pedal out your feet.",
      "Step forward into a gentle Forward Fold, letting your head hang heavy.",
      "Slowly roll up to standing and reach arms overhead.",
      "Finish with 1 minute of Savasana (corpse pose) lying flat on your back."
    ]
  ),
  Exercise(
    id: '9',
    title: 'Walking',
    description: 'A brisk walk to clear your mind.',
    duration: '15 mins',
    type: ExerciseType.physical,
    minScore: 0,
    maxScore: 100,
    benefits: "Walking, especially in nature, reduces rumination (repetitive negative thoughts). The rhythmic movement and optical flow processing help quiet the brain's detailed-oriented centers.",
    steps: [
      "Put on comfortable shoes.",
      "Step outside or find a clear path indoors.",
      "Start at a comfortable pace, noticing the sensation of your feet hitting the ground.",
      "Focus your eyes on the horizon or trees, rather than looking down.",
      "If thoughts intrude, gently bring your focus back to your footsteps.",
      "Pick up the pace slightly for the last 5 minutes to boost endorphins."
    ]
  ),
  Exercise(
    id: '10',
    title: '4-7-8 Breathing',
    description: 'Inhale 4s, hold 7s, exhale 8s.',
    duration: '5 mins',
    type: ExerciseType.breathing,
    minScore: 0,
    maxScore: 100,
    benefits: "A natural tranquilizer for the nervous system. The long exhale activates the vagus nerve, signaling your body to rest and digest, making it perfect for anxiety or sleep.",
    steps: [
      "Exhale completely through your mouth.",
      "Close your mouth and inhale quietly through your nose to a count of 4.",
      "Hold your breath for a count of 7.",
      "Exhale completely through your mouth, making a whoosh sound to a count of 8.",
      "This is one breath. Repeat the cycle 3 more times.",
      "Let your breath return to natural rhythm."
    ]
  ),
  Exercise(
    id: '11',
    title: 'Progressive Muscle Relaxation',
    description: 'Tense and relax muscle groups.',
    duration: '10 mins',
    type: ExerciseType.grounding,
    minScore: 0,
    maxScore: 60,
    benefits: "Teaches you to recognize the difference between tension and relaxation. By systematically tensing and releasing muscles, you can physically force your body into a state of calm.",
    steps: [
      "Lie down comfortably.",
      "Start with your feet: curl your toes tight for 5s, then release instantly.",
      "Move to calves: flex them hard for 5s, then let go.",
      "Continue up to your thighs, buttocks, and stomach.",
      "Clench your hands into fists, shrug shoulders to ears, then drop them.",
      "Scrunch your face tight, then relax your jaw and eyes.",
      "Feel the wave of heaviness and relaxation wash over you."
    ]
  ),
  Exercise(
    id: '12',
    title: 'Pilates Core Focus',
    description: 'Strengthen core and improve posture.',
    duration: '15 mins',
    type: ExerciseType.physical,
    minScore: 0,
    maxScore: 100,
    benefits: "Pilates builds a strong foundation for movement. It improves core stability, aligns the spine, and connects deep abdominal muscles, which boosts overall confidence and physical resilience.",
    steps: [
      "Lie on your back, knees bent, feet flat on the floor.",
      "Engage your core by drawing your belly button to your spine.",
      "Lift knees to tabletop position (90 degrees).",
      "Perform 'The Hundred': Pump arms by sides while breathing rhythmically.",
      "Extend legs to 45 degrees if comfortable.",
      "Transition to 'Single Leg Stretch', alternating hugging knees.",
      "Finish with a gentle spine stretch forward."
    ]
  ),
  Exercise(
    id: '13',
    title: 'Free Dance Flow',
    description: 'Move your body to the rhythm.',
    duration: '5 mins',
    type: ExerciseType.physical,
    minScore: 50,
    maxScore: 100,
    benefits: "Dancing releases dopamine and endorphins. Moving freely without judgment helps release trapped emotions, boosts creativity, and provides a powerful outlet for stress energy.",
    steps: [
      "Put on your favorite upbeat song.",
      "Stand in a clear space.",
      "Start by just swaying your hips.",
      "Let your arms move however they want.",
      "Don't worry about looking cool—focus on how it feels.",
      "Shake out your whole body at the end to release tension."
    ]
  ),
  Exercise(
    id: '14',
    title: 'Peaceful Visualization',
    description: 'Imagine a safe, calm place.',
    duration: '10 mins',
    type: ExerciseType.visualization,
    minScore: 0,
    maxScore: 100,
    benefits: "Visualization tricks the brain into believing you are actually in a calm environment. This mental escape lowers heart rate and blood pressure, providing a deep psychological rest.",
    steps: [
      "Find a quiet comfortable spot and close your eyes.",
      "Imagine a place where you feel perfectly safe (beach, forest, room).",
      "What do you see? (Colors, light, objects)",
      "What do you hear? (Waves, birds, silence)",
      "What do you smell? (Salt air, pine, rain)",
      "Stay in this place, soaking up the feeling of safety.",
      "Slowly bring yourself back when you are ready."
    ]
  ),
  Exercise(
    id: '15',
    title: 'Social Connection',
    description: 'Reach out to someone you trust.',
    duration: '10 mins',
    type: ExerciseType.social,
    minScore: 30,
    maxScore: 80,
    benefits: "Social connection triggers oxytocin, the 'love hormone'. Even a brief text or call can reduce feelings of isolation and remind you that you are supported and valued.",
    steps: [
      "Scroll through your contacts.",
      "Choose one friend or family member you haven't spoken to lately.",
      "Send a simple text: 'Thinking of you' or 'How are you?'.",
      "Or, make a quick 5-minute phone call.",
      "Focus on listening to their voice.",
      "Allow yourself to feel connected and less alone."
    ]
  ),
  Exercise(
    id: '16',
    title: 'Goal Setting Session',
    description: 'Plan your next small steps.',
    duration: '10 mins',
    type: ExerciseType.planning,
    minScore: 40,
    maxScore: 100,
    benefits: "Breaking undefined worries into concrete tasks reduces anxiety. Planning gives you a sense of control and agency, turning a mountain of stress into climbable steps.",
    steps: [
      "Open a notebook or your phone's calendar.",
      "Identify one main goal or stressor for the week.",
      "Break it down into 3 tiny, manageable steps.",
      "Schedule exactly when you will do step 1.",
      "Write down a potential obstacle and how you'll handle it.",
      "Close the book and trust the plan."
    ]
  ),
  Exercise(
    id: '17',
    title: 'Mindful Music Listening',
    description: 'Truly listen to a song.',
    duration: '5 mins',
    type: ExerciseType.music,
    minScore: 0,
    maxScore: 100,
    benefits: "Active listening serves as a meditation anchor. Music directly impacts the limbic system (emotional brain), capable of shifting your mood faster than almost any other stimulus.",
    steps: [
      "Put on headphones for the best experience.",
      "Choose a song that matches the mood you WANT to feel.",
      "Close your eyes and press play.",
      "Try to pick out individual instruments (bass, drums, melody).",
      "Notice how the music physically feels in your ears.",
      "If your mind wanders, come back to the bassline."
    ]
  ),
];
