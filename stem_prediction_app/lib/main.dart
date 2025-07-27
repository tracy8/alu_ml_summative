import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ),
    home: PredictionForm(),
  ));
}

class PredictionForm extends StatefulWidget {
  @override
  _PredictionFormState createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  final _formKey = GlobalKey<FormState>();

  final ageController = TextEditingController();
  final studyTimeController = TextEditingController();

  String gender = 'Male';
  String schoolLocation = 'Urban';
  String parentalEducation = 'Bachelor';
  int absences = 0;
  String tutoring = 'Yes';
  String parentalSupport = 'Yes';
  String extracurricular = 'Yes';
  String sports = 'Yes';
  String music = 'Yes';
  String volunteering = 'Yes';
  String gradeClass = 'A';

  String result = '';
  bool isLoading = false;

  Future<void> predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      result = '';
    });

    final url = Uri.parse('https://stem-prediction.onrender.com/predict');

    final body = jsonEncode({
      "Age": int.parse(ageController.text),
      "Gender": gender,
      "SchoolLocation": schoolLocation,
      "ParentalEducation": parentalEducation,
      "StudyTimeWeekly": double.parse(studyTimeController.text),
      "Absences": absences,
      "Tutoring": tutoring,
      "ParentalSupport": parentalSupport,
      "Extracurricular": extracurricular,
      "Sports": sports,
      "Music": music,
      "Volunteering": volunteering,
      "GradeClass": gradeClass,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double score = data['prediction'];
        String interpretation = "";

        if (score >= 4.0) {
          interpretation = "Very strong potential in STEM fields!";
        } else if (score >= 3.0) {
          interpretation = "Good potential in STEM, with room to grow.";
        } else if (score >= 2.0) {
          interpretation = "Moderate potential. Consider strengthening your study habits.";
        } else {
          interpretation = "Limited potential in STEM based on current indicators.";
        }

        setState(() {
          result = "🎯 Predicted STEM Potential Score: ${score.toStringAsFixed(2)}\n\n$interpretation";
        });
      } else {
        setState(() => result = " Error: ${response.body}");
      }
    } catch (e) {
      setState(() => result = " Failed to connect to the API.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildDropdown(String label, List<String> options, String value, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildAbsenceDropdown() {
    return DropdownButtonFormField<int>(
      value: absences,
      decoration: InputDecoration(labelText: 'How many days have you been absent?'),
      items: List.generate(91, (index) => DropdownMenuItem(value: index, child: Text("$index"))),
      onChanged: (val) => setState(() => absences = val ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: Text("STEM Potential Predictor", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Enter your age'),
                    validator: (val) => val == null || int.tryParse(val) == null ? 'Please enter a valid number' : null,
                  ),
                  SizedBox(height: 16),
                  buildDropdown("Gender", ['Male', 'Female'], gender, (val) => setState(() => gender = val!)),
                  SizedBox(height: 16),
                  buildDropdown("Where is your school located?", ['Urban', 'Rural'], schoolLocation, (val) => setState(() => schoolLocation = val!)),
                  SizedBox(height: 16),
                  buildDropdown("Parent's highest education level", ['High School', 'Bachelor', 'Master', 'PhD'], parentalEducation, (val) => setState(() => parentalEducation = val!)),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: studyTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'How many hours do you study per week?'),
                    validator: (val) => val == null || double.tryParse(val) == null ? 'Please enter a valid number' : null,
                  ),
                  SizedBox(height: 16),
                  buildAbsenceDropdown(),
                  SizedBox(height: 16),
                  buildDropdown("Do you receive extra tutoring?", ['Yes', 'No'], tutoring, (val) => setState(() => tutoring = val!)),
                  SizedBox(height: 16),
                  buildDropdown("Do your parents support your studies?", ['Yes', 'No'], parentalSupport, (val) => setState(() => parentalSupport = val!)),
                  SizedBox(height: 16),
                  buildDropdown("Do you participate in extracurricular activities?", ['Yes', 'No'], extracurricular, (val) => setState(() => extracurricular = val!)),
                  SizedBox(height: 16),
                  buildDropdown("Do you play any sports?", ['Yes', 'No'], sports, (val) => setState(() => sports = val!)),
                  SizedBox(height: 16),
                  buildDropdown("Do you engage in music-related activities?", ['Yes', 'No'], music, (val) => setState(() => music = val!)),
                  SizedBox(height: 16),
                  buildDropdown("Do you volunteer?", ['Yes', 'No'], volunteering, (val) => setState(() => volunteering = val!)),
                  SizedBox(height: 16),
                  buildDropdown("What was your grade last term?", ['A', 'B', 'C', 'D', 'F'], gradeClass, (val) => setState(() => gradeClass = val!)),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : predict,
                    child: isLoading
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Predict'),
                  ),
                  SizedBox(height: 24),
                  if (result.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        result,
                        style: TextStyle(fontSize: 16, color: Colors.blue[900]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
