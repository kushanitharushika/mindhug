import pandas as pd
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.multioutput import MultiOutputClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

# Load dataset
try:
    data = pd.read_csv("exercise_dataset.csv")
    print("Dataset loaded successfully.")
except FileNotFoundError:
    print("Error: exercise_dataset.csv not found. Run generate_dataset.py first.")
    exit(1)

# Features (Input)
X = data[['level', 'mood']]

# Labels (Output) - all columns except level and mood
y = data.drop(columns=['level', 'mood'])

# Split data (optional but good practice)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Multi-label model using Random Forest
# n_estimators=100 is standard for RF. random_state for reproducibility.
rf = RandomForestClassifier(n_estimators=100, random_state=42)
model = MultiOutputClassifier(rf)

print("Training model...")
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
print(f"Model Accuracy (subset accuracy): {accuracy_score(y_test, y_pred):.2f}")

# Save Model
with open('model.pkl', 'wb') as f:
    pickle.dump(model, f)

# Save Columns (to map predictions back to exercise names)
with open('model_columns.pkl', 'wb') as f:
    pickle.dump(y.columns.tolist(), f)

print("Model saved to model.pkl")
print(f"Columns saved: {y.columns.tolist()}")

# Test a prediction
test_input = [[0, 0]] # Level 0, Mood 0 (Anxious)
print(f"Test Prediction for Level 0, Mood 0: {model.predict(test_input)}")
