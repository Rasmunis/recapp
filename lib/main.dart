import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:recapp/components/ingredient_search_results.dart';
import 'package:recapp/services/ingredient_service.dart';

import 'models/ingredient.dart';

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
      home: MyHomePage(title: "Rasmus' Kokebok"),
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
  Map<String, dynamic> _ingredientsAndRecipes = {};

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
            IngredientSearchResults(ingredientsAndRecipes: _ingredientsAndRecipes)
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
          _ingredientsAndRecipes[ingredient.name] = recipeIngredients;
        });
      });
    } else {
      List<Ingredient> selectionDifference = _previouslySelectedIngredients.toSet().difference(_selectedIngredients.toSet()).toList();
      selectionDifference.forEach((ingredient) {
        setState(() {
          _ingredientsAndRecipes.remove(ingredient.name);
        });
      });
    }
    _previouslySelectedIngredients = new List<Ingredient>.from(_selectedIngredients);
  }
}