import 'package:flutter/material.dart';
import '../widgets/range_picker.dart';

class RangePickerScreen extends StatelessWidget {
  const RangePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white
      ),
      child: ListView.builder(
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          final now = DateTime.now();
          final targetDate = DateTime(now.year, now.month + index);
          return RangePicker(now: targetDate);
        },
      ),
    );
  }
}