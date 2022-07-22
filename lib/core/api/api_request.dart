import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../values/app_config.dart';
import '../values/app_constants.dart';

class ApiRequest {
  final String url;
  final Map<String, dynamic>? data;

  ApiRequest({
    required this.url,
    this.data,
  });

  Future<Dio> _dio() async {
    BaseOptions options = BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: 10 * 1000,
        receiveTimeout: 10 * 1000);

    return Dio(options);
  }

  void get({
    required Function() beforeSend,
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
  }) async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken(false);

    Options _cacheOptions = buildCacheOptions(
      const Duration(days: 7),
      forceRefresh: true,
      maxStale: const Duration(days: 10),
    );

    await _dio().then((dio) async {
      dio.options.headers["authorization"] = "Bearer $token";
      dio.options.headers["User-Agent"] = "Other";
      dio.interceptors.add(
          DioCacheManager(CacheConfig(baseUrl: AppConfig.baseUrl)).interceptor);

      try {
        Response response = await dio.get(AppConstants.storiesEndpointPath,
            queryParameters: data, options: _cacheOptions);

        if (onSuccess != null) onSuccess(response.data);

      } on DioError catch (e) {

        if (e.response!.statusCode == 403) {
          /// If the response status code is 403, that means the firebase token is expired
          /// generate a new token
          token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
          dio.options.headers["authorization"] = "Bearer $token";

          /// request again with the new token
          Response response = await dio.get(AppConstants.storiesEndpointPath,
              queryParameters: data, options: _cacheOptions);

          /// return the response
          if (onSuccess != null) onSuccess(response.data);
        } else {
          if (onError != null) onError(e.message);
        }
      }
    });
  }
}
