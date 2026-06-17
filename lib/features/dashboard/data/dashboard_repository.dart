import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../food_entry/domain/nutrition_models.dart';
import '../../mock_data.dart';

class DashboardData {
  const DashboardData({required this.summary, required this.meals});

  final DailySummaryResponse summary;
  final List<MealLog> meals;
}

class DashboardRepository {
  const DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardData> load(String date) async {
    if (AppConfig.useMockData) {
      return DashboardData(
        summary: DailySummaryResponse(
          date: date,
          goal: MockData.goal,
          consumed: MockData.consumed,
          remaining: MockData.remaining,
        ),
        meals: MockData.meals,
      );
    }
    final summaryJson = await _apiClient.getJson(
      ApiEndpoints.dailySummary,
      queryParameters: {'date': date},
    );
    final mealsJson = await _apiClient.getJson(
      ApiEndpoints.meals,
      queryParameters: {'date': date},
    );
    return DashboardData(
      summary: DailySummaryResponse.fromJson(summaryJson),
      meals: (mealsJson['items'] as List)
          .map((item) => MealLog.fromJson(item))
          .toList(),
    );
  }
}
