class ApiEndpoints {
  static const health = '/';
  static const parseFood = '/api/food/parse';
  static const previewFood = '/api/food/preview';
  static const searchFood = '/api/food/search';
  static const meals = '/api/meals';
  static const dailySummary = '/api/daily-summary';
  static const profile = '/api/profile';

  static String meal(String id) => '/api/meals/$id';
}
