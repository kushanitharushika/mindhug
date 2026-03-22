import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import pickle

print("Starting training of Stroop ML Model...")

# Generate Synthetic Data
np.random.seed(42)
n_samples = 2000

# Features distribution
reaction_times = np.random.randint(400, 2000, size=n_samples) # average reaction time in milliseconds
error_rates = np.random.uniform(0, 40, size=n_samples) # error percentage (0 to 40%)
stroop_effects = np.random.randint(50, 700, size=n_samples) # incongruent RT - congruent RT

stress_levels = []
for i in range(n_samples):
    rt = reaction_times[i]
    er = error_rates[i]
    se = stroop_effects[i]
    
    # Labeling Logic (to mimic real-world cognitive stress indicators)
    if er >= 20 or se > 400:
        stress_levels.append(2) # 2 = Stressed (High error or massive cognitive load slowdown)
    elif er <= 8 and se <= 200 and rt < 1000:
        stress_levels.append(0) # 0 = Calm (Sharp focus, no hesitation)
    else:
        stress_levels.append(1) # 1 = Normal

df = pd.DataFrame({
    'reaction_time': reaction_times,
    'error_rate': error_rates,
    'stroop_effect': stroop_effects,
    'stress_level': stress_levels
})

X = df[['reaction_time', 'error_rate', 'stroop_effect']]
y = df['stress_level']

# Train Model
model = RandomForestClassifier(n_estimators=100, random_state=42, max_depth=5)
model.fit(X, y)

# Save Model
with open('stroop_rf_model.pkl', 'wb') as f:
    pickle.dump(model, f)

print(f"Success! Stroop ML Model trained on {n_samples} samples and saved as 'stroop_rf_model.pkl'.")
