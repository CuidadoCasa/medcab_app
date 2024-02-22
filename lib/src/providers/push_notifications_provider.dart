import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_medcab/src/providers/client_provider.dart';
import 'package:app_medcab/src/providers/driver_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_medcab/src/utils/shared_pref.dart';

class PushNotificationsProvider {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final StreamController<Map<String, dynamic>> _streamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get message => _streamController.stream;

  void initPushNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _streamController.sink.add(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _streamController.sink.add(message.data);
      SharedPref sharedPref = SharedPref();
      sharedPref.save('isNotification', 'true');
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: true,
    );

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
    
  }
  
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('OnResume $message');
  }

  // void initPushNotifications() async {
  //   _firebaseMessaging.configure(
  //   // _firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) {
  //       print('Cuando estamos en primer plano');
  //       print('OnMessage: $message');
  //       _streamController.sink.add(message);
  //     },
  //     onLaunch: (Map<String, dynamic> message) {
  //       print('OnLaunch: $message');
  //       _streamController.sink.add(message);
  //       SharedPref sharedPref = SharedPref();
  //       sharedPref.save('isNotification', 'true');
  //     },
  //     onResume: (Map<String, dynamic> message) {
  //       print('OnResume $message');
  //       _streamController.sink.add(message);
  //     }
  //   );

  //   _firebaseMessaging.requestPermission(
  //     sound: true,
  //     badge: true,
  //     alert: true,
  //     provisional: true
  //   );

  //   _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
  //     print('Coonfiguraciones para Ios fueron regustradas $settings');
  //   });


  // }

  void saveToken(String idUser, String typeUser) async {

    String ? token = '';
    if(Platform.isIOS){
      token = await _firebaseMessaging.getAPNSToken();
    } else {
      token = await _firebaseMessaging.getToken();
    }
    
    Map<String, dynamic> data = {
      'token': token
    };

    if (typeUser == 'client') {
      ClientProvider clientProvider = ClientProvider();
      clientProvider.update(data, idUser);
    }
    else {
      DriverProvider driverProvider = DriverProvider();
      driverProvider.update(data, idUser);
    }

  }

  Future<void> sendMessage(String to, Map<String, dynamic> data, String title, String body) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String> {
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAAP1lEFQ:APA91bE-qh2t7_WgpHpjImc_MT-TUNRXc9RieEI9n2UICYNrcr2aBwqAIwlp44MBK7ekYvrQbAznVRISx7ouPYlXTN9da-Y7h6Dkd3USmGeJQnAPoNsDziz1Pj0tdSR1oEZdG0Tap5kr'
      },
      body: jsonEncode(
        <String, dynamic> {
          'notification': <String, dynamic> {
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'to': to
        }
      )
    );
  }

  void dispose () {
    _streamController.onCancel;
  }

}