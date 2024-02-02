import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensorsapp/notification.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedometer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _speed = '0';
  bool _isSpeeding = false;
  double _accelerationThreshold = 10.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var locationStatus = await Permission.location.request();
    var soundStatus = await Permission.microphone.request();

    if (locationStatus.isGranted && soundStatus.isGranted) {
      _startListening();
    } else {
      // Handle permission denied scenarios
    }
  }

  Future<void> _startListening() async {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double accelerationMagnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (accelerationMagnitude > _accelerationThreshold) {
        _handleSpeedingDetected();
      }
    });

    // Initiate GPS speed tracking
    _getLocationSpeed();
  }

  Future<void> _getLocationSpeed() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _speed = position.speed.toStringAsFixed(2);
    });

    // Check for speeding after updating speed
    if (double.parse(_speed) > 10) {
      _handleSpeedingDetected();
    }
  }

  void _handleSpeedingDetected() async {
    setState(() {
      _isSpeeding = true;
    });

    // Show notification for speeding alert
    await NotificationManager.init();
    await NotificationManager.showNotification(
      id: 0,
      title: 'Speeding Alert',
      body: 'You are speeding!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speedometer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Speedometer(speed: double.parse(_speed)),
            _isSpeeding
                ? Text(
                    'Alert: You are speeding!',
                    style: TextStyle(color: Colors.red),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

class Speedometer extends StatelessWidget {
  final double speed;

  Speedometer({required this.speed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Speedometer background
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.grey.shade300, Colors.white],
                stops: [0.3, 1.0],
              ),
            ),
          ),
          // Speedometer indicator
          Transform.rotate(
            angle: pi * (speed / 180),
            child: Container(
              width: 3,
              height: 90,
              color: Colors.red,
            ),
          ),
          // Speed text
          Positioned(
            top: 160,
            child: Text(
              '$speed km/h',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'CarSpeedFont', // Utilisation de la police personnalisée
              ),
            ),
          ),
        ],
      ),
    );
  }
}
