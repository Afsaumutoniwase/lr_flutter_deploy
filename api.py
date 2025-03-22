from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np

# Load the saved model
model = joblib.load('best_hydroponic_model.pkl')

# Define input data model with constraints
class InputData(BaseModel):
    soil_ec: float = Field(..., ge=0.0, le=3.0, description="Electrical Conductivity (dS/m), must be between 0 and 3")
    nitrogen: float = Field(..., ge=0.0, le=120.0, description="Nitrogen content (ppm), must be between 0 and 120")
    phosphorus: float = Field(..., ge=0.0, le=80.0, description="Phosphorus content (ppm), must be between 0 and 80")
    potassium: float = Field(..., ge=0.0, le=300.0, description="Potassium content (ppm), must be between 0 and 300")
    moisture: float = Field(..., ge=0.0, le=80.0, description="Moisture percentage, must be between 0 and 80")
    temperature: float = Field(..., ge=0.0, le=30.0, description="Temperature (°C), must be between 0 and 30")
    crop: int = Field(..., ge=0, le=12, description="Encoded crop type (0-12)")

# Initialize FastAPI application
app = FastAPI(
    title="Hydroponic pH Prediction API",
    description="This API predicts the optimal pH level for hydroponic farming based on key soil and environmental factors.",
    version="1.0.0",
    docs_url="/docs",  
    redoc_url="/redoc"
)
# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],
)
# Define crop encoding mapping
CROP_ENCODING_MAPPING = {
    "Bell Pepper": 0,
    "Bitter Gourd": 1,
    "Carrot": 2,
    "Corn": 3,
    "Cucumber": 4,
    "Eggplant": 5,
    "Green Chili": 6,
    "Lettuce": 7,
    "Mustard Greens": 8,
    "Pechay": 9,
    "Squash": 10,
    "Tomato": 11,
    "Watermelon": 12
}
@app.get("/")
async def root():
    return {"message": "Welcome to the Hydroponic pH Prediction API! Go to /docs for API documentation."}

@app.get("/crop-encoding")
async def get_crop_encoding():
    return {"Crop Encoding Mapping": CROP_ENCODING_MAPPING}

# Define the prediction endpoint
@app.post('/predict')
def predict(data: InputData):
    try:
        # Convert input data to numpy array
        input_data = np.array([[
            data.soil_ec, data.nitrogen, data.phosphorus,
            data.potassium, data.moisture, data.temperature,
            data.crop
        ]])

        # Make prediction
        prediction = model.predict(input_data)
        return {'predicted_pH': prediction[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Run the API
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8080)