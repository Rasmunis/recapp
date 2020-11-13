import 'package:flutter_tagging/flutter_tagging.dart';
import 'recipeIngredient.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Ingredient extends Taggable {
  final int id;
  final String name;

  Ingredient({
    this.id,
    this.name,
  });

  @override
  List<Object> get props => [name];

  Future<List<RecipeIngredient>> fetchRecipes() async {
    final response = await http.get("https://recapi.azurewebsites.net/api/Ingredients/${this.id}/recipes");

    if (response.statusCode == 200) {
      List<dynamic> recipeIngredientsJson = json.decode(response.body);
      List<RecipeIngredient> recipeIngredients = [];

      recipeIngredientsJson.forEach((value) {
        recipeIngredients.add(RecipeIngredient.fromJson(value));
      });

      return recipeIngredients;
    }
    else {
      throw Exception("Failed to load recipes of ${this.name}");
    }
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
    );
  }
}