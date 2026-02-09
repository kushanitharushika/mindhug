from flask import Flask, request, jsonify
import pickle
import pandas as pd

app = Flask(__name__)

# Load Model
try:
    with open('model.pkl', 'rb') as f:
        model = pickle.load(f)
    print("Model loaded successfully.")
except:
    print("Model not found. Please run train_model.py first.")
    model = None

@app.route('/recommend', methods=['POST'])
def recommend():
    if not model:
        return jsonify({'error': 'Model not trained'}), 500

    data = request.json
    level = data.get('level', 'Level 3 - Balanced & Resilient')
    mood = data.get('mood', 'Neutral')

    # Prepare input for model (needs to match training columns)
    # We used OneHotEncoding based on pandas get_dummies during training
    # Ideally, we should save the column structure or encoder too.
    # For this simple prototype, we'll reconstruct the specific input row.
    
    # 1. Create a dummy DataFrame with the same structure as training
    # (In production, use a saved ColumnTransformer pipeline)
    
    # Simple Heuristic Fallback if model logic is complex to reconstruct without pipeline:
    # Just use the model to predict on a single row dataframe
    
    try:
        # Load columns from training artifact if possible, or hardcode known categories
        # For simplicity in this script, we'll assume the input is processed similarly
        # Real ML approach: Pipeline(OneHotEncoder -> Model)
        
        # Let's rely on the fact that we can just pass the raw "Label" encoding 
        # or just implement the logic here directly if we aren't using a complex model.
        # But user asked for ML. So we will use the model.
        
        # We need to recreate the feature vector
        # A robust way: Save the columns during training.
        with open('model_columns.pkl', 'rb') as f:
            model_columns = pickle.load(f)
            
        input_data = pd.DataFrame([{
            'Level': level,
            'Mood': mood
        }])
        
        # One-hot encode using the known empty columns structure
        input_dummies = pd.get_dummies(input_data)
        input_dummies = input_dummies.reindex(columns=model_columns, fill_value=0)
        
        prediction = model.predict(input_dummies)
        
        # The model predicts a string representation of the list (simplified)
        # Or a class label. Let's say we trained to predict "Exercise_Cluster_ID" or similar.
        # Actually, for this matrix, multi-label classification or string output is needed.
        # Let's assume the target was the stringified list of exercises.
        
        exercises_str = prediction[0]
        # Clean up string representation if needed, or just return it
        # Assuming training data target was literally "['Yoga', 'Walking']"
        
        import ast
        exercises_list = ast.literal_eval(exercises_str)
        
        return jsonify({'recommendations': exercises_list})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
