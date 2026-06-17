enum MealType {
  breakfast,
  lunch,
  snack,
  dinner,
  other;

  String get label => name[0].toUpperCase() + name.substring(1);
}

class NutritionValues {
  const NutritionValues({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.sodiumMg,
    required this.calciumMg,
    required this.ironMg,
    required this.potassiumMg,
    this.vitaminAMcg = 0,
    this.vitaminCMg = 0,
    this.vitaminB12Mcg = 0,
  });

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;
  final double calciumMg;
  final double ironMg;
  final double potassiumMg;
  final double vitaminAMcg;
  final double vitaminCMg;
  final double vitaminB12Mcg;

  factory NutritionValues.fromJson(Map<String, dynamic> json) =>
      NutritionValues(
        calories: _double(json['calories']),
        proteinG: _double(json['proteinG']),
        carbsG: _double(json['carbsG']),
        fatG: _double(json['fatG']),
        fiberG: _double(json['fiberG']),
        sugarG: _double(json['sugarG']),
        sodiumMg: _double(json['sodiumMg']),
        calciumMg: _double(json['calciumMg']),
        ironMg: _double(json['ironMg']),
        potassiumMg: _double(json['potassiumMg']),
        vitaminAMcg: _double(json['vitaminAMcg']),
        vitaminCMg: _double(json['vitaminCMg']),
        vitaminB12Mcg: _double(json['vitaminB12Mcg']),
      );

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'fiberG': fiberG,
    'sugarG': sugarG,
    'sodiumMg': sodiumMg,
    'calciumMg': calciumMg,
    'ironMg': ironMg,
    'potassiumMg': potassiumMg,
    'vitaminAMcg': vitaminAMcg,
    'vitaminCMg': vitaminCMg,
    'vitaminB12Mcg': vitaminB12Mcg,
  };
}

class ParsedFoodItem {
  const ParsedFoodItem({
    required this.rawText,
    required this.canonicalName,
    required this.quantity,
    required this.unit,
    required this.estimatedGrams,
    required this.estimatedMl,
    required this.confidence,
    required this.possibleVariants,
  });

  final String rawText;
  final String canonicalName;
  final double quantity;
  final String unit;
  final double? estimatedGrams;
  final double? estimatedMl;
  final double confidence;
  final List<String> possibleVariants;

  factory ParsedFoodItem.fromJson(Map<String, dynamic> json) => ParsedFoodItem(
    rawText: json['rawText'] as String,
    canonicalName: json['canonicalName'] as String,
    quantity: _double(json['quantity']),
    unit: json['unit'] as String,
    estimatedGrams: _nullableDouble(json['estimatedGrams']),
    estimatedMl: _nullableDouble(json['estimatedMl']),
    confidence: _double(json['confidence']),
    possibleVariants: List<String>.from(json['possibleVariants'] as List),
  );
}

class NutritionPreviewItem extends NutritionValues {
  const NutritionPreviewItem({
    required super.calories,
    required super.proteinG,
    required super.carbsG,
    required super.fatG,
    required super.fiberG,
    required super.sugarG,
    required super.sodiumMg,
    required super.calciumMg,
    required super.ironMg,
    required super.potassiumMg,
    required this.foodId,
    required this.name,
    required this.inputName,
    required this.grams,
    required this.confidence,
    required this.isEstimate,
    required this.needsManualSelection,
  });

  final String? foodId;
  final String? name;
  final String inputName;
  final double? grams;
  final double confidence;
  final bool isEstimate;
  final bool needsManualSelection;

  factory NutritionPreviewItem.fromJson(Map<String, dynamic> json) =>
      NutritionPreviewItem(
        calories: _double(json['calories']),
        proteinG: _double(json['proteinG']),
        carbsG: _double(json['carbsG']),
        fatG: _double(json['fatG']),
        fiberG: _double(json['fiberG']),
        sugarG: _double(json['sugarG']),
        sodiumMg: _double(json['sodiumMg']),
        calciumMg: _double(json['calciumMg']),
        ironMg: _double(json['ironMg']),
        potassiumMg: _double(json['potassiumMg']),
        foodId: json['foodId'] as String?,
        name: json['name'] as String?,
        inputName: json['inputName'] as String,
        grams: _nullableDouble(json['grams']),
        confidence: _double(json['confidence']),
        isEstimate: json['isEstimate'] as bool,
        needsManualSelection: json['needsManualSelection'] as bool,
      );

  Map<String, dynamic> toSaveJson({
    required String foodName,
    required double quantity,
    required String unit,
  }) => {
    ...toJson(),
    'foodId': foodId,
    'foodName': foodName,
    'quantity': quantity,
    'unit': unit,
    'grams': grams ?? 0,
    'isEstimate': isEstimate,
    'confidence': confidence,
  };
}

class NutritionPreview {
  const NutritionPreview({required this.items, required this.total});

  final List<NutritionPreviewItem> items;
  final NutritionValues total;

  factory NutritionPreview.fromJson(Map<String, dynamic> json) =>
      NutritionPreview(
        items: (json['items'] as List)
            .map((item) => NutritionPreviewItem.fromJson(item))
            .toList(),
        total: NutritionValues.fromJson(json['total']),
      );
}

class PublicFood {
  const PublicFood({
    required this.id,
    required this.name,
    required this.aliases,
    required this.defaultServingName,
    required this.defaultServingGrams,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });

  final String id;
  final String name;
  final List<String> aliases;
  final String? defaultServingName;
  final double? defaultServingGrams;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  factory PublicFood.fromJson(Map<String, dynamic> json) => PublicFood(
    id: json['id'] as String,
    name: json['name'] as String,
    aliases: List<String>.from(json['aliases'] as List),
    defaultServingName: json['defaultServingName'] as String?,
    defaultServingGrams: _nullableDouble(json['defaultServingGrams']),
    caloriesPer100g: _double(json['caloriesPer100g']),
    proteinPer100g: _double(json['proteinPer100g']),
    carbsPer100g: _double(json['carbsPer100g']),
    fatPer100g: _double(json['fatPer100g']),
  );
}

class MealLog {
  const MealLog({
    required this.id,
    required this.date,
    required this.mealType,
    required this.items,
    this.notes,
  });

  final String id;
  final String date;
  final String mealType;
  final String? notes;
  final List<NutritionPreviewItem> items;

  double get calories =>
      items.fold(0, (previous, item) => previous + item.calories);

  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog(
    id: json['id'] as String,
    date: json['date'] as String,
    mealType: json['mealType'] as String,
    notes: json['notes'] as String?,
    items: (json['items'] as List)
        .map((item) => NutritionPreviewItem.fromJson(item))
        .toList(),
  );
}

class MacroGoal {
  const MacroGoal({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  factory MacroGoal.fromJson(Map<String, dynamic> json) => MacroGoal(
    calories: _double(json['calories']),
    proteinG: _double(json['proteinG']),
    carbsG: _double(json['carbsG']),
    fatG: _double(json['fatG']),
  );
}

class DailySummaryResponse {
  const DailySummaryResponse({
    required this.date,
    required this.goal,
    required this.consumed,
    required this.remaining,
  });

  final String date;
  final MacroGoal? goal;
  final NutritionValues consumed;
  final MacroGoal? remaining;

  factory DailySummaryResponse.fromJson(Map<String, dynamic> json) =>
      DailySummaryResponse(
        date: json['date'] as String,
        goal: json['goal'] == null ? null : MacroGoal.fromJson(json['goal']),
        consumed: NutritionValues.fromJson(json['consumed']),
        remaining: json['remaining'] == null
            ? null
            : MacroGoal.fromJson(json['remaining']),
      );
}

class UserProfile {
  const UserProfile({
    this.id,
    this.name,
    this.email,
    this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
    this.dailyCalorieGoal,
    this.proteinGoalG,
    this.carbsGoalG,
    this.fatGoalG,
  });

  final String? id;
  final String? name;
  final String? email;
  final double? age;
  final String? sex;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final String? goal;
  final double? dailyCalorieGoal;
  final double? proteinGoalG;
  final double? carbsGoalG;
  final double? fatGoalG;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String?,
    name: json['name'] as String?,
    email: json['email'] as String?,
    age: _nullableDouble(json['age']),
    sex: json['sex'] as String?,
    heightCm: _nullableDouble(json['heightCm']),
    weightKg: _nullableDouble(json['weightKg']),
    activityLevel: json['activityLevel'] as String?,
    goal: json['goal'] as String?,
    dailyCalorieGoal: _nullableDouble(json['dailyCalorieGoal']),
    proteinGoalG: _nullableDouble(json['proteinGoalG']),
    carbsGoalG: _nullableDouble(json['carbsGoalG']),
    fatGoalG: _nullableDouble(json['fatGoalG']),
  );

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (email != null) 'email': email,
    if (age != null) 'age': age,
    if (sex != null) 'sex': sex,
    if (heightCm != null) 'heightCm': heightCm,
    if (weightKg != null) 'weightKg': weightKg,
    if (activityLevel != null) 'activityLevel': activityLevel,
    if (goal != null) 'goal': goal,
    if (dailyCalorieGoal != null) 'dailyCalorieGoal': dailyCalorieGoal,
    if (proteinGoalG != null) 'proteinGoalG': proteinGoalG,
    if (carbsGoalG != null) 'carbsGoalG': carbsGoalG,
    if (fatGoalG != null) 'fatGoalG': fatGoalG,
  };
}

double _double(dynamic value) => value is num ? value.toDouble() : 0;
double? _nullableDouble(dynamic value) =>
    value is num ? value.toDouble() : null;
