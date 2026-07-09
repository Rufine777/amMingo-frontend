import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static final CookieJar _cookieJar = CookieJar();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "$baseUrl/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  AuthService() {
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  static const String baseUrl = "http://localhost:8000";

  Future<void> sendOtp(String email) async {
    await _dio.post("/login/email", data: {"email": email});
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "access_token", value: token);
  }

  static Future<void> saveUserCode(String code) async {
    await _storage.write(key: "user_code", value: code);
  }

  static Future<String?> getUserCode() async {
    return await _storage.read(key: "user_code");
  }

  Future<void> resendOtp(String email) async {
    await sendOtp(email);
  }

  Future<Response> verifyOtp(String email, String otp) async {
    final response = await _dio.post(
      "/login/verify-otp",
      data: {"email": email, "otp": otp},
    );
    return response;
  }

  Future<Response> joinGame(String code) async {
    final token = await _storage.read(key: "access_token");
    _dio.options.headers["Cookie"] = "access_token=$token";
    return await _dio.post("/games/join/$code", data: {});
  }

  Future<Response> getLobby(String code) async {
    return await _dio.get("/games/$code/lobby");
  }

  Future<Response> getGameDetails(String code) async {
    return await _dio.get("/games/$code");
  }

  Future<Response> getProfile(int id) async {
    final token = await _storage.read(key: "access_token");
    _dio.options.headers["Cookie"] = "access_token=$token";
    return await _dio.get("/profile/$id");
  }

  Future<Response> updateProfile({String? name, String? username}) async {
    final token = await _storage.read(key: "access_token");
    _dio.options.headers["Cookie"] = "access_token=$token";
    final data = <String, dynamic>{};
    if (name != null) data["name"] = name;
    if (username != null) data["username"] = username;
    return await _dio.patch("/profile/me", data: data);
  }

  Future<Response> uploadProfileImage(String path) async {
    final token = await _storage.read(key: "access_token");
    _dio.options.headers["Cookie"] = "access_token=$token";
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(path),
    });
    return await _dio.post("/profile/upload", data: formData);
  }

  Future<void> logout() async {
    await _storage.delete(key: "access_token");
    await _storage.delete(key: "user_code");
    _cookieJar.deleteAll();
  }

  Future<String?> signInWithGoogle() async {
    final result = await FlutterWebAuth2.authenticate(
      url: "$baseUrl/api/login/oauth",
      callbackUrlScheme: "amingo",
      options: const FlutterWebAuth2Options(preferEphemeral: false),
    );
    return Uri.parse(result).queryParameters["token"];
  }

  void setAuthToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  Future<Response> createGame({
    required String description,
    required String location,
    required int duration,
  }) async {
    final token = await _storage.read(key: "access_token");

    _dio.options.headers["Cookie"] = "access_token=$token";

    return await _dio.post(
      "/games",
      data: {
        "description": description,
        "location": location,
        "duration": duration,
      },
    );
  }

  Future<Response> startGame({required String code, required int size}) async {
    final token = await _storage.read(key: "access_token");
    _dio.options.headers["Cookie"] = "access_token=$token";

    try {
      return await _dio.post("/games/$code/start", data: {"size": size});
    } on DioException catch (e) {
      debugPrint("STATUS: ${e.response?.statusCode}");
      debugPrint("BODY: ${e.response?.data}");
      debugPrint("URI: ${e.requestOptions.uri}");
      rethrow;
    }
  }

  Future<Response> getBoard(String code) async {
    final token = await _storage.read(key: "access_token");
    _dio.options.headers["Cookie"] = "access_token=$token";

    return await _dio.get("/games/$code/board/");
  }

  Future<Response> getGameStatus(String code) async {
    return await _dio.get("/games/$code/status");
  }

  Future<Response> getLeaderboard(String code) async {
    return await _dio.get("/games/$code/leaderboard");
  }

  Future<Response> submitTile({
    required int bingoId,
    required int row,
    required int col,
    required String friendName,
    required String friendCode,
    required String fact,
    required dynamic image, // File or XFile
  }) async {
    final token = await _storage.read(key: "access_token");
    _dio.options.headers["Cookie"] = "access_token=$token";

    final formData = FormData.fromMap({
      "bingo_id": bingoId,
      "row": row,
      "col": col,
      "friend_name": friendName,
      "friend_code": friendCode,
      "fact": fact,
      "image": await MultipartFile.fromFile(image.path),
    });

    return await _dio.post("/games/tile-submit", data: formData);
  }
}
