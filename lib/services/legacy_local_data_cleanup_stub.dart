/// No-op legacy cleanup for platforms without a local file system.
library;

/// Removes obsolete local training data when the platform supports files.
Future<bool> deleteLegacyLocalData() async => true;
