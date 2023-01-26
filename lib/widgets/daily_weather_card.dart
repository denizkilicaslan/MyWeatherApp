import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard({Key? key, required this.icon, required this.temperature, required this.date}) : super(key: key);

  final String icon;
  final double temperature;
  final String date;

  @override
  Widget build(BuildContext context) {
    List<String> days = ['Pazartesi','Salı', 'Çarşmba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    String weekday = days[DateTime.parse(date).weekday - 1];
    return Card(
      color: Colors.transparent,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Image.network('http://openweathermap.org/img/wn/$icon.png'),
            Text(
              '$temperature°C',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(weekday),
          ],
        ),
      ),
    );
  }
}
