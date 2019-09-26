import 'package:flutter/services.dart';
import 'package:flutter_appauth/src/mappable.dart';
import 'package:meta/meta.dart';
import 'authorization_request.dart';
import 'authorization_response.dart';
import 'authorization_token_request.dart';
import 'authorization_token_response.dart';
import 'token_request.dart';
import 'token_response.dart';

import 'package:flutter/foundation.dart' as Foundation;

class FlutterAppAuth {
  factory FlutterAppAuth() => _instance;

  final MethodChannel _channel;

  @visibleForTesting
  FlutterAppAuth.private(MethodChannel channel) : _channel = channel;

  static final FlutterAppAuth _instance = new FlutterAppAuth.private(
      const MethodChannel('crossingthestreams.io/flutter_appauth'));

  Map<String, dynamic> buildArguments(Mappable request) {
    const isDebugMode = !Foundation.kReleaseMode;
    final map = request.toMap();
    map.putIfAbsent('isDebug', () => isDebugMode);
    return map;
  }

  /// Convenience method for authorizing and then exchanges code
  Future<AuthorizationTokenResponse> authorizeAndExchangeCode(
      AuthorizationTokenRequest request) async {
    var result = await _channel.invokeMethod(
        'authorizeAndExchangeCode', buildArguments(request));
    return AuthorizationTokenResponse(
        result['accessToken'],
        result['refreshToken'],
        result['accessTokenExpirationTime'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                result['accessTokenExpirationTime'].toInt()),
        result['idToken'],
        result['tokenType'],
        result['authorizationAdditionalParameters']?.cast<String, dynamic>(),
        result['tokenAdditionalParameters']?.cast<String, dynamic>());
  }

  Future<AuthorizationResponse> authorize(AuthorizationRequest request) async {
    var result = await _channel.invokeMethod('authorize', buildArguments(request));
    return AuthorizationResponse(
        result['authorizationCode'],
        result['codeVerifier'],
        result['authorizationAdditionalParameters']?.cast<String, dynamic>());
  }

  /// For exchanging tokens
  Future<TokenResponse> token(TokenRequest request) async {
    var result = await _channel.invokeMethod('token', buildArguments(request));
    return TokenResponse(
        result['accessToken'],
        result['refreshToken'],
        result['accessTokenExpirationTime'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                result['accessTokenExpirationTime'].toInt()),
        result['idToken'],
        result['tokenType'],
        result['tokenAdditionalParameters']?.cast<String, String>());
  }
}
