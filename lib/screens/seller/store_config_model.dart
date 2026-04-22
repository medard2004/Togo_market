import 'package:flutter/material.dart';

class DayOpeningHours {
  final String day;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  bool isOpen;
  bool isHalfDay;

  DayOpeningHours({
    required this.day,
    this.openingTime = const TimeOfDay(hour: 8, minute: 0),
    this.closingTime = const TimeOfDay(hour: 18, minute: 0),
    this.isOpen = true,
    this.isHalfDay = false,
  });
}

class StoreConfigData {
  String name = '';
  String slogan = '';
  String description = '';
  List<String> categoryIds = [];
  String phone = '';
  String zone = 'Tokoin';
  String address = '';
  
  List<DayOpeningHours> openingHours = [
    DayOpeningHours(day: 'Lundi'),
    DayOpeningHours(day: 'Mardi'),
    DayOpeningHours(day: 'Mercredi'),
    DayOpeningHours(day: 'Jeudi'),
    DayOpeningHours(day: 'Vendredi'),
    DayOpeningHours(day: 'Samedi', isHalfDay: true, closingTime: const TimeOfDay(hour: 12, minute: 0)),
    DayOpeningHours(day: 'Dimanche', isOpen: false),
  ];
}
