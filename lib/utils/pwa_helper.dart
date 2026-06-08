import 'pwa_helper_stub.dart'
    if (dart.library.js) 'pwa_helper_web.dart' as impl;

class PwaHelper {
  static bool get isWebSupported => impl.isWebSupported;
  
  static void init(Function(bool) onInstallableChanged) {
    impl.init(onInstallableChanged);
  }

  static bool isInstallable() {
    return impl.isInstallable();
  }

  static Future<bool> triggerInstall() {
    return impl.triggerInstall();
  }
}
