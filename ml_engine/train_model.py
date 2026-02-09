import pandas as pd
import pickle
from sklearn.tree import DecisionTreeClassifier

# Define the Expanded Matrix Data
# Format: List of exercises/activities as a string representation of a list
data = [
    # --- Level 0: Priority Support Needed (Stabilize, calm, ground) ---
    {'Level': 'Level 0 - Priority Support Needed', 'Mood': 'Anxious', 'Exercises': "['Deep Breathing', '4-7-8 Breathing', 'Box Breathing', 'Progressive Muscle Relaxation', 'Gentle Neck & Shoulder Stretches', 'Seated Forward Fold', '5-4-3-2-1 Grounding', 'Guided Body Scan', 'Holding a warm object', 'Listening to calming nature sounds', 'Watching slow visual patterns']"},
    {'Level': 'Level 0 - Priority Support Needed', 'Mood': 'Sad', 'Exercises': "['Gentle Yoga', 'Deep Breathing', 'Stretching (full body)', 'Slow Walking', 'Seated Cat-Cow', 'Guided Meditation', 'Gratitude journaling', 'Listening to soft instrumental music', 'Sitting near sunlight', 'Self-compassion affirmations']"},
    {'Level': 'Level 0 - Priority Support Needed', 'Mood': 'Neutral', 'Exercises': "['Gentle Yoga', 'Stretching', 'Slow Walking', 'Seated Mobility Exercises', 'Arm Circles & Ankle Rolls', 'Mindful Sitting', 'Breathing Awareness', 'Listening to white noise', 'Light body scan', 'Minimal to-do planning']"},
    {'Level': 'Level 0 - Priority Support Needed', 'Mood': 'Calm', 'Exercises': "['Gentle Yoga', 'Stretching', 'Body Scan Movement', 'Light Walking', 'Supine Twists', 'Mindful Breathing', 'Journaling feelings', 'Soft background music', 'Tea / hydration reminder', 'Digital detox']"},
    {'Level': 'Level 0 - Priority Support Needed', 'Mood': 'Happy', 'Exercises': "['Light Walking', 'Gentle Yoga', 'Stretching', 'Seated Balance Exercises', 'Mobility Flow', 'Gratitude list', 'Light dancing (slow tempo)', 'Sharing positive thoughts', 'Music listening', 'Visualization exercises']"},
    
    # Map other moods to closest fit for Level 0 if not explicitly defined
    {'Level': 'Level 0 - Priority Support Needed', 'Mood': 'Tired', 'Exercises': "['Gentle Yoga', 'Stretching', 'Slow Walking', 'Mindful Sitting', 'Listening to white noise']"}, # Mapped to Neutral/Calm mix
    {'Level': 'Level 0 - Priority Support Needed', 'Mood': 'Energetic', 'Exercises': "['Light Walking', 'Gentle Yoga', 'Stretching', 'Music listening', 'Visualization exercises']"}, # Mapped to Happy

    # --- Level 1: Needs Attention (Regulate emotions + gentle activation) ---
    {'Level': 'Level 1 - Needs Attention', 'Mood': 'Anxious', 'Exercises': "['Breathing Exercises', 'Progressive Muscle Relaxation', 'Gentle Yoga', 'Stretching', 'Mindful Walking', 'Seated Forward Fold', 'Grounding with senses', 'Writing worries -> release', 'Nature sounds', 'Calm breathing timer', 'Posture check']"},
    {'Level': 'Level 1 - Needs Attention', 'Mood': 'Sad', 'Exercises': "['Walking', 'Gentle Yoga', 'Light Stretching', 'Seated Mobility', 'Slow Dance Movement', 'Mindful Movement', 'Music with positive tone', 'Journaling emotions', 'Gratitude notes', 'Sun exposure']"},
    {'Level': 'Level 1 - Needs Attention', 'Mood': 'Neutral', 'Exercises': "['Yoga', 'Stretching', 'Walking', 'Light Cardio', 'Balance Exercises', 'Body awareness scan', 'Daily intention setting', 'Breathing focus', 'Minimal task planning', 'Calm playlist']"},
    {'Level': 'Level 1 - Needs Attention', 'Mood': 'Calm', 'Exercises': "['Yoga Flow', 'Stretching', 'Walking', 'Light Cardio', 'Core Activation (gentle)', 'Mindful Breathing', 'Light journaling', 'Visualization', 'Hydration reminder', 'Music-based relaxation']"},
    {'Level': 'Level 1 - Needs Attention', 'Mood': 'Happy', 'Exercises': "['Light Cardio', 'Dance Workout', 'Yoga', 'Walking', 'Mobility Flow', 'Mood reflection', 'Gratitude journaling', 'Music engagement', 'Short creative activity', 'Social connection reminder']"},

    # Map other moods for Level 1
    {'Level': 'Level 1 - Needs Attention', 'Mood': 'Tired', 'Exercises': "['Yoga', 'Stretching', 'Walking', 'Breathing focus', 'Calm playlist']"},
    {'Level': 'Level 1 - Needs Attention', 'Mood': 'Energetic', 'Exercises': "['Light Cardio', 'Dance Workout', 'Yoga', 'Walking', 'Music engagement']"},


    # --- Level 2: Managing Well (Build resilience & consistency) ---
    {'Level': 'Level 2 - Managing Well', 'Mood': 'Anxious', 'Exercises': "['Yoga', 'Controlled Breathing', 'Walking', 'Stretching', 'Light Cardio', 'Mobility Flow', 'Breath pacing', 'Mindful journaling', 'Relaxing music', 'Nature exposure', 'Goal reflection']"},
    {'Level': 'Level 2 - Managing Well', 'Mood': 'Sad', 'Exercises': "['Brisk Walking', 'Light Cardio', 'Yoga', 'Dance Workout', 'Stretching', 'Mood journaling', 'Positive music', 'Self-talk exercises', 'Visualization', 'Short creative task']"},
    {'Level': 'Level 2 - Managing Well', 'Mood': 'Neutral', 'Exercises': "['Pilates', 'Yoga', 'Walking', 'Light Cardio', 'Core Training', 'Mindful planning', 'Breathing reset', 'Focus timer', 'Body posture check', 'Music break']"},
    {'Level': 'Level 2 - Managing Well', 'Mood': 'Calm', 'Exercises': "['Light Strength Training', 'Yoga', 'Mobility Exercises', 'Walking', 'Stretching', 'Goal setting', 'Reflection journaling', 'Breath awareness', 'Music with rhythm', 'Hydration habit']"},
    {'Level': 'Level 2 - Managing Well', 'Mood': 'Happy', 'Exercises': "['Cardio Workout', 'Dance Workout', 'Strength Training', 'Yoga', 'Walking', 'Achievement reflection', 'Social engagement', 'Creative expression', 'Music flow', 'Positive affirmation']"},
    
    # Map other moods for Level 2
    {'Level': 'Level 2 - Managing Well', 'Mood': 'Tired', 'Exercises': "['Pilates', 'Yoga', 'Walking', 'Breathing reset', 'Music break']"},
    {'Level': 'Level 2 - Managing Well', 'Mood': 'Energetic', 'Exercises': "['Cardio Workout', 'Dance Workout', 'Strength Training', 'Music flow', 'Creative expression']"},


    # --- Level 3: Balanced & Resilient (Optimize performance & mental strength) ---
    {'Level': 'Level 3 - Balanced & Resilient', 'Mood': 'Anxious', 'Exercises': "['Cardio', 'Yoga', 'Stretching', 'Mobility Exercises', 'Cool-down Breathing', 'Balance Training', 'Breath control', 'Visualization', 'Focus training', 'Music regulation', 'Stress-release journaling']"},
    {'Level': 'Level 3 - Balanced & Resilient', 'Mood': 'Sad', 'Exercises': "['Strength Training', 'Cardio', 'Walking', 'Yoga', 'Stretching', 'Mood tracking', 'Positive self-talk', 'Gratitude journaling', 'Music motivation', 'Short social activity']"},
    {'Level': 'Level 3 - Balanced & Resilient', 'Mood': 'Neutral', 'Exercises': "['Mixed Workout', 'Strength Training', 'Cardio', 'Yoga', 'Core Training', 'Goal planning', 'Productivity reflection', 'Focus breathing', 'Energy check-in', 'Music boost']"},
    {'Level': 'Level 3 - Balanced & Resilient', 'Mood': 'Calm', 'Exercises': "['Strength Training', 'Mobility Training', 'Yoga', 'Walking', 'Stretching', 'Long-term planning', 'Deep breathing', 'Reflection writing', 'Music immersion', 'Habit tracking']"},
    {'Level': 'Level 3 - Balanced & Resilient', 'Mood': 'Happy', 'Exercises': "['HIIT', 'Running', 'Strength Training', 'Dance Workout', 'Cardio', 'Performance tracking', 'Celebration reflection', 'Music motivation', 'Social sharing', 'Confidence affirmations']"},

    # Map other moods for Level 3
    {'Level': 'Level 3 - Balanced & Resilient', 'Mood': 'Tired', 'Exercises': "['Mixed Workout', 'Strength Training', 'Yoga', 'Energy check-in', 'Music boost']"},
    {'Level': 'Level 3 - Balanced & Resilient', 'Mood': 'Energetic', 'Exercises': "['HIIT', 'Running', 'Strength Training', 'Performance tracking', 'Music motivation']"},
]

# Convert to DataFrame
df = pd.DataFrame(data)

# Preprocessing: One-Hot Encode Inputs
X = pd.get_dummies(df[['Level', 'Mood']])
y = df['Exercises']

# Train Model (Decision Tree fits perfectly for rules)
model = DecisionTreeClassifier()
model.fit(X, y)

# Save Model & Columns (to ensure input structure matches later)
with open('model.pkl', 'wb') as f:
    pickle.dump(model, f)

with open('model_columns.pkl', 'wb') as f:
    pickle.dump(X.columns, f)

print(f"Model re-trained on expanded matrix ({len(df)} scenarios).")
print(f"Columns saved: {X.columns}")
