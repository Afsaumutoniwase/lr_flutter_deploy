# **Hydroponic pH Prediction System**

This project is a **machine learning-based system** designed to predict the optimal pH level for hydroponic farming based on key soil and environmental factors. It consists of three main components:

1. **Machine Learning Model**: A linear regression model trained on hydroponic farming data.
2. **API**: A FastAPI-based RESTful API that serves predictions.
3. **Flutter App**: A mobile app that interacts with the API to make predictions.

---

## **Table of Contents**
1. [Dataset Description](#dataset-description)
2. [Project Structure](#project-structure)
3. [How to Use](#how-to-use)
   - [Running the API](#running-the-api)
   - [Running the Flutter App](#running-the-flutter-app)
4. [API Documentation](#api-documentation)
5. [Flutter App Demo](#flutter-app-demo)
6. [Video Demo](#video-demo)
7. [Contributing](#contributing)
8. [License](#license)

---

## **Dataset Description**

### **Overview**
The dataset contains agricultural and environmental factors influencing different crops in a hydroponic farming system. It is used to analyze soil conditions and predict the optimal pH levels for different crops.

### **Features**
Each row represents a unique data point containing seven key attributes that impact crop growth:

| Feature          | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| **Soil EC (dS/m)** | Electrical conductivity, indicating the nutrient concentration.             |
| **Nitrogen (ppm)** | Essential for leaf growth and overall plant health.                         |
| **Phosphorus (ppm)** | Supports root development and flowering.                                   |
| **Potassium (ppm)** | Regulates water uptake and strengthens plant resistance.                    |
| **Moisture (%)**    | Percentage of water present in the soil/growth medium.                     |
| **Temperature (°C)** | Optimal temperature for each crop.                                         |
| **Crop**           | The crop type, encoded as follows:                                         |

### **Crop Encoding**
| Crop            | Encoding |
|-----------------|----------|
| Bell Pepper     | 0        |
| Bitter Gourd    | 1        |
| Carrot          | 2        |
| Corn            | 3        |
| Cucumber        | 4        |
| Eggplant        | 5        |
| Green Chili     | 6        |
| Lettuce         | 7        |
| Mustard Greens  | 8        |
| Pechay          | 9        |
| Squash          | 10       |
| Tomato          | 11       |
| Watermelon      | 12       |

### **Data Source**
The dataset was sourced from [Zenodo](https://zenodo.org/records/14276906/files/Book1%20(2).csv?download=1), a research data repository.

---

## **Project Structure**

```
lr_flutter_deploy/
│
├── hydroponic_ph_model.ipynb          # Linear regression model and training code Jupyter notebook for model training
│
├── api.py                              # FastAPI code FastAPI application
│
├── lib/                          # Main flutter app code
├──pubspec.yaml                  # Flutter dependencies
│
├── README.md                         # Project documentation
```

---

## **How to Use**

### **Running the API**
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/mathematics_for_ml_summative.git
   cd mathematics_for_ml_summative/API
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the API:
   ```bash
   uvicorn prediction:app --host 0.0.0.0 --port 8000
   ```

4. Access the API documentation:
   - Swagger UI: [http://localhost:8000/docs](http://localhost:8000/docs)
   - ReDoc: [http://localhost:8000/redoc](http://localhost:8000/redoc)

---

### **Running the Flutter App**
1. Install Flutter: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).

2. Navigate to the Flutter app directory:
   ```bash
   cd mathematics_for_ml_summative/FlutterApp
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

---

## **API Documentation**

### **API Endpoint**
- **URL**: [https://hydroponic-ph-prediction.onrender.com](https://hydroponic-ph-prediction.onrender.com)
- **Swagger UI**: [https://hydroponic-ph-prediction.onrender.com/docs](https://hydroponic-ph-prediction.onrender.com/docs)

### **Make a Prediction**
- **Endpoint**: `POST /predict`
- **Request Body**:
  ```json
  {
    "soil_ec": 1.5,
    "nitrogen": 50.0,
    "phosphorus": 30.0,
    "potassium": 150.0,
    "moisture": 40.0,
    "temperature": 25.0,
    "crop": 2
  }
  ```
- **Response**:
  ```json
  {
    "predicted_pH": 6.4251763878156485
  }
  ```

---

## **Flutter App Demo**

### **Features**
- Input fields for all required variables.
- A **Predict** button to send data to the API.
- A display area to show the predicted pH value or error messages.

### **Screenshots**
![App Screenshot 1](https://via.placeholder.com/300x600.png?text=Input+Screen)
![App Screenshot 2](https://via.placeholder.com/300x600.png?text=Prediction+Result)

---

## **Video Demo**
Watch the video demo on YouTube: [Hydroponic pH Prediction Demo](https://youtu.be/your-video-id)

---

## **Contributing**
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

---
