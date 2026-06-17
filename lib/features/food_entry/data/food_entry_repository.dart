import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../mock_data.dart';
import '../domain/nutrition_models.dart';

class FoodEntryRepository {
  const FoodEntryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ParsedFoodItem>> parseFood(String text) async {
    if (AppConfig.useMockData) {
      if (text.trim().toLowerCase() == 'normal lunch') return [];
      return [
        ParsedFoodItem(
          rawText: text,
          canonicalName: text.contains('dal')
              ? 'dal bhat'
              : 'vegetable chowmein',
          quantity: 1,
          unit: text.contains('dal') ? 'thali' : 'plate',
          estimatedGrams: text.contains('dal') ? 520 : 350,
          estimatedMl: null,
          confidence: text.length < 6 ? 0.35 : 0.72,
          possibleVariants: const [
            'vegetable chowmein',
            'chicken chowmein',
            'egg chowmein',
          ],
        ),
      ];
    }
    final json = await _apiClient.postJson(
      ApiEndpoints.parseFood,
      data: {'text': text, 'locale': 'ne-NP'},
    );
    return (json['items'] as List)
        .map((item) => ParsedFoodItem.fromJson(item))
        .toList();
  }

  Future<NutritionPreview> preview(List<ParsedFoodItem> items) async {
    if (AppConfig.useMockData) {
      return const NutritionPreview(
        items: [MockData.previewItem],
        total: MockData.previewItem,
      );
    }
    final json = await _apiClient.postJson(
      ApiEndpoints.previewFood,
      data: {
        'items': items
            .map(
              (item) => {
                'canonicalName': item.canonicalName,
                'quantity': item.quantity,
                'unit': item.unit,
                if (item.estimatedGrams != null) 'grams': item.estimatedGrams,
              },
            )
            .toList(),
      },
    );
    return NutritionPreview.fromJson(json);
  }
}
