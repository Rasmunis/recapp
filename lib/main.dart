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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

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
            Text(
              'You have pressed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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
