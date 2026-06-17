import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../food_entry/domain/nutrition_models.dart';
import '../../mock_data.dart';

class FoodsRepository {
  const FoodsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PublicFood>> search(String query) async {
    final trimmedQuery = query.trim();
    if (AppConfig.useMockData) {
      return MockData.foods
          .where(
            (food) =>
                trimmedQuery.isEmpty ||
                food.name.toLowerCase().contains(trimmedQuery.toLowerCase()) ||
                food.aliases.any(
                  (alias) => alias.contains(trimmedQuery.toLowerCase()),
                ),
          )
          .toList();
    }
    final queryParameters = trimmedQuery.isEmpty ? null : {'q': trimmedQuery};
    final json = await _apiClient.getJson(
      ApiEndpoints.searchFood,
      queryParameters: queryParameters,
    );
    return (json['items'] as List)
        .map((item) => PublicFood.fromJson(item))
        .toList();
  }
}
