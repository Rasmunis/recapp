import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: "Rasmus' Cookbook"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Ingredient> _selectedIngredients = [];
  List<Ingredient> _previouslySelectedIngredients = [];
  Map<String, dynamic> _recipes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlutterTagging(
                initialItems: _selectedIngredients,
                findSuggestions: fetchIngredientsContaining,
                configureChip: (ingredient) {
                  return ChipConfiguration(
                    label: Text(ingredient.name),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                    deleteIconColor: Colors.white
                  );
                },
                configureSuggestion: (ingredient) {
                  return SuggestionConfiguration(title: Text(ingredient.name));
                },
                onChanged: () {
                  selectedIngredientsChanged();
                },
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.blue.withAlpha(30),
                    hintText: 'Søk etter ingredienser...',
                    labelText: 'Ingredienssøk'
                  )
                ),
              )
            ),
            ListView.separated(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: _recipes.length,
              itemBuilder: (BuildContext context, int index) {
                String ingredientName = _recipes.keys.elementAt(index);
                return Container(
                    child: Column(
                      children: <Widget>[
                        Text(
                            ingredientName,
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _recipes[ingredientName].length,
                            itemBuilder: (BuildContext context, int index) {
                              return Text(_recipes[ingredientName][index].recipeName);
                            }
                        ),
                      ],
                    )
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            )
          ],
        ),
    );
  }

  void selectedIngredientsChanged() {
    if (_selectedIngredients.length > _previouslySelectedIngredients.length) {
      List<Ingredient> selectionDifference = _selectedIngredients.toSet().difference(_previouslySelectedIngredients.toSet()).toList();
      selectionDifference.forEach((ingredient) async {
        final recipeIngredients = await ingredient.fetchRecipes();
        setState(() {
          _recipes[ingredient.name] = recipeIngredients;
        });
      });
    } else {
      List<Ingredient> selectionDifference = _previouslySelectedIngredients.toSet().difference(_selectedIngredients.toSet()).toList();
      selectionDifference.forEach((ingredient) {
        setState(() {
          _recipes.remove(ingredient.name);
        });
      });
    }
    _previouslySelectedIngredients = new List<Ingredient>.from(_selectedIngredients);
  }
}

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

class RecipeIngredient {
  final int recipeId;
  final String recipeName;

  RecipeIngredient({
    this.recipeId,
    this.recipeName,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      recipeId: json['recipeId'],
      recipeName: json['recipeName']
    );
  }
}
