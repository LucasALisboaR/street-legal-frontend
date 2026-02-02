/// Endpoints da API
/// 
/// Centraliza todas as URLs dos endpoints da aplicação
class ApiEndpoints {
  ApiEndpoints._();

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // ═══════════════════════════════════════════════════════════════════════════
  // USER
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String profile = '/user/profile';
  static String userProfile(String userId) => '/user/$userId';
  static const String updateProfile = '/user/profile';
  static const String uploadAvatar = '/user/avatar';

  // Street Legal API - Users
  static const String users = '/users';
  static const String usersSync = '/users/sync';
  static String userById(String userId) => '/users/$userId';
  static String usersByCrew(String crewId) => '/users/crew/$crewId';

  // ═══════════════════════════════════════════════════════════════════════════
  // GARAGE
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String vehicles = '/garage/vehicles';
  static String vehicle(String vehicleId) => '/garage/vehicles/$vehicleId';
  static String updateVehicle(String vehicleId) => '/garage/vehicles/$vehicleId';
  static String deleteVehicle(String vehicleId) => '/garage/vehicles/$vehicleId';

  // Street Legal API - Garage
  static String garageByUser(String userId) => '/garage/$userId';
  static String garageVehicle(String userId, String carId) =>
      '/garage/$userId/$carId';

  // ═══════════════════════════════════════════════════════════════════════════
  // CREW
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String crews = '/crew';
  static String crew(String crewId) => '/crew/$crewId';
  static String joinCrew(String crewId) => '/crew/$crewId/join';
  static String leaveCrew(String crewId) => '/crew/$crewId/leave';
  static String crewMembers(String crewId) => '/crew/$crewId/members';

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String events = '/events';
  static String event(String eventId) => '/events/$eventId';
  static String joinEvent(String eventId) => '/events/$eventId/join';
  static String leaveEvent(String eventId) => '/events/$eventId/leave';
  static String eventAttendees(String eventId) => '/events/$eventId/attendees';

  // ═══════════════════════════════════════════════════════════════════════════
  // MOMENTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String moments = '/moments';
  static String moment(String momentId) => '/moments/$momentId';
  static String likeMoment(String momentId) => '/moments/$momentId/like';
  static String unlikeMoment(String momentId) => '/moments/$momentId/unlike';
  static String momentComments(String momentId) => '/moments/$momentId/comments';
  static String addComment(String momentId) => '/moments/$momentId/comments';

  // ═══════════════════════════════════════════════════════════════════════════
  // MAP
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String locations = '/map/locations';
  static String nearbyLocations = '/map/locations/nearby';
  static String userLocation = '/map/location';
}
