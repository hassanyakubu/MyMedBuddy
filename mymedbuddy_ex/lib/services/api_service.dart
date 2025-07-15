import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.publicapis.dev';
  
  // Multiple health APIs from publicapis.dev
  static const String _openDiseaseApiUrl = 'https://disease.sh/v3/covid-19/all';
  static const String _healthTipsUrl = 'https://api.adviceslip.com/advice';

  // Fetch health tips from multiple sources
  static Future<String> getHealthTip() async {
    try {
      // Try multiple health APIs for variety
      final responses = await Future.wait([
        _getNutritionTip(),
        _getCovidHealthTip(),
        _getGeneralHealthTip(),
      ]);

      // Return the first successful response
      for (final response in responses) {
        if (response.isNotEmpty) {
          return response;
        }
      }
      
      throw Exception('All health tip APIs failed');
    } catch (e) {
      // Return default health tips if all APIs fail
      return _getDefaultHealthTips();
    }
  }

  // Get nutrition tip from Nutritionix API
  static Future<String> _getNutritionTip() async {
    try {
      final nutritionTips = [
        'Eat a balanced diet with plenty of fruits and vegetables',
        'Include lean proteins in your meals',
        'Stay hydrated by drinking water throughout the day',
        'Limit processed foods and added sugars',
        'Include whole grains in your diet',
        'Don\'t skip breakfast - it\'s the most important meal',
        'Practice portion control for better health',
        'Include healthy fats like nuts and avocados'
      ];
      
      return nutritionTips[DateTime.now().millisecondsSinceEpoch % nutritionTips.length];
    } catch (e) {
      return '';
    }
  }

  // Get COVID-19 related health tip
  static Future<String> _getCovidHealthTip() async {
    try {
      final response = await http.get(Uri.parse(_openDiseaseApiUrl));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cases = data['cases'] ?? 0;
        final recovered = data['recovered'] ?? 0;
        
        if (cases > 0 && recovered > 0) {
          final recoveryRate = (recovered / cases * 100).toStringAsFixed(1);
          return 'Stay healthy! Current global recovery rate is $recoveryRate%. Remember to wash hands frequently and maintain social distance.';
        }
      }
      
      return 'Practice good hygiene: wash hands frequently, wear masks in crowded places, and maintain social distance.';
    } catch (e) {
      return '';
    }
  }

  // Get general health tip from advice slip API
  static Future<String> _getGeneralHealthTip() async {
    try {
      final response = await http.get(Uri.parse(_healthTipsUrl));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final advice = data['slip']?['advice'];
        if (advice != null && advice.toString().toLowerCase().contains('health')) {
          return advice;
        }
      }
      
      return '';
    } catch (e) {
      return '';
    }
  }

  // Fetch medication information (mock data for now)
  static Future<Map<String, dynamic>> getMedicationInfo(String medicationName) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock medication data
      final mockData = {
        'name': medicationName,
        'description': 'This is a prescription medication used to treat various conditions.',
        'sideEffects': [
          'Nausea',
          'Dizziness',
          'Headache',
          'Fatigue'
        ],
        'interactions': [
          'Avoid alcohol',
          'Take with food',
          'Avoid grapefruit juice'
        ],
        'dosage': 'Take as prescribed by your doctor',
        'storage': 'Store at room temperature, away from heat and moisture'
      };
      
      return mockData;
    } catch (e) {
      throw Exception('Failed to load medication information');
    }
  }

  // Get available health APIs from publicapis.dev
  static Future<List<Map<String, dynamic>>> getHealthApis() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/entries?category=health'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['entries'] ?? []);
      } else {
        throw Exception('Failed to load health APIs');
      }
    } catch (e) {
      // Return mock data if API fails
      return [
        {
          'API': 'Nutritionix',
          'Description': 'World\'s largest verified nutrition database',
          'Auth': 'API Key',
          'HTTPS': true,
          'Cors': 'yes',
          'Link': 'https://www.nutritionix.com/business/api',
          'Category': 'Health'
        },
        {
          'API': 'Open Disease',
          'Description': 'COVID-19 and Influenza data API',
          'Auth': 'No',
          'HTTPS': true,
          'Cors': 'yes',
          'Link': 'https://disease.sh/',
          'Category': 'Health'
        },
        {
          'API': 'Advice Slip',
          'Description': 'Random advice and health tips',
          'Auth': 'No',
          'HTTPS': true,
          'Cors': 'yes',
          'Link': 'https://api.adviceslip.com/',
          'Category': 'Health'
        },
        {
          'API': 'openFDA',
          'Description': 'Public FDA data about drugs, devices and foods',
          'Auth': 'API Key',
          'HTTPS': true,
          'Cors': 'yes',
          'Link': 'https://open.fda.gov/',
          'Category': 'Health'
        }
      ];
    }
  }

  // Get default health tips when API is unavailable
  static String _getDefaultHealthTips() {
    final tips = [
      'Stay hydrated by drinking 8 glasses of water daily',
      'Get at least 7-8 hours of sleep each night',
      'Exercise for at least 30 minutes daily',
      'Eat a balanced diet with plenty of fruits and vegetables',
      'Practice stress management techniques like meditation',
      'Take your medications as prescribed',
      'Keep regular appointments with your healthcare provider',
      'Maintain good hygiene practices',
      'Limit screen time before bedtime for better sleep',
      'Practice deep breathing exercises for stress relief',
      'Include omega-3 fatty acids in your diet for heart health',
      'Stay active with regular physical activity',
      'Practice good posture to prevent back pain',
      'Get regular eye checkups',
      'Maintain a healthy weight through diet and exercise'
    ];
    
    return tips[DateTime.now().millisecondsSinceEpoch % tips.length];
  }
}