import os
import pandas as pd  
import joblib
import traceback
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from contextlib import asynccontextmanager

# Lifespan to load model on startup
@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    model_path = os.path.join("models", "best_model.pkl")
    if not os.path.exists(model_path):
        raise FileNotFoundError("Model file not found at path: models/best_model.pkl")
    model = joblib.load(model_path)
    yield

# Declare the app with lifespan
app = FastAPI(lifespan=lifespan)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variable for the model
model = None

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

# Preprocessing function using DataFrame
def preprocess(data: StudentData):
    gender_map = {"Male": 0, "Female": 1}
    school_location_map = {"Urban": 1, "Rural": 0}
    parental_education_map = {"High School": 0, "Bachelor": 1, "Master": 2, "PhD": 3}
    yes_no_map = {"Yes": 1, "No": 0}
    grade_class_map = {"A": 4, "B": 3, "C": 2, "D": 1, "F": 0}

    try:
        input_dict = {
            "Age": data.Age,
            "Gender": gender_map[data.Gender],
            "SchoolLocation": school_location_map[data.SchoolLocation],
            "ParentalEducation": parental_education_map[data.ParentalEducation],
            "StudyTimeWeekly": data.StudyTimeWeekly,
            "Absences": data.Absences,
            "Tutoring": yes_no_map[data.Tutoring],
            "ParentalSupport": yes_no_map[data.ParentalSupport],
            "Extracurricular": yes_no_map[data.Extracurricular],
            "Sports": yes_no_map[data.Sports],
            "Music": yes_no_map[data.Music],
            "Volunteering": yes_no_map[data.Volunteering],
            "GradeClass": grade_class_map[data.GradeClass]
        }
        return pd.DataFrame([input_dict])
    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"Invalid value: {str(e)}")

# Prediction endpoint
@app.post("/predict")
async def predict(data: StudentData):
    if model is None:
        raise HTTPException(status_code=503, detail="Model is not loaded.")
    
    processed = preprocess(data)  # This returns a DataFrame
    
    try:
        prediction = model.predict(processed)[0]
        return {"prediction": round(float(prediction), 2)}
    except Exception as e:
        import traceback
        tb = traceback.format_exc()
        print("Prediction error:\n", tb)
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

