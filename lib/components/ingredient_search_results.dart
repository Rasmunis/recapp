import 'package:flutter/material.dart';


class IngredientSearchResults extends StatelessWidget {
  final Map<String, dynamic> ingredientsAndRecipes;

  IngredientSearchResults({Key key, @required this.ingredientsAndRecipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ListItem> flattenedList = flattenIngredientsAndRecipesMap(ingredientsAndRecipes);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: flattenedList.length,
      itemBuilder: (context, index) {
        final item = flattenedList[index];
        return ListTile(
          title: item.buildTitle(context),
        );
      }
    );
  }
}


abstract class ListItem {
  Widget buildTitle(BuildContext context);
}


class IngredientsHeader implements ListItem {
  final String header;

  IngredientsHeader(this.header);

  Widget buildTitle(BuildContext context) {
    return Text(
      header,
      style: Theme.of(context).textTheme.headline5,
    );
  }
}


class RecipeItem implements ListItem {
  final String name;

  RecipeItem(this.name);

  Widget buildTitle(BuildContext context) => Text(name);
}


List<ListItem> flattenIngredientsAndRecipesMap(Map<String, dynamic> ingredientsAndRecipes) {
  List<ListItem> flattenedList = [];

  ingredientsAndRecipes.keys.forEach((ingredientsHeader) {
    flattenedList.add(IngredientsHeader(ingredientsHeader));
    ingredientsAndRecipes[ingredientsHeader].forEach((recipe) {
      flattenedList.add(RecipeItem(recipe.recipeName));
    });
  });

  return flattenedList;
}