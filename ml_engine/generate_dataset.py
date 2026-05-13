import pandas as pd
import random

# Define core exercises/activities
exercises = [
    'breathing', 'yoga', 'walking', 'stretching', 'cardio', 
    'strength', 'hiit', 'dance', 'meditation', 'grounding', 'journaling'
]

# Define mappings based on Level (0-3) and Mood (0-4)
# Level: 0=Priority, 1=Needs Attention, 2=Managing, 3=Balanced
# Mood: 0=Anxious, 1=Sad, 2=Neutral, 3=Calm, 4=Happy

def get_suitable_exercises(level, mood):
    suitable = []
    
    # Logic based on user request and general wellness principles
    
    # Level 0 (Priority Support) - Focus on grounding, calming, safety
    if level == 0:
        suitable.extend(['breathing', 'grounding', 'meditation'])
        if mood == 0: # Anxious
            suitable.extend(['stretching']) # Gentle movement
        elif mood == 1: # Sad
            suitable.extend(['walking', 'yoga']) # Gentle movement
        # Avoid high energy activities for Level 0 generally
        
    # Level 1 (Needs Attention) - Gentle activation + regulation
    elif level == 1:
        suitable.extend(['yoga', 'walking', 'stretching', 'breathing'])
        if mood == 0: # Anxious
            suitable.append('meditation')
        elif mood == 1: # Sad
            suitable.append('dance') # Light movement to uplift
        elif mood == 4: # Happy (rare for this level but possible)
            suitable.extend(['cardio', 'dance'])

    # Level 2 (Managing Well) - Resilience building
    elif level == 2:
        suitable.extend(['yoga', 'walking', 'cardio', 'strength'])
        if mood == 0: # Anxious
            suitable.extend(['breathing', 'meditation'])
        elif mood == 3: # Calm
            suitable.extend(['stretching', 'journaling'])
        elif mood == 4: # Happy
            suitable.extend(['dance', 'hiit'])

    # Level 3 (Balanced) - Performance & Optimization
    elif level == 3:
        suitable.extend(['cardio', 'strength', 'hiit', 'yoga'])
        if mood == 0: # Anxious (even balanced people get anxious)
            suitable.extend(['breathing', 'meditation'])
        elif mood == 1: # Sad
            suitable.extend(['walking', 'journaling'])
        elif mood == 4: # Happy
            suitable.extend(['dance', 'hiit', 'strength']) # Go hard!

    # Add some noise/randomness to make it realistic
    # Sometimes add a random 'good' habit like journaling or walking if not present
    if random.random() > 0.7:
        suitable.append(random.choice(['journaling', 'walking']))

    return list(set(suitable)) # unique items

# Generate Dataset
data = []
num_samples = 200 # Generate enough samples

for _ in range(num_samples):
    level = random.choice([0, 1, 2, 3])
    mood = random.choice([0, 1, 2, 3, 4])
    
    suitable_list = get_suitable_exercises(level, mood)
    
    row = {
        'level': level,
        'mood': mood
    }
    
    # One-hot encode the target exercises
    for ex in exercises:
        row[ex] = 1 if ex in suitable_list else 0
        
    data.append(row)

df = pd.DataFrame(data)
df.to_csv('exercise_dataset.csv', index=False)
print("Dataset generated: exercise_dataset.csv")
print(df.head())
