import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: NutrientFetcher(),
  ));
}

class NutrientFetcher extends StatefulWidget {
  @override
  _NutrientFetcherState createState() => _NutrientFetcherState();
}

class _NutrientFetcherState extends State<NutrientFetcher> {
  final TextEditingController _queryController = TextEditingController();
  List<Map<String, dynamic>> _ingredientData = [];

  // Mapping of API keys to user-friendly labels
  final Map<String, String> _fieldLabels = {
    "name": "Name",
    "calories": "Calories",
    "serving_size_g": "Serving Size (g)",
    "fat_total_g": "Total Fat (g)",
    "fat_saturated_g": "Saturated Fat (g)",
    "protein_g": "Protein (g)",
    "sodium_mg": "Sodium (mg)",
    "potassium_mg": "Potassium (mg)",
    "cholesterol_mg": "Cholesterol (mg)",
    "carbohydrates_total_g": "Total Carbohydrates (g)",
    "fiber_g": "Fiber (g)",
    "sugar_g": "Sugar (g)"
  };

  Future<void> fetchIngredients(String query) async {
    final url = Uri.parse('https://api.api-ninjas.com/v1/nutrition?query=$query');
    final response = await http.get(
      url,
      headers: {'x-api-key': '+U39uMqojAeMzsyGMpxG/w==okaLrT6XXMzxJFGt'}, // Replace with your actual API key
    );

    print('Request URL: ${url.toString()}');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        _ingredientData = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      setState(() {
        _ingredientData = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch data: ${response.reasonPhrase}'),
      ));
    }
  }

  Widget buildIngredientCard(String label, dynamic value) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrients Fetcher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Enter Query',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                fetchIngredients(_queryController.text);
              },
              child: Text('Fetch Nutrients'),
            ),
            SizedBox(height: 16.0),
            _ingredientData.isEmpty
                ? Center(child: Text('No Data'))
                : Expanded(
              child: ListView(
                children: _ingredientData.map((data) {
                  return Column(
                    children: data.entries.map((entry) {
                      final label = _fieldLabels[entry.key] ?? entry.key; // Fallback to the original key if no label is found
                      return buildIngredientCard(label, entry.value);
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
