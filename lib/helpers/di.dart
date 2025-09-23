//import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

final locator = GetIt.instance;
// final appData = locator.get<GetStorage>();

/// Lazy getter for global access
GetStorage get appData => locator.get<GetStorage>();
List<CameraDescription> get cameras => locator.get<List<CameraDescription>>();
CameraDescription get myFrontCamera => cameras.firstWhere((c) {
  return c.lensDirection == CameraLensDirection.front;
});

Future<void> diSetup() async {
  // locator.registerSingleton<GetStorage>(GetStorage());
  // locator.registerSingleton<WebViewController>(WebViewController());
  // locator.registerSingleton<GenericDi>(GenericDi());

  await _diSetupSync();
  await _diSetupAsync();
}

// ///-------------------SyncFunction-----------------
Future<void> _diSetupSync() async {
  if (!locator.isRegistered<GetStorage>()) {
    await GetStorage.init();
    locator.registerSingleton<GetStorage>(GetStorage());
  }
}

// ///-------------------AsyncFunction----------------
Future<void> _diSetupAsync() async {
  if (!locator.isRegistered<List<CameraDescription>>()) {
    final cameras = await availableCameras();
    locator.registerSingleton<List<CameraDescription>>(cameras);
  }
}
