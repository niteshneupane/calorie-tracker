import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../food_entry/domain/nutrition_models.dart';
import '../../mock_data.dart';

class MealRepository {
  const MealRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<String> saveMeal({
    required String date,
    required MealType mealType,
    required List<NutritionPreviewItem> items,
  }) async {
    if (AppConfig.useMockData) return 'meal_mock_saved';
    final json = await _apiClient.postJson(
      ApiEndpoints.meals,
      data: {
        'date': date,
        'mealType': mealType.name,
        'items': items
            .map(
              (item) => item.toSaveJson(
                foodName: item.name ?? item.inputName,
                quantity: 1,
                unit: 'plate',
              ),
            )
            .toList(),
      },
    );
    return json['mealId'] as String;
  }

  Future<List<MealLog>> mealsForDate(String date) async {
    if (AppConfig.useMockData) return MockData.meals;
    final json = await _apiClient.getJson(
      ApiEndpoints.meals,
      queryParameters: {'date': date},
    );
    return (json['items'] as List)
        .map((item) => MealLog.fromJson(item))
        .toList();
  }

  Future<void> deleteMeal(String id, String date) async {
    if (AppConfig.useMockData) return;
    await _apiClient.deleteJson(
      ApiEndpoints.meal(id),
      queryParameters: {'date': date},
    );
  }
}
