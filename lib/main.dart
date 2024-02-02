import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

import 'package:sensorsapp/notification.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

  // Définition du seuil pour la détection de ralentisseurs
  double seuil = 10.0; // Valeur de seuil à ajuster en fonction de vos besoins

  @override
  void initState() {
    super.initState();
    // Commence à écouter les mises à jour de la vitesse du GPS
    _getLocationSpeed();
    // Commence à écouter les mises à jour des capteurs
    _listenToSensors();
  }

  // Obtient la vitesse actuelle à partir du GPS
  Future<void> _getLocationSpeed() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _speed = position.speed.toString();
    });
  }

  // Écoute les mises à jour des capteurs
void _listenToSensors() {
  accelerometerEvents.listen((AccelerometerEvent event) {
    // Calcul de l'accélération totale (magnitude) à partir des données de l'accéléromètre
    double accelerationMagnitude =
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z);
    accelerationMagnitude = sqrt(accelerationMagnitude);

    // Logique de détection de ralentisseurs
    if (accelerationMagnitude > seuil) {
      setState(() {
        _isSpeeding = true;
      });
      // Si la vitesse dépasse le seuil, affiche la notification
      _showSpeedingNotification();
    } else {
      setState(() {
        _isSpeeding = false;
      });
    }
  });
}

// Affiche la notification de vitesse excessive
void _showSpeedingNotification() async {
  await NotificationManager.init(); // Initialisation du gestionnaire de notifications
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
            Text(
              'Current Speed:',
            ),
            Text(
              '$_speed m/s',
              style: Theme.of(context).textTheme.headline4,
            ),
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