import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';

const String _KEY = "fcmKey";

class RemoteConfigService {
  final RemoteConfig _remoteConfig;
  RemoteConfigService({RemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  final defaults = <String, dynamic>{
    _KEY: 1,
  };

  static RemoteConfigService _instance;
  static Future<RemoteConfigService> getInstance() async {
    if (_instance == null) {
      _instance = RemoteConfigService(
        remoteConfig: RemoteConfig.instance,
      );
    }
    return _instance;
  }

  Future initialize() async {
    try {
      await _remoteConfig.setDefaults(defaults);
      await _fetchAndActivate();
    } on PlatformException  catch (e) {
      print("Remote Config fetch throttled: $e");
    } catch (e) {
      print("Unable to fetch remote config. Default value will be used");
    }
  }

  Future _fetchAndActivate() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  String get getKey => _remoteConfig.getString(_KEY);

}