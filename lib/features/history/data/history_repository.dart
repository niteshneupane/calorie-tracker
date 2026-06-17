import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';

class HistoryDay {
  const HistoryDay({
    required this.date,
    required this.calories,
    required this.proteinG,
    required this.mealCount,
  });

  final String date;
  final double calories;
  final double proteinG;
  final int mealCount;

  factory HistoryDay.fromJson(Map<String, dynamic> json) => HistoryDay(
    date: json['date'] as String,
    calories: (json['calories'] as num?)?.toDouble() ?? 0,
    proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
    mealCount: (json['mealCount'] as num?)?.toInt() ?? 0,
  );
}

class HistoryData {
  const HistoryData({
    required this.from,
    required this.to,
    required this.items,
  });

  final String from;
  final String to;
  final List<HistoryDay> items;

  factory HistoryData.fromJson(Map<String, dynamic> json) => HistoryData(
    from: json['from'] as String,
    to: json['to'] as String,
    items: (json['items'] as List)
        .map((item) => HistoryDay.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class HistoryRepository {
  const HistoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<HistoryData> load({required String from, required String to}) async {
    if (AppConfig.useMockData) {
      return HistoryData(
        from: from,
        to: to,
        items: List.generate(
          7,
          (index) => HistoryDay(
            date: DateTime.now()
                .subtract(Duration(days: index))
                .toIso8601String()
                .slice(0, 10),
            calories: 1450 - index * 80,
            proteinG: 62 - index * 3,
            mealCount: index == 6 ? 0 : 3,
          ),
        ),
      );
    }

    final json = await _apiClient.getJson(
      '/api/history',
      queryParameters: {'from': from, 'to': to},
    );
    return HistoryData.fromJson(json);
  }
}

extension on String {
  String slice(int start, int end) => substring(start, end);
}
