import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:kilmatic_weather_app/utils/util.dart' as util;
import 'package:http/http.dart' as http;

class Kilmatic extends StatefulWidget {
  @override
  _KilmaticState createState() => _KilmaticState();
}

class _KilmaticState extends State<Kilmatic> {
  String _cityEntered;
  Future _goToNextScree(BuildContext context) async{
    Map results = await Navigator.of(context).push(
      new MaterialPageRoute<Map>(builder: (BuildContext context){
        return new ChangeCity();
      })
    );
    
    if(results != null && results.containsKey('enter')){
      _cityEntered = results['enter'].toString();
    }else{
      print('Nothing!');
    }
  }

  void showStuff() async{
   Map data = await getWeather(util.apiID, util.defaultCity);
   print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text('Kilmatic'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          new IconButton(
              icon:new Icon(Icons.menu),
              onPressed: () {_goToNextScree(context);}),
        ],
      ),

      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset('images/umbrella.png',
            width: 490.0,
            height:1200.0,
            fit: BoxFit.fill,),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: new Text('${_cityEntered == null ? util.defaultCity : _cityEntered}',
            style: cityStyle(),),
          ),
          
          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
          ),

          updateTempWidget(_cityEntered)
        ],
      ),

    );
  }

  Widget updateTempWidget(String cityName){
    return new FutureBuilder(
        future: getWeather(util.apiID,cityName == null ? util.defaultCity : cityName),
        builder: (BuildContext context,AsyncSnapshot<Map> snapshot){
          //where we get all of the json data, we setup widgets etc.
          if(snapshot.hasData){
            Map content = snapshot.data;
            return new Container(
              margin: const EdgeInsets.fromLTRB(30.0, 360.0, 0.0, 0.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new ListTile(
                    title: new Text(content['main']['temp'].toString() + " °F",
                    style: new TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 49.9,
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                    ),),

                    subtitle: new ListTile(
                      title: new Text(
                        "Humidity: ${content['main']['humidity'].toString()}\n"
                        "Min: ${content['main']['temp_min'].toString()} °F\n"
                        "Max: ${content['main']['temp_max'].toString()} °F",

                        style: extraData(),
                      ),
                    ),

                  )
                ],
              ),
            );
          }else{
            return new Container();
          }

        });
  }

  Future<Map> getWeather(String apiID, String cityName) async{
    String apiURL = "https://samples.openweathermap.org/data/2.5/weather?q=${cityName}&appid=${util.apiID}";
    http.Response response = await http.get(apiURL);
    return json.decode(response.body);
  }
}

class ChangeCity extends StatelessWidget {
  var __cityFieldController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Change City'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),

      body: new Stack(
        children: <Widget>[
        new Center(
          child: new Image.asset('images/white_snow.png',
          width: 490.0,
          height: 1200.0,
          fit: BoxFit.fill,),
        ),

        new ListView(
          children: <Widget>[
            new ListTile(
              title: new TextField(
                 decoration: new InputDecoration(
                   hintText: 'Enter City',
                 ),
                controller: __cityFieldController,
                keyboardType: TextInputType.text,
              ),
            ),

            new ListTile(
              title: new FlatButton(
                  onPressed: (){
                    Navigator.pop(context,{
                      'enter': __cityFieldController.text
                    });
                  },
                  textColor: Colors.white,
                  color: Colors.redAccent,
                  child: new Text('Get Weather',)),
            )

          ],
        )

        ],
      ),

    );
  }
}



TextStyle cityStyle(){
  return new TextStyle(
    color: Colors.white,
    fontSize: 22.0,
    fontStyle: FontStyle.italic
  );
}

TextStyle tempStyle() {
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.9,
  );
}

TextStyle extraData(){
  return new TextStyle(
    color: Colors.white70,
    fontStyle: FontStyle.normal,
    fontSize: 17.0,
  );
}
