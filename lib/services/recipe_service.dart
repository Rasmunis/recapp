import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:recapp/models/recipe.dart';

Future<Recipe> fetchRecipeWithId(String id) async {
  final response = await http.get("https://recapi.azurewebsites.net/api/Recipes/$id");

  if (response.statusCode == 200) {
    Map<String, dynamic> ingredientsJson = json.decode(response.body);
    Recipe recipe = Recipe.fromJson(ingredientsJson);

    return recipe;
  }
  else {
    throw Exception("Failed to load recipe");
  }
}