from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pickle
import pandas as pd
import numpy as np

app = FastAPI()

# Load Model and Columns
try:
    with open('model.pkl', 'rb') as f:
        model = pickle.load(f)
    with open('model_columns.pkl', 'rb') as f:
        model_columns = pickle.load(f)
    print("Model and columns loaded successfully.")
except FileNotFoundError:
    print("Error: Model files not found. Run train_model.py first.")
    model = None
    model_columns = None

class UserInput(BaseModel):
    level: int
    mood: int

@app.get("/")
def home():
    return {"message": "Mental Health Recommendation API is Running"}

@app.post("/recommend")
def recommend(data: UserInput):
    if not model or not model_columns:
        raise HTTPException(status_code=500, detail="Model not loaded. Please train the model first.")

    try:
        # Prepare input DataFrame
        input_data = pd.DataFrame([{
            'level': data.level,
            'mood': data.mood
        }])

        # Predict probabilities
        # MultiOutputClassifier with RandomForest returns a list of arrays (one per label)
        # Each array has shape (n_samples, n_classes). We want the probability of class 1.
        
        predictions = {}
        
        # model.predict_proba(X) returns a list of arrays of shape (n_samples, 2)
        # We need the probability of the positive class (index 1) for each label.
        probas = model.predict_proba(input_data)
        
        for i, col_name in enumerate(model_columns):
            # probas[i] is array [[prob_0, prob_1]] for the i-th label
            # We take index 0 (first sample) and index 1 (positive class probability)
            # Handle cases where a label might have only 1 class in training (though rare with RF)
            if probas[i].shape[1] > 1:
                prob = probas[i][0][1]
            else:
                prob = 0.0 # Should not happen if data is diverse enough
            
            predictions[col_name] = prob

        # Sort by probability and take top 5
        top_5 = sorted(predictions, key=predictions.get, reverse=True)[:5]
        
        return {"recommendations": top_5}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=8000)
