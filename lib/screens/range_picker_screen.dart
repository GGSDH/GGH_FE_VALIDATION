import 'dart:developer';

import 'package:flutter/material.dart';
import '../widgets/range_picker.dart';

class RangePickerScreen extends StatelessWidget {
  const RangePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const YearRangePicker();
  }
}

class YearRangePicker extends StatefulWidget {
  const YearRangePicker({super.key});

  @override
  State<YearRangePicker> createState() => _YearRangePickerState();
}

class _YearRangePickerState extends State<YearRangePicker> {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      log('selectedDay: $selectedDay');
      if (startDate.isBefore(endDate)) {
        startDate = selectedDay;
        endDate = selectedDay;
      } else if (selectedDay.isBefore(startDate)) {
        startDate = selectedDay;
      } else if (selectedDay.isAfter(endDate)) {
        endDate = selectedDay;
      } else {
        startDate = selectedDay;
        endDate = selectedDay;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ListView.builder(
      itemCount: 12,
      itemBuilder: (BuildContext context, int index) {
        final targetDate = DateTime(now.year, now.month + index, now.day);

        return RangePicker(
          now: targetDate,
          startDate: startDate,
          endDate: endDate,
          onDaySelected: _onDaySelected,
        );
      },
    );
  }
}