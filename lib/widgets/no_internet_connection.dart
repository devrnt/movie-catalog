import 'package:flutter/material.dart';
import 'package:movie_catalog/data/strings.dart';

class NoInternetConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Center(
            child: Text(
              Strings.noInternetTitle,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 15.0),
          ),
          Center(
            child: Icon(
              Icons.signal_wifi_off,
              size: 32.0,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 7.0),
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.help_outline,
                size: 22.0,
                color: Colors.white.withOpacity(0.9),
              ),
              Text(
                ' What can I do?',
                style: TextStyle(
                    fontSize: 15.0, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                '1. Make sure you have an internet connection. (VPN not supported  yet)',
                style: TextStyle(color: Colors.grey),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3.0),
              ),
              Text(
                '2. Turn off wifi/mobile network.',
                style: TextStyle(color: Colors.grey),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3.0),
              ),
              Text(
                // 'Please turn on your internet connection.\nMake sure you have a working network connection.\nVPN are not supported at the moment.\nTry turning your WiFi on and off.',
                '3. Turn wifi/mobile network back on.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }
}
