import 'package:flutter/material.dart';
import 'package:weather_app/backend/shared_prefs.dart';
import 'package:weather_app/pages/weather_details.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController _cityController = TextEditingController();
  List<String> recentSearches = [];
  SharedPrefs sharedPrefs = SharedPrefs();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // Method to load recent searches from shared preferences
  Future<void> _loadRecentSearches() async {
    List<String> searches = await sharedPrefs.loadRecentSearches();
    setState(() {
      recentSearches = searches;
    });
  }

  // Method to handle refresh action
  Future<void> _handleRefresh() async {
    await _loadRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text(
          'Weather\'s App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[300],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[300]!, Colors.blue[100]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Input Field
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(top: 30, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: "Search City",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          // Navigate to WeatherDetails screen with the entered city name
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WeatherDetails(
                              cityName: _cityController.text,
                            ),
                          ));
                        },
                        child: const Icon(Icons.search, color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                // Recent Searches List
                Expanded(
                  child: recentSearches.isEmpty
                      ? const Center(
                          child: Text(
                            'No recent searches',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: recentSearches.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(recentSearches[index]),
                                leading: const Icon(Icons.search),
                                onTap: () {
                                  // Navigate to WeatherDetails screen with the selected city name
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => WeatherDetails(
                                        cityName: recentSearches[index]),
                                  ));
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
