class Recipe {
  int id;
  String name;
  String description;
  String instructions;

  Recipe({
    this.id,
    this.name,
    this.description,
    this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
    );
  }
}