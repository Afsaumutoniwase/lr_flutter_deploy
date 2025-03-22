import 'package:flutter/material.dart';
import '../models/hydroponic_data.dart';
import '../services/api_service.dart';
import '../widgets/prediction_form_field.dart';
import '../widgets/prediction_result_card.dart';
import '../widgets/theme_toggle.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController soilEcController = TextEditingController();
  final TextEditingController nitrogenController = TextEditingController();
  final TextEditingController phosphorusController = TextEditingController();
  final TextEditingController potassiumController = TextEditingController();
  final TextEditingController moistureController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();

  String predictionResult = "";
  String suggestion = "";
  bool isLoading = false;

  int? selectedCrop;
  final Map<String, int> cropEncoding = {
    'Bell Pepper': 0,
    'Bitter Gourd': 1,
    'Carrot': 2,
    'Corn': 3,
    'Cucumber': 4,
    'Eggplant': 5,
    'Green Chili': 6,
    'Lettuce': 7,
    'Mustard Greens': 8,
    'Pechay': 9,
    'Squash': 10,
    'Tomato': 11,
    'Watermelon': 12,
  };

  Future<void> predictpH() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiService = ApiService();

      // First check connectivity before making the actual API call
      bool isConnected = await apiService.checkConnectivity();
      if (!isConnected) {
        throw Exception(
          'Cannot connect to the server. Please check your internet connection.',
        );
      }

      final inputData = HydroponicInput(
        soilEc: double.parse(soilEcController.text),
        nitrogen: double.parse(nitrogenController.text),
        phosphorus: double.parse(phosphorusController.text),
        potassium: double.parse(potassiumController.text),
        moisture: double.parse(moistureController.text),
        temperature: double.parse(temperatureController.text),
        crop: selectedCrop ?? 0,
      );

      final result = await apiService.predictPH(inputData);

      String predResult = "Predicted pH: ${result.toStringAsFixed(2)}";
      String suggestion = "";

      if (result < 5.5) {
        suggestion =
            "pH is too low. Consider adding lime (calcium carbonate) or increasing alkalinity.";
      } else if (result > 7.0) {
        suggestion =
            "pH is too high. Consider adding acidic nutrients like phosphoric acid.";
      } else {
        suggestion = "pH is optimal for your crops.";
      }

      setState(() {
        isLoading = false;
      });

      // Show the modal dialog with results
      PredictionResultModal.show(
        context,
        predictionResult: predResult,
        suggestion: suggestion,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Extract a user-friendly message from the exception
      String errorMessage = 'Unable to predict pH. Please try again later.';
      String detailedError = e.toString();

      // Log the full error for debugging
      print("Error during prediction: $detailedError");

      if (detailedError.contains('Network error') ||
          detailedError.contains('SocketException') ||
          detailedError.contains('connect to the server')) {
        errorMessage =
            'Network error: Check your internet connection and try again.';
      } else if (detailedError.contains('Connection timed out') ||
          detailedError.contains('TimeoutException')) {
        errorMessage =
            'Server is taking too long to respond. Please try again later.';
      } else if (detailedError.contains('Invalid response format')) {
        errorMessage =
            'Received invalid data from server. Please try again later.';
      } else if (detailedError.contains('Missing pH field')) {
        errorMessage =
            'The API response format has changed. Please update the app.';
      }

      // Show enhanced error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Error"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(errorMessage),
                  SizedBox(height: 8),
                  if (detailedError.contains('Network error') ||
                      detailedError.contains('SocketException'))
                    Text(
                      "• Make sure your device is connected to the internet\n• Try switching between Wi-Fi and mobile data",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (detailedError.contains('Connection timed out'))
                    Text(
                      "• The server might be under maintenance\n• Try again in a few minutes",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  // Add developer details for debugging
                  ExpansionTile(
                    title: Text(
                      "Technical Details",
                      style: TextStyle(fontSize: 12),
                    ),
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.grey[200],
                        child: Text(
                          detailedError,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    predictpH(); // Retry the prediction
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
      );
    }
  }

  // Validation function
  String? validateInput(String? value) {
    if (value == null || value.isEmpty) return "This field is required";
    final number = double.tryParse(value);
    if (number == null) return "Enter a valid number";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "FarmSmart Prediction",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ThemeToggle(isSmall: true),
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "📊 Enter the required parameters to predict the pH level in your hydroponic system.",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              PredictionFormField(
                controller: soilEcController,
                labelText: "Soil EC (dS/m)",
                validator: validateInput,
                icon: Icons.water_drop,
              ),

              PredictionFormField(
                controller: nitrogenController,
                labelText: "Nitrogen (ppm)",
                validator: validateInput,
                icon: Icons.grass,
              ),

              PredictionFormField(
                controller: phosphorusController,
                labelText: "Phosphorus (ppm)",
                validator: validateInput,
                icon: Icons.science,
              ),

              PredictionFormField(
                controller: potassiumController,
                labelText: "Potassium (ppm)",
                validator: validateInput,
                icon: Icons.spa,
              ),

              PredictionFormField(
                controller: moistureController,
                labelText: "Moisture (%)",
                validator: validateInput,
                icon: Icons.opacity,
              ),

              PredictionFormField(
                controller: temperatureController,
                labelText: "Temperature (°C)",
                validator: validateInput,
                icon: Icons.thermostat,
              ),

              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedCrop,
                onChanged: (newValue) {
                  setState(() {
                    selectedCrop = newValue;
                  });
                },
                items:
                    cropEncoding.entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                decoration: InputDecoration(
                  labelText: "Select Crop",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.eco),
                ),
                validator:
                    (value) => value == null ? "Please select a crop" : null,
              ),

              SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : predictpH,
                  icon:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(Icons.analytics),
                  label: Text(
                    isLoading ? "Predicting..." : "Predict pH",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
