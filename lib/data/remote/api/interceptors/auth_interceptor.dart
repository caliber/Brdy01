import 'package:dio/dio.dart';
import '../../../../app/constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConstants.golfApiKey.isEmpty) {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        message: 'API_KEY_MISSING',
      ));
      return;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: DioExceptionType.badResponse,
        message: 'API_KEY_INVALID',
      ));
      return;
    }
    handler.next(err);
  }
}
