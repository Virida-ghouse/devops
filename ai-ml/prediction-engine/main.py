from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import numpy as np
import pandas as pd
from datetime import datetime
import os

app = FastAPI(
    title="VIRIDA AI/ML Prediction Engine",
    description="Moteur de prédiction IA pour VIRIDA",
    version="1.0.0"
)

# Modèles de données
class PredictionRequest(BaseModel):
    data: list
    model_type: str = "default"

class PredictionResponse(BaseModel):
    prediction: float
    confidence: float
    model_used: str
    timestamp: str

class HealthResponse(BaseModel):
    status: str
    service: str
    timestamp: str
    version: str

# Modèle ML simple (simulation)
class SimpleMLModel:
    def __init__(self):
        self.model_name = "VIRIDA_Prediction_v1.0"
        self.is_trained = True
    
    def predict(self, data):
        # Simulation d'une prédiction ML
        if len(data) < 2:
            raise ValueError("Au moins 2 valeurs requises")
        
        # Calcul simple basé sur la moyenne et variance
        mean_val = np.mean(data)
        std_val = np.std(data)
        
        # Prédiction simulée
        prediction = mean_val + (std_val * 0.5)
        confidence = min(0.95, max(0.1, 1.0 - (std_val / mean_val) if mean_val > 0 else 0.5))
        
        return prediction, confidence

# Instance du modèle
ml_model = SimpleMLModel()

@app.get("/", response_model=dict)
async def root():
    return {
        "service": "VIRIDA AI/ML Prediction Engine",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "predict": "/predict",
            "models": "/models",
            "docs": "/docs"
        },
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        service="prediction-engine",
        timestamp=datetime.now().isoformat(),
        version="1.0.0"
    )

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    try:
        # Validation des données
        if not request.data:
            raise HTTPException(status_code=400, detail="Données manquantes")
        
        if len(request.data) < 2:
            raise HTTPException(status_code=400, detail="Au moins 2 valeurs requises")
        
        # Conversion en numpy array
        data_array = np.array(request.data, dtype=float)
        
        # Prédiction
        prediction, confidence = ml_model.predict(data_array)
        
        return PredictionResponse(
            prediction=float(prediction),
            confidence=float(confidence),
            model_used=ml_model.model_name,
            timestamp=datetime.now().isoformat()
        )
    
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur interne: {str(e)}")

@app.get("/models")
async def list_models():
    return {
        "models": [
            {
                "name": ml_model.model_name,
                "type": "regression",
                "status": "trained" if ml_model.is_trained else "untrained",
                "features": ["numerical_data"],
                "description": "Modèle de prédiction VIRIDA v1.0"
            }
        ],
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/status")
async def api_status():
    return {
        "service": "VIRIDA AI/ML Prediction Engine",
        "status": "running",
        "models_loaded": 1,
        "uptime": "N/A",
        "memory_usage": "N/A",
        "timestamp": datetime.now().isoformat()
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
