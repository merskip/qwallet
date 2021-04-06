import 'RemoteUserPreferences.dart';

abstract class RemoteUserPreferencesProvider {
  Stream<RemoteUserPreferences> getUserPreferences();
}
