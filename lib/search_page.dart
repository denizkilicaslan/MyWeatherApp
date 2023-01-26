import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = ' ';

  @override
  Widget build(BuildContext context) {
    // aFunc();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/search.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: TextField(
                  onChanged: (value) {
                    selectedCity = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Şehir Seçiniz',
                    labelStyle: TextStyle(color: Colors.brown),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(fontSize: 30.0),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () async{
                  var response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid={APIKEY}&units=metric'));

                  if(response.statusCode == 200){
                    //sayfa kaldır, sayfayı çağıran/açan yere komuta/satıra bir veri dön
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, selectedCity);
                  } else {
                    _showMyDialog();
                  }
                },
                child: const Text('Select City'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location not Found'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please select a valid location'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
