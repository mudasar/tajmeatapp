import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/view/base/notification_dialog.dart';
import 'package:flutter_grocery/view/screens/chat/chat_screen.dart';
import 'package:flutter_grocery/view/screens/order/order_details_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = new AndroidInitializationSettings('notification_icon');
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      print('response is ---------- ${jsonDecode(notificationResponse.payload)}');
      int _orderId;
      String _type = 'general';
      if(notificationResponse != null && notificationResponse.payload.isNotEmpty) {
        _orderId = int.tryParse(jsonDecode(notificationResponse.payload)['order_id']) ?? null;
        _type = jsonDecode(notificationResponse.payload)['type'];
      }
        try{
          if(_orderId != null) {

            Get.navigator.push(MaterialPageRoute(builder: (context) =>
                OrderDetailsScreen(orderModel: null, orderId: _orderId)),
            );
          }else if(_orderId == null && _type == 'message') {
            Get.navigator.push(
              MaterialPageRoute(builder: (context) => ChatScreen(orderModel: null,isAppBar: true,)),
            );}

        }catch (e) {}
        return;
      },);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}");
      print('id ${message.data}');
     // _route(message);
      showNotification(message, flutterLocalNotificationsPlugin, kIsWeb);

    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onOpenApp: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}");
      showNotification(message, flutterLocalNotificationsPlugin, kIsWeb);

    });

    // FirebaseMessaging.instance.onTokenRefresh
    //     .listen((fcmToken) {
    //       print('notificaton refress call');
    // })
    //     .onError((err) {
    //   print('notificaton refress call error : $err');
    //   // Error getting token.
    // });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    String _title;
    String _body;
    String _orderID;
    String _image;
    String _type;
    if(data) {
      _title = message.data['title'];
      _body = message.data['body'];
      _orderID = message.data['order_id'];
      _image = (message.data['image'] != null && message.data['image'].isNotEmpty)
          ? message.data['image'].startsWith('http') ? message.data['image']
          : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.data['image']}' : null;

    }else {
      _title = message.notification.title;
      _body = message.notification.body;
      _orderID = message.notification.titleLocKey;
      if(Platform.isAndroid) {
        _image = (message.notification.android.imageUrl != null && message.notification.android.imageUrl.isNotEmpty)
            ? message.notification.android.imageUrl.startsWith('http') ? message.notification.android.imageUrl
            : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.android.imageUrl}' : null;
      }else if(Platform.isIOS) {
        _image = (message.notification.apple.imageUrl != null && message.notification.apple.imageUrl.isNotEmpty)
            ? message.notification.apple.imageUrl.startsWith('http') ? message.notification.apple.imageUrl
            : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.apple.imageUrl}' : null;
      }
    }
    _type = message.data['type'];

    Map<String, String> _payloadData = {
      'title' : '$_title',
      'body' : '$_body',
      'order_id' : '$_orderID',
      'image' : '$_image',
      'type' : '$_type',
    };

    print('data------------------ $_payloadData');

    if(kIsWeb) {
      showDialog(
          context: Get.context,
          builder: (context) => Center(
            child: NotificationDialog(
              orderId: int.tryParse(_orderID),
              title: _title,
              body: _body,
              image: _image,
              type: _type,
            ),
          )
      );
    }

    else if(_image != null && _image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(_payloadData, fln);
      }catch(e) {
        await showBigTextNotification(_payloadData, fln);
      }
    }else {
      await showBigTextNotification(_payloadData, fln);
    }
  }


  static Future<void> showBigTextNotification(Map<String, String> data, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      data['body'], htmlFormatBigText: true,
      contentTitle: data['title'], htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, data['title'], data['body'], platformChannelSpecifics, payload: jsonEncode(data));
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      Map<String, String> data,
      FlutterLocalNotificationsPlugin fln,
      ) async {
    final String largeIconPath = await _downloadAndSaveFile(data['image'], 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(data['image'], 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: data['title'], htmlFormatContentTitle: true,
      summaryText: data['body'], htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, data['title'], data['body'], platformChannelSpecifics, payload: jsonEncode(data));
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print("onBackground: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}");
}