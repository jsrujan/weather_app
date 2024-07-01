import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  Future<void> saveRecentSearch(String cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentSearches = prefs.getStringList('recentSearches') ?? [];

    if (recentSearches.contains(cityName)) {
      recentSearches.remove(cityName);
    }

    recentSearches.insert(0, cityName);

    if (recentSearches.length > 5) {
      recentSearches = recentSearches.take(5).toList();
    }

    await prefs.setStringList('recentSearches', recentSearches);
  }

  Future<List<String>> loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recentSearches') ?? [];
  }
}
