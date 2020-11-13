class RecipeIngredient {
  int recipeId;
  String recipeName;

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