import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
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

  // Default values
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
      "GradeClass": gradeClass
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
          result = "Predicted STEM Potential Score: ${score.toStringAsFixed(2)}\n$interpretation";
        });
      } else {
        setState(() => result = "Error: ${response.body}");
      }
    } catch (e) {
      setState(() => result = "Failed to connect to the API.");
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
      appBar: AppBar(title: Text("STEM Potential Predictor")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
              buildDropdown("Gender", ['Male', 'Female'], gender, (val) => setState(() => gender = val!)),
              buildDropdown("Where is your school located?", ['Urban', 'Rural'], schoolLocation, (val) => setState(() => schoolLocation = val!)),
              buildDropdown("What is your parent's highest education level?", ['High School', 'Bachelor', 'Master', 'PhD'], parentalEducation, (val) => setState(() => parentalEducation = val!)),
              TextFormField(
                controller: studyTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'How many hours do you study per week?'),
                validator: (val) => val == null || double.tryParse(val) == null ? 'Please enter a valid number' : null,
              ),
              buildAbsenceDropdown(),
              buildDropdown("Do you receive extra tutoring (private or school)?", ['Yes', 'No'], tutoring, (val) => setState(() => tutoring = val!)),
              buildDropdown("Do your parents support your education?", ['Yes', 'No'], parentalSupport, (val) => setState(() => parentalSupport = val!)),
              buildDropdown("Do you participate in extracurricular activities?", ['Yes', 'No'], extracurricular, (val) => setState(() => extracurricular = val!)),
              buildDropdown("Do you play any sports?", ['Yes', 'No'], sports, (val) => setState(() => sports = val!)),
              buildDropdown("Do you participate in music-related activities?", ['Yes', 'No'], music, (val) => setState(() => music = val!)),
              buildDropdown("Do you volunteer in any community or school programs?", ['Yes', 'No'], volunteering, (val) => setState(() => volunteering = val!)),
              buildDropdown("What was your grade last term?", ['A', 'B', 'C', 'D', 'F'], gradeClass, (val) => setState(() => gradeClass = val!)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : predict,
                child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Predict'),
              ),
              SizedBox(height: 20),
              if (result.isNotEmpty)
                Text(
                  result,
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
