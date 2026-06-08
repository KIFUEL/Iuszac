// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';

bool get isWebSupported => true;

void init(Function(bool) onInstallableChanged) {
  js.context['onAppInstallable'] = (bool installable) {
    onInstallableChanged(installable);
  };
}

bool isInstallable() {
  if (js.context.hasProperty('isAppInstallable')) {
    try {
      return js.context.callMethod('isAppInstallable') as bool;
    } catch (_) {
      return false;
    }
  }
  return false;
}

Future<bool> triggerInstall() async {
  if (js.context.hasProperty('installAppWithCallback')) {
    final completer = Completer<bool>();
    
    js.context['onInstallComplete'] = (bool success) {
      if (!completer.isCompleted) {
        completer.complete(success);
      }
    };

    try {
      js.context.callMethod('installAppWithCallback');
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    
    return completer.future;
  }
  return false;
}
