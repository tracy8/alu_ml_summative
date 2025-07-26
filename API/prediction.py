from fastapi import FastAPI
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
import os

model_path = os.path.join("..", "models", "best_model.pkl")
model = joblib.load(model_path)


# Define expected feature columns (these must match the ones used during training)
expected_columns = [
    'Age', 'StudyTimeWeekly', 'Absences',
    'Gender_female', 'Gender_male',
    'Ethnicity_Group A', 'Ethnicity_Group B', 'Ethnicity_Group C',
    'ParentalEducation_associate\'s degree', 'ParentalEducation_bachelor\'s degree',
    'Tutoring_yes', 'ParentalSupport_yes',
    'Extracurricular_yes', 'Sports_yes',
    'Music_yes', 'Volunteering_yes'
]

# Input schema
class StudentData(BaseModel):
    Age: int = Field(..., ge=10, le=25)
    StudyTimeWeekly: float = Field(..., ge=0, le=60)
    Absences: int = Field(..., ge=0, le=100)
    Gender: str
    Ethnicity: str
    ParentalEducation: str
    Tutoring: str
    ParentalSupport: str
    Extracurricular: str
    Sports: str
    Music: str
    Volunteering: str
    GradeClass: str  # not used in prediction but included for completeness

# Set up FastAPI
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Helper function to preprocess input
def preprocess_input(input_data: dict):
    df = pd.DataFrame([input_data])
    df = pd.get_dummies(df)

    # Add missing expected columns
    for col in expected_columns:
        if col not in df.columns:
            df[col] = 0

    return df[expected_columns]

# Home route
@app.post("/predict")
def predict(data: StudentData):
    try:
        input_dict = data.dict()

        # Convert to DataFrame with correct format
        import pandas as pd
        input_df = pd.DataFrame([input_dict])

        # Predict
        prediction = model.predict(input_df)[0]
        return {"predicted_STEM_potential": round(prediction, 2)}

    except Exception as e:
        return {"error": str(e)}

