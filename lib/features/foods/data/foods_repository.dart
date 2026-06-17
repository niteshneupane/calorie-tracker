import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../food_entry/domain/nutrition_models.dart';
import '../../mock_data.dart';

class FoodsRepository {
  const FoodsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PublicFood>> search(String query) async {
    if (AppConfig.useMockData || query.trim().isEmpty) {
      return MockData.foods
          .where(
            (food) =>
                query.trim().isEmpty ||
                food.name.toLowerCase().contains(query.toLowerCase()) ||
                food.aliases.any(
                  (alias) => alias.contains(query.toLowerCase()),
                ),
          )
          .toList();
    }
    final json = await _apiClient.getJson(
      ApiEndpoints.searchFood,
      queryParameters: {'q': query},
    );
    return (json['items'] as List)
        .map((item) => PublicFood.fromJson(item))
        .toList();
  }
}
