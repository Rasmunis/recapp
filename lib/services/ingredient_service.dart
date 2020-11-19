import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:recapp/models/ingredient.dart';

Future<List<Ingredient>> fetchIngredientsContaining(String nameSubstring) async {
  final response = await http.get("https://recapi.azurewebsites.net/api/Ingredients/search?query=$nameSubstring");

  if (response.statusCode == 200) {
    List<dynamic> ingredientsJson = json.decode(response.body);
    List<Ingredient> ingredients = [];

    ingredientsJson.forEach((value) {
      ingredients.add(Ingredient.fromJson(value));
    });

    return ingredients;
  }
  else {
    throw Exception("Failed to load ingredient");
  }
}