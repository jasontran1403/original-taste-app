import 'package:original_taste/controller/my_controller.dart';

enum YesNo { yes, no }


class SettingController extends MyController {
  String? selectedTheme;
  String? selectedLayout;
  YesNo online = YesNo.yes;
  YesNo activity = YesNo.yes;
  YesNo searches = YesNo.yes;
  YesNo guestCheckout = YesNo.no;
  YesNo displayPrice = YesNo.no;


  final List<String> layouts = [
    'Default',
    'Electronics',
    'Fashion',
    'Dining',
    'Interior',
    'Home',
  ];


  final List<String> themes = [
    'Default',
    'Dark',
    'Minimalist',
    'High Contrast',
  ];

  String? selectedCountry;

  final List<String> countries = [
    "United Kingdom",
    "France",
    "Netherlands",
    "U.S.A",
    "Denmark",
    "Canada",
    "Australia",
    "India",
    "Germany",
    "Spain",
    "United Arab Emirates",
  ];


  String? localizationSelectedCountry;

  final List<String> localizationCountries = [
    "United Kingdom",
    "France",
    "Netherlands",
    "U.S.A",
    "Denmark",
    "Canada",
    "Australia",
    "India",
    "Germany",
    "Spain",
    "United Arab Emirates",
  ];

  String? selectedLanguage;

  String? selectedCurrencyValue;

  final List<String> currencyOptions = [
    "US Dollar",
    "Pound",
    "Indian Rupee",
    "Euro",
    "Australian Dollar",
    "Japanese Yen",
    "Korean Won",
  ];


  final List<String> languages = [
    "English",
    "Russian",
    "Arabic",
    "Spanish",
    "Turkish",
    "German",
    "Armenian",
    "Italian",
    "Catalán",
    "Hindi",
    "Japanese",
    "French",
  ];
  String? selectedLengthClass;

  final List<String> lengthClassOptions = [
    "Centimeter",
    "Millimeter",
    "Inch",
  ];

  String? selectedWeightClass;

  final List<String> weightClassOptions = [
    "Kilogram",
    "Gram",
    "Pound",
    "Ounce",
  ];
  String? selectedOption = "Yes";
  String allowReviews = "Yes";
  String allowGuestReviews = "No";
  String? selectedTexOption = "Yes";


  String? selectedCity;

  final Map<String, List<Map<String, dynamic>>> groupedCities = {
    "UK": [
      {"name": "London", "enabled": true},
      {"name": "Manchester", "enabled": true},
      {"name": "Liverpool", "enabled": true},
    ],
    "FR": [
      {"name": "Paris", "enabled": true},
      {"name": "Lyon", "enabled": true},
      {"name": "Marseille", "enabled": true},
    ],
    "DE": [
      {"name": "Hamburg", "enabled": true},
      {"name": "Munich", "enabled": true},
      {"name": "Berlin", "enabled": true},
    ],
    "US": [
      {"name": "New York", "enabled": true},
      {"name": "Washington", "enabled": false},
      {"name": "Michigan", "enabled": true},
    ],
    "SP": [
      {"name": "Madrid", "enabled": true},
      {"name": "Barcelona", "enabled": true},
      {"name": "Malaga", "enabled": true},
    ],
    "CA": [
      {"name": "Montreal", "enabled": true},
      {"name": "Toronto", "enabled": true},
      {"name": "Vancouver", "enabled": true},
    ],
  };

}