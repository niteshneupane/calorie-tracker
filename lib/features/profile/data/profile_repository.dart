import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../food_entry/domain/nutrition_models.dart';
import '../../mock_data.dart';

class ProfileRepository {
  const ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile() async {
    if (AppConfig.useMockData) return MockData.user;
    return UserProfile.fromJson(await _apiClient.getJson(ApiEndpoints.profile));
  }

  Future<UserProfile> saveProfile(UserProfile profile) async {
    if (AppConfig.useMockData) return profile;
    return UserProfile.fromJson(
      await _apiClient.putJson(ApiEndpoints.profile, data: profile.toJson()),
    );
  }
}
