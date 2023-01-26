import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hava_durumu/search_page.dart';
import 'package:hava_durumu/widgets/daily_weather_card.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = 'İstanbul';
  double? temperature;
  String code = 'home';
  final String key = 'APIKEY';
  Position? devicePosition;
  // ignore: prefer_typing_uninitialized_variables
  var locationData;
  String? icon;

  List<String> icons = [];
  List<double> temperatures = [];
  List<String> dates = [];

  final spinkit = const SpinKitChasingDots(
    color: Colors.white,
    size: 72,
  );

  Future<void> getLocationDataFromAPI() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);
    setState(() {
      temperature = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      code = locationDataParsed['weather'].first['main'];
      icon = locationDataParsed['weather'].first['icon'];
    });
  }

  Future<void> getLocationDataFromAPIByLatLan() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
      final locationDataParsed = jsonDecode(locationData.body);
      setState(() {
        temperature = locationDataParsed['main']['temp'];
        location = locationDataParsed['name'];
        code = locationDataParsed['weather'].first['main'];
        icon = locationDataParsed['weather'].first['icon'];
      });
    }
  }

  Future<void> getDevicePosition() async {
    devicePosition = await _determinePosition();
  }
  Future<void> getDailyForecastByLatLon() async{
    var forecastData = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecastData.body);

    temperatures.clear();
    icons.clear();
    dates.clear();
    DateTime dateTime;
    setState(() {
      for(int i = 7; i<40; i = i+8){
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });

  }
  Future<void> getDailyForecastByLocation() async{
    var forecastData = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecastData.body);

    temperatures.clear();
    icons.clear();
    dates.clear();
    DateTime dateTime;
    setState(() {
      for(int i = 7; i<40; i = i+8){
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });

  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataFromAPIByLatLan();
    await getDailyForecastByLatLon();
  }

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/$code.jpg'), fit: BoxFit.cover),
      ),
      child: (temperature == null || devicePosition == null || icons.isEmpty || dates.isEmpty || temperatures.isEmpty)
          ? Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    spinkit,
                  ],
                ),
              ),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: max(150, 10),
                      child: Image.network(
                          'http://openweathermap.org/img/wn/$icon@4x.png'),
                    ),
                    Text(
                      '$temperature°C',
                      style: const TextStyle(
                          fontSize: 70, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () async {
                            final selectedCity = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchPage(),
                              ),
                            );
                            location = selectedCity;
                            getLocationDataFromAPI();
                            getDailyForecastByLocation();
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    buildWeatherCards(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildWeatherCards(BuildContext context) {

    List<DailyWeatherCard> cards = [];
    for(int i = 0; i<5; i++){
      cards.add(DailyWeatherCard(icon: icons[i], temperature: temperatures[i], date: dates[i]));
    }

    return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: cards,
                    ),
                  );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
