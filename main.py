from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import os
import pandas as pd

app = FastAPI()


# Load model
model_path = os.path.join("models", "best_model.pkl")
model = joblib.load(model_path)

# Features expected during prediction
expected_features = [
    'Age',
    'Gender',
    'Ethnicity',
    'ParentalEducation',
    'StudyTimeWeekly',
    'Absences',
    'Tutoring',
    'ParentalSupport',
    'Extracurricular',
    'Sports',
    'Music',
    'Volunteering',
    'GradeClass'
]

# Input data model
class StudentInput(BaseModel):
    Age: int
    Gender: str
    Ethnicity: str
    ParentalEducation: str
    StudyTimeWeekly: float
    Absences: int
    Tutoring: str
    ParentalSupport: str
    Extracurricular: str
    Sports: str
    Music: str
    Volunteering: str
    GradeClass: str

# Prediction endpoint
@app.post("/predict")
def predict_potential(data: StudentInput):
    df = pd.DataFrame([data.dict()])

    # Ensure all expected columns exist
    df = df.reindex(columns=expected_features, fill_value=0)

    # Predict
    prediction = model.predict(df)[0]
    return {"prediction": prediction}
