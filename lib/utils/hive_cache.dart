/// Global cache for theme values
class HiveCache {
  HiveCache._();

  static Map<String, Map<String, String>>? cachedHiveData;
  static String? cachedSelectedKey;

  static bool hasCache() {
    return cachedHiveData != null && cachedSelectedKey != null;
  }

  static void updateCache(
    Map<String, Map<String, String>> hiveData,
    String selectedKey,
  ) {
    cachedHiveData = hiveData;
    cachedSelectedKey = selectedKey;
  }
}
