import os
from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np

app = FastAPI()

# Global variable for the model
model = None

# Load the trained model on startup
@app.on_event("startup")
def load_model():
    global model
    model_path = os.path.join("models", "best_model.pkl")
    model = joblib.load(model_path)

# Defined request schema
class StudentData(BaseModel):
    Age: int
    Gender: str
    SchoolLocation: str  # updated
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

# Converted inputs to numerical values as used in training
def preprocess(data: StudentData):
    gender_map = {"Male": 0, "Female": 1}
    school_location_map = {"Urban": 1, "Rural": 0}
    parental_education_map = {"High School": 0, "Bachelor": 1, "Master": 2, "PhD": 3}
    yes_no_map = {"Yes": 1, "No": 0}
    grade_class_map = {"A": 4, "B": 3, "C": 2, "D": 1, "F": 0}

    return np.array([
        data.Age,
        gender_map.get(data.Gender, 0),
        school_location_map.get(data.SchoolLocation, 0),
        parental_education_map.get(data.ParentalEducation, 0),
        data.StudyTimeWeekly,
        data.Absences,
        yes_no_map.get(data.Tutoring, 0),
        yes_no_map.get(data.ParentalSupport, 0),
        yes_no_map.get(data.Extracurricular, 0),
        yes_no_map.get(data.Sports, 0),
        yes_no_map.get(data.Music, 0),
        yes_no_map.get(data.Volunteering, 0),
        grade_class_map.get(data.GradeClass, 0),
    ]).reshape(1, -1)

@app.post("/predict")
async def predict(data: StudentData):
    processed = preprocess(data)
    prediction = model.predict(processed)[0]
    return {"prediction": float(prediction)}
