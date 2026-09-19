/// Deletes IndexedDB databases created by older web builds.
library;

import 'dart:async';
import 'dart:js_interop';

@JS('indexedDB.deleteDatabase')
external _DeleteDatabaseRequest _deleteDatabase(JSString name);

extension type _DeleteDatabaseRequest(JSObject _) implements JSObject {
  external set onsuccess(JSFunction callback);
  external set onerror(JSFunction callback);
  external set onblocked(JSFunction callback);
}

const _deleteTimeout = Duration(seconds: 3);

/// Deletes known obsolete Drift databases and awaits both requests.
Future<bool> deleteLegacyLocalData() async {
  final results = await Future.wait(
    const ['poker_lab', 'poker_profile'].map(_deleteIndexedDatabase),
  );
  return results.every((succeeded) => succeeded);
}

Future<bool> _deleteIndexedDatabase(String name) async {
  Timer? timeout;
  try {
    final request = _deleteDatabase(name.toJS);
    final result = Completer<bool>();

    void complete(bool succeeded) {
      if (result.isCompleted) return;
      timeout?.cancel();
      result.complete(succeeded);
    }

    timeout = Timer(_deleteTimeout, () => complete(false));
    request.onsuccess = ((JSAny? _) => complete(true)).toJS;
    request.onerror = ((JSAny? _) => complete(false)).toJS;
    request.onblocked = ((JSAny? _) => complete(false)).toJS;
    return await result.future;
  } on Object {
    timeout?.cancel();
    return false;
  }
}
