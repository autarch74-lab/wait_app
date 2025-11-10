// lib/app.dart
import 'package:flutter/material.dart';

Widget createApp(Widget home) => MaterialApp(
  title: 'Wait',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primarySwatch: Colors.blue),
  home: home,
);
