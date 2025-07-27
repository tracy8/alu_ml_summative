import os
import numpy as np
import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from contextlib import asynccontextmanager

# Declare the app
app = FastAPI()

# Global variable for the model
model = None

# Use lifespan instead of deprecated @on_event("startup")
@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    model_path = os.path.join("models", "best_model.pkl")
    if not os.path.exists(model_path):
        raise FileNotFoundError("Model file not found at path: models/best_model.pkl")
    model = joblib.load(model_path)
    yield

app = FastAPI(lifespan=lifespan)

# Request schema
class StudentData(BaseModel):
    Age: int
    Gender: str
    SchoolLocation: str
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

# Preprocessing function
def preprocess(data: StudentData):
    gender_map = {"Male": 0, "Female": 1}
    school_location_map = {"Urban": 1, "Rural": 0}
    parental_education_map = {"High School": 0, "Bachelor": 1, "Master": 2, "PhD": 3}
    yes_no_map = {"Yes": 1, "No": 0}
    grade_class_map = {"A": 4, "B": 3, "C": 2, "D": 1, "F": 0}

    try:
        return np.array([
            data.Age,
            gender_map[data.Gender],
            school_location_map[data.SchoolLocation],
            parental_education_map[data.ParentalEducation],
            data.StudyTimeWeekly,
            data.Absences,
            yes_no_map[data.Tutoring],
            yes_no_map[data.ParentalSupport],
            yes_no_map[data.Extracurricular],
            yes_no_map[data.Sports],
            yes_no_map[data.Music],
            yes_no_map[data.Volunteering],
            grade_class_map[data.GradeClass],
        ]).reshape(1, -1)
    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"Invalid value: {str(e)}")

# Prediction endpoint
@app.post("/predict")
async def predict(data: StudentData):
    if model is None:
        raise HTTPException(status_code=503, detail="Model is not loaded.")
    
    processed = preprocess(data)
    try:
        prediction = model.predict(processed)[0]
        return {"prediction": round(float(prediction), 2)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
